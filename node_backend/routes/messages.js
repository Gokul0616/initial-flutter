const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Message = require('../models/Message');
const User = require('../models/User');
const Story = require('../models/Story');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = path.join(__dirname, '../uploads/messages');
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'msg-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 100 * 1024 * 1024, // 100MB limit
    files: 10 // Max 10 files at once
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|mp4|mov|avi|webm|mp3|wav|ogg|pdf|doc|docx|txt/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype) || 
                     file.mimetype.startsWith('image/') ||
                     file.mimetype.startsWith('video/') ||
                     file.mimetype.startsWith('audio/');
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('File type not supported'));
    }
  }
});

// Get user conversations
router.get('/conversations', auth, async (req, res) => {
  try {
    const userId = req.user._id;
    
    const conversations = await Message.aggregate([
      {
        $match: {
          $or: [
            { sender: userId },
            { recipient: userId }
          ],
          isDeleted: false,
          deletedFor: { $not: { $elemMatch: { userId: userId } } }
        }
      },
      {
        $sort: { createdAt: -1 }
      },
      {
        $group: {
          _id: {
            $cond: [
              { $eq: ['$sender', userId] },
              '$recipient',
              '$sender'
            ]
          },
          lastMessage: { $first: '$$ROOT' },
          unreadCount: {
            $sum: {
              $cond: [
                {
                  $and: [
                    { $eq: ['$recipient', userId] },
                    { $eq: ['$isRead', false] }
                  ]
                },
                1,
                0
              ]
            }
          }
        }
      },
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: '_id',
          as: 'user'
        }
      },
      {
        $unwind: '$user'
      },
      {
        $lookup: {
          from: 'stories',
          let: { userId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: {
                  $and: [
                    { $eq: ['$creator', '$$userId'] },
                    { $eq: ['$isDeleted', false] },
                    { $or: [
                      { $gt: ['$expiresAt', new Date()] },
                      { $eq: ['$isHighlight', true] }
                    ]},
                    { $not: { $in: [userId, '$viewers.userId'] } }
                  ]
                }
              }
            },
            { $sort: { createdAt: -1 } },
            { $limit: 1 }
          ],
          as: 'latestStory'
        }
      },
      {
        $project: {
          user: {
            _id: '$user._id',
            username: '$user.username',
            displayName: '$user.displayName',
            profilePicture: '$user.profilePicture',
            isVerified: '$user.isVerified'
          },
          lastMessage: {
            id: '$lastMessage._id',
            text: '$lastMessage.text',
            messageType: '$lastMessage.messageType',
            media: '$lastMessage.media',
            createdAt: '$lastMessage.createdAt',
            isRead: '$lastMessage.isRead',
            sender: '$lastMessage.sender'
          },
          unreadCount: 1,
          hasStory: { $gt: [{ $size: '$latestStory' }, 0] },
          latestStory: { $arrayElemAt: ['$latestStory', 0] }
        }
      },
      {
        $sort: { 'lastMessage.createdAt': -1 }
      }
    ]);

    res.json({ 
      conversations: conversations.map(conv => ({
        ...conv,
        lastMessage: {
          ...conv.lastMessage,
          previewText: getMessagePreview(conv.lastMessage)
        }
      }))
    });

  } catch (error) {
    console.error('Get conversations error:', error);
    res.status(500).json({ error: 'Server error fetching conversations' });
  }
});

// Helper function for message preview
function getMessagePreview(message) {
  if (message.text) return message.text;
  if (message.messageType === 'image') return '📷 Photo';
  if (message.messageType === 'video') return '🎥 Video';
  if (message.messageType === 'audio') return '🎵 Audio';
  if (message.messageType === 'story_reply') return '💬 Replied to story';
  if (message.messageType === 'media_group') return '📷 Multiple photos';
  return 'Message';
}

// Get messages between two users
router.get('/conversation/:userId', auth, async (req, res) => {
  try {
    const currentUserId = req.user._id;
    const { userId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const skip = (page - 1) * limit;

    const messages = await Message.find({
      $or: [
        { sender: currentUserId, recipient: userId },
        { sender: userId, recipient: currentUserId }
      ],
      isDeleted: false,
      deletedFor: { $not: { $elemMatch: { userId: currentUserId } } }
    })
    .populate('sender', 'username displayName profilePicture isVerified')
    .populate('recipient', 'username displayName profilePicture isVerified')
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit);

    // Mark messages as read
    await Message.updateMany(
      {
        sender: userId,
        recipient: currentUserId,
        isRead: false
      },
      { isRead: true, readAt: new Date(), status: 'read' }
    );

    res.json({
      messages: messages.reverse().map(msg => msg.toMessageJSON()),
      hasMore: messages.length === limit
    });

  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ error: 'Server error fetching messages' });
  }
});

// Send text message
router.post('/send', auth, async (req, res) => {
  try {
    const { recipientId, text, replyTo, storyReply } = req.body;
    const senderId = req.user._id;

    if (!recipientId) {
      return res.status(400).json({ error: 'Recipient is required' });
    }

    if (!text && !storyReply) {
      return res.status(400).json({ error: 'Message text or story reply is required' });
    }

    // Check if recipient exists
    const recipient = await User.findById(recipientId);
    if (!recipient) {
      return res.status(404).json({ error: 'Recipient not found' });
    }

    const messageData = {
      sender: senderId,
      recipient: recipientId,
      text: text || '',
      messageType: storyReply ? 'story_reply' : 'text'
    };

    // Add reply reference
    if (replyTo) {
      const originalMessage = await Message.findById(replyTo.messageId)
        .populate('sender', 'displayName');
      if (originalMessage) {
        messageData.replyTo = {
          messageId: replyTo.messageId,
          text: originalMessage.text || getMessagePreview(originalMessage),
          senderName: originalMessage.sender.displayName
        };
      }
    }

    // Add story reply reference
    if (storyReply) {
      const story = await Story.findById(storyReply.storyId);
      if (story) {
        messageData.storyReply = {
          storyId: storyReply.storyId,
          storyMediaUrl: story.mediaUrl,
          storyText: story.text
        };
      }
    }

    const message = new Message(messageData);
    await message.save();
    await message.populate('sender', 'username displayName profilePicture isVerified');
    await message.populate('recipient', 'username displayName profilePicture isVerified');

    // Emit real-time message
    req.app.get('io').emit('new_message', {
      recipientId,
      message: message.toMessageJSON()
    });

    res.status(201).json({
      message: 'Message sent successfully',
      data: message.toMessageJSON()
    });

  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({ error: 'Server error sending message' });
  }
});

// Send media message
router.post('/send-media', auth, upload.array('media', 10), async (req, res) => {
  try {
    const { recipientId, text, replyTo } = req.body;
    const senderId = req.user._id;
    const files = req.files;

    if (!recipientId) {
      return res.status(400).json({ error: 'Recipient is required' });
    }

    if (!files || files.length === 0) {
      return res.status(400).json({ error: 'Media files are required' });
    }

    // Check if recipient exists
    const recipient = await User.findById(recipientId);
    if (!recipient) {
      return res.status(404).json({ error: 'Recipient not found' });
    }

    const messageData = {
      sender: senderId,
      recipient: recipientId,
      text: text || ''
    };

    // Handle single file
    if (files.length === 1) {
      const file = files[0];
      const mediaType = file.mimetype.startsWith('image/') ? 'image' : 
                       file.mimetype.startsWith('video/') ? 'video' : 'audio';
      
      messageData.messageType = mediaType;
      messageData.media = {
        url: `/uploads/messages/${file.filename}`,
        type: mediaType,
        filename: file.originalname,
        size: file.size
      };
    } else {
      // Handle multiple files
      messageData.messageType = 'media_group';
      messageData.mediaGroup = files.map(file => {
        const mediaType = file.mimetype.startsWith('image/') ? 'image' : 
                         file.mimetype.startsWith('video/') ? 'video' : 'audio';
        return {
          url: `/uploads/messages/${file.filename}`,
          type: mediaType,
          filename: file.originalname,
          size: file.size
        };
      });
    }

    // Add reply reference
    if (replyTo) {
      const originalMessage = await Message.findById(replyTo.messageId)
        .populate('sender', 'displayName');
      if (originalMessage) {
        messageData.replyTo = {
          messageId: replyTo.messageId,
          text: originalMessage.text || getMessagePreview(originalMessage),
          senderName: originalMessage.sender.displayName
        };
      }
    }

    const message = new Message(messageData);
    await message.save();
    await message.populate('sender', 'username displayName profilePicture isVerified');
    await message.populate('recipient', 'username displayName profilePicture isVerified');

    // Emit real-time message
    req.app.get('io').emit('new_message', {
      recipientId,
      message: message.toMessageJSON()
    });

    res.status(201).json({
      message: 'Media message sent successfully',
      data: message.toMessageJSON()
    });

  } catch (error) {
    console.error('Send media message error:', error);
    res.status(500).json({ error: 'Server error sending media message' });
  }
});

// React to message
router.post('/:messageId/react', auth, async (req, res) => {
  try {
    const { messageId } = req.params;
    const { emoji } = req.body;
    const userId = req.user._id;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({ error: 'Message not found' });
    }

    // Check if user is part of the conversation
    if (message.sender !== userId && message.recipient !== userId) {
      return res.status(403).json({ error: 'Not authorized' });
    }

    // Remove existing reaction from this user
    message.reactions = message.reactions.filter(r => r.userId !== userId);
    
    // Add new reaction if provided
    if (emoji) {
      message.reactions.push({ userId, emoji });
    }

    await message.save();

    // Emit real-time reaction
    const recipientId = message.sender === userId ? message.recipient : message.sender;
    req.app.get('io').emit('message_reaction', {
      recipientId,
      messageId,
      reaction: { userId, emoji, createdAt: new Date() }
    });

    res.json({ message: 'Reaction updated' });

  } catch (error) {
    console.error('React to message error:', error);
    res.status(500).json({ error: 'Server error reacting to message' });
  }
});

// Delete message
router.delete('/:messageId', auth, async (req, res) => {
  try {
    const { messageId } = req.params;
    const { deleteFor } = req.body; // 'me' or 'everyone'
    const userId = req.user._id;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({ error: 'Message not found' });
    }

    // Check if user is part of the conversation
    if (message.sender !== userId && message.recipient !== userId) {
      return res.status(403).json({ error: 'Not authorized' });
    }

    if (deleteFor === 'everyone' && message.sender === userId) {
      // Delete for everyone (only sender can do this)
      message.isDeleted = true;
    } else {
      // Delete for me only
      const existingDelete = message.deletedFor.find(d => d.userId === userId);
      if (!existingDelete) {
        message.deletedFor.push({ userId });
      }
    }

    await message.save();

    // Emit real-time delete
    if (deleteFor === 'everyone') {
      const recipientId = message.sender === userId ? message.recipient : message.sender;
      req.app.get('io').emit('message_deleted', {
        recipientId,
        messageId,
        deletedBy: userId
      });
    }

    res.json({ message: 'Message deleted successfully' });

  } catch (error) {
    console.error('Delete message error:', error);
    res.status(500).json({ error: 'Server error deleting message' });
  }
});

module.exports = router;