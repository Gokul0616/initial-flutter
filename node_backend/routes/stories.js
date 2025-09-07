const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Story = require('../models/Story');
const User = require('../models/User');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = path.join(__dirname, '../uploads/stories');
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'story-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 100 * 1024 * 1024 // 100MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|mp4|mov|avi|webm/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only images and videos are allowed'));
    }
  }
});

// Get public stories (no auth required for testing)
router.get('/public', async (req, res) => {
  try {
    const stories = await Story.find({
      privacy: 'public',
      isDeleted: false,
      $or: [
        { expiresAt: { $gt: new Date() } },
        { isHighlight: true }
      ]
    })
    .populate('creator', 'username displayName profilePicture isVerified')
    .sort({ createdAt: -1 })
    .limit(20);

    const storyGroups = {};
    stories.forEach(story => {
      const creatorId = story.creator._id.toString();
      if (!storyGroups[creatorId]) {
        storyGroups[creatorId] = {
          user: story.creator,
          stories: [],
          hasUnviewed: true,
          latestStory: story.createdAt
        };
      }
      storyGroups[creatorId].stories.push(story.toStoryJSON());
    });

    res.json({
      storyGroups: Object.values(storyGroups)
    });

  } catch (error) {
    console.error('Get public stories error:', error);
    res.status(500).json({ error: 'Server error fetching stories' });
  }
});

// Create new story
router.post('/create', auth, upload.single('media'), async (req, res) => {
  try {
    const { content, text, textColor, backgroundColor, stickers, music, privacy } = req.body;
    const userId = req.user._id;

    const storyData = {
      creator: userId,
      content: content || 'text',
      text: text || '',
      textColor: textColor || '#FFFFFF',
      backgroundColor: backgroundColor || '#000000',
      privacy: privacy || 'public'
    };

    // Add media URL if file uploaded
    if (req.file) {
      storyData.mediaUrl = `/uploads/stories/${req.file.filename}`;
      storyData.content = req.file.mimetype.startsWith('video/') ? 'video' : 'photo';
    }

    // Parse stickers if provided
    if (stickers) {
      try {
        storyData.stickers = JSON.parse(stickers);
      } catch (e) {
        storyData.stickers = [];
      }
    }

    // Parse music if provided
    if (music) {
      try {
        storyData.music = JSON.parse(music);
      } catch (e) {
        storyData.music = {};
      }
    }

    const story = new Story(storyData);
    await story.save();
    await story.populate('creator', 'username displayName profilePicture isVerified');

    // Emit real-time event
    req.app.get('io').emit('new_story', {
      story: story.toStoryJSON()
    });

    res.status(201).json({
      message: 'Story created successfully',
      data: story.toStoryJSON()
    });

  } catch (error) {
    console.error('Create story error:', error);
    res.status(500).json({ error: 'Server error creating story' });
  }
});

// Get user's own stories
router.get('/my-stories', auth, async (req, res) => {
  try {
    const userId = req.user._id;
    
    const stories = await Story.find({
      creator: userId,
      isDeleted: false,
      $or: [
        { expiresAt: { $gt: new Date() } },
        { isHighlight: true }
      ]
    })
    .populate('creator', 'username displayName profilePicture isVerified')
    .sort({ createdAt: -1 });

    res.json({
      stories: stories.map(story => story.toStoryJSON())
    });

  } catch (error) {
    console.error('Get my stories error:', error);
    res.status(500).json({ error: 'Server error fetching stories' });
  }
});

// Get stories from following users
router.get('/following-stories', auth, async (req, res) => {
  try {
    const userId = req.user._id;
    const user = await User.findById(userId);
    
    const followingIds = user.following || [];
    followingIds.push(userId); // Include own stories

    const stories = await Story.aggregate([
      {
        $match: {
          creator: { $in: followingIds },
          isDeleted: false,
          $or: [
            { expiresAt: { $gt: new Date() } },
            { isHighlight: true }
          ]
        }
      },
      {
        $group: {
          _id: '$creator',
          stories: { $push: '$$ROOT' },
          latestStory: { $max: '$createdAt' },
          hasUnviewed: {
            $sum: {
              $cond: [
                { $not: { $in: [userId, '$viewers.userId'] } },
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
        $sort: { hasUnviewed: -1, latestStory: -1 }
      }
    ]);

    res.json({
      storiesGroups: stories.map(group => ({
        user: {
          id: group.user._id,
          username: group.user.username,
          displayName: group.user.displayName,
          profilePicture: group.user.profilePicture,
          isVerified: group.user.isVerified
        },
        stories: group.stories.map(story => ({
          id: story._id,
          content: story.content,
          mediaUrl: story.mediaUrl,
          text: story.text,
          textColor: story.textColor,
          backgroundColor: story.backgroundColor,
          stickers: story.stickers,
          music: story.music,
          expiresAt: story.expiresAt,
          viewsCount: story.viewsCount,
          isHighlight: story.isHighlight,
          createdAt: story.createdAt
        })),
        hasUnviewed: group.hasUnviewed > 0,
        latestStory: group.latestStory
      }))
    });

  } catch (error) {
    console.error('Get following stories error:', error);
    res.status(500).json({ error: 'Server error fetching stories' });
  }
});

// View story (mark as viewed)
router.post('/:storyId/view', auth, async (req, res) => {
  try {
    const { storyId } = req.params;
    const userId = req.user._id;

    const story = await Story.findById(storyId);
    if (!story) {
      return res.status(404).json({ error: 'Story not found' });
    }

    // Add viewer if not already viewed
    story.addViewer(userId);
    await story.save();

    res.json({ message: 'Story viewed' });

  } catch (error) {
    console.error('View story error:', error);
    res.status(500).json({ error: 'Server error viewing story' });
  }
});

// Get story viewers
router.get('/:storyId/viewers', auth, async (req, res) => {
  try {
    const { storyId } = req.params;
    const userId = req.user._id;

    const story = await Story.findById(storyId);
    if (!story) {
      return res.status(404).json({ error: 'Story not found' });
    }

    // Only story creator can see viewers
    if (story.creator !== userId) {
      return res.status(403).json({ error: 'Not authorized to view story viewers' });
    }

    // Populate viewer details
    const viewerIds = story.viewers.map(v => v.userId);
    const viewers = await User.find({ _id: { $in: viewerIds } })
      .select('username displayName profilePicture isVerified');

    const viewersWithTime = story.viewers.map(viewer => {
      const user = viewers.find(u => u._id.toString() === viewer.userId);
      return {
        user: user ? {
          id: user._id,
          username: user.username,
          displayName: user.displayName,
          profilePicture: user.profilePicture,
          isVerified: user.isVerified
        } : null,
        viewedAt: viewer.viewedAt
      };
    }).filter(v => v.user);

    res.json({
      viewers: viewersWithTime.sort((a, b) => new Date(b.viewedAt) - new Date(a.viewedAt))
    });

  } catch (error) {
    console.error('Get story viewers error:', error);
    res.status(500).json({ error: 'Server error fetching viewers' });
  }
});

// Add story to highlights
router.post('/:storyId/highlight', auth, async (req, res) => {
  try {
    const { storyId } = req.params;
    const { title } = req.body;
    const userId = req.user._id;

    const story = await Story.findById(storyId);
    if (!story) {
      return res.status(404).json({ error: 'Story not found' });
    }

    if (story.creator !== userId) {
      return res.status(403).json({ error: 'Not authorized to modify this story' });
    }

    story.isHighlight = true;
    story.highlightTitle = title || 'Highlight';
    await story.save();

    res.json({
      message: 'Story added to highlights',
      data: story.toStoryJSON()
    });

  } catch (error) {
    console.error('Add highlight error:', error);
    res.status(500).json({ error: 'Server error adding to highlights' });
  }
});

// Delete story
router.delete('/:storyId', auth, async (req, res) => {
  try {
    const { storyId } = req.params;
    const userId = req.user._id;

    const story = await Story.findById(storyId);
    if (!story) {
      return res.status(404).json({ error: 'Story not found' });
    }

    if (story.creator !== userId) {
      return res.status(403).json({ error: 'Not authorized to delete this story' });
    }

    // Mark as deleted instead of actually deleting
    story.isDeleted = true;
    await story.save();

    res.json({ message: 'Story deleted successfully' });

  } catch (error) {
    console.error('Delete story error:', error);
    res.status(500).json({ error: 'Server error deleting story' });
  }
});

// React to story
router.post('/:storyId/react', auth, async (req, res) => {
  try {
    const { storyId } = req.params;
    const { emoji } = req.body;
    const userId = req.user._id;

    const story = await Story.findById(storyId);
    if (!story) {
      return res.status(404).json({ error: 'Story not found' });
    }

    // Remove existing reaction from this user
    story.reactions = story.reactions.filter(r => r.userId !== userId);
    
    // Add new reaction
    if (emoji) {
      story.reactions.push({ userId, emoji });
    }

    await story.save();

    // Emit real-time event to story creator
    req.app.get('io').emit('story_reaction', {
      storyId,
      creatorId: story.creator,
      reaction: { userId, emoji, createdAt: new Date() }
    });

    res.json({ message: 'Reaction updated' });

  } catch (error) {
    console.error('React to story error:', error);
    res.status(500).json({ error: 'Server error reacting to story' });
  }
});

module.exports = router;