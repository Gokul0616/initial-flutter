const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const messageSchema = new mongoose.Schema({
  _id: {
    type: String,
    default: uuidv4
  },
  sender: {
    type: String,
    ref: 'User',
    required: true
  },
  recipient: {
    type: String,
    ref: 'User',
    required: true
  },
  text: {
    type: String,
    default: '',
    maxlength: 1000
  },
  messageType: {
    type: String,
    enum: ['text', 'image', 'video', 'audio', 'story_reply', 'media_group'],
    default: 'text'
  },
  // Media attachments
  media: {
    url: String,
    type: {
      type: String,
      enum: ['image', 'video', 'audio', 'file']
    },
    filename: String,
    size: Number,
    thumbnail: String, // For videos
    duration: Number, // For videos/audio
    width: Number, // For images/videos
    height: Number // For images/videos
  },
  // For media groups (multiple images/videos)
  mediaGroup: [{
    url: String,
    type: String,
    filename: String,
    size: Number,
    thumbnail: String,
    width: Number,
    height: Number
  }],
  // Story reply reference
  storyReply: {
    storyId: String,
    storyMediaUrl: String,
    storyText: String
  },
  // Message reactions
  reactions: [{
    userId: String,
    emoji: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  // Reply to another message
  replyTo: {
    messageId: String,
    text: String,
    senderName: String
  },
  isRead: {
    type: Boolean,
    default: false
  },
  readAt: {
    type: Date
  },
  isDeleted: {
    type: Boolean,
    default: false
  },
  deletedFor: [{
    userId: String,
    deletedAt: {
      type: Date,
      default: Date.now
    }
  }],
  // For disappearing messages
  expiresAt: {
    type: Date
  },
  // Message status
  status: {
    type: String,
    enum: ['sending', 'sent', 'delivered', 'read'],
    default: 'sent'
  }
}, {
  timestamps: true
});

// Index for better performance
messageSchema.index({ sender: 1, recipient: 1, createdAt: -1 });
messageSchema.index({ recipient: 1, isRead: 1 });
messageSchema.index({ createdAt: -1 });
messageSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

// Generate message response JSON
messageSchema.methods.toMessageJSON = function() {
  return {
    id: this._id,
    text: this.text,
    sender: this.sender,
    recipient: this.recipient,
    messageType: this.messageType,
    media: this.media,
    mediaGroup: this.mediaGroup,
    storyReply: this.storyReply,
    reactions: this.reactions,
    replyTo: this.replyTo,
    isRead: this.isRead,
    readAt: this.readAt,
    status: this.status,
    expiresAt: this.expiresAt,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt
  };
};

// Check if message has media
messageSchema.methods.hasMedia = function() {
  return this.media && this.media.url || 
         (this.mediaGroup && this.mediaGroup.length > 0);
};

// Get message preview text
messageSchema.methods.getPreviewText = function() {
  if (this.text) return this.text;
  if (this.messageType === 'image') return '📷 Photo';
  if (this.messageType === 'video') return '🎥 Video';
  if (this.messageType === 'audio') return '🎵 Audio';
  if (this.messageType === 'story_reply') return '💬 Replied to story';
  if (this.messageType === 'media_group') return `📷 ${this.mediaGroup.length} photos`;
  return 'Message';
};

module.exports = mongoose.model('Message', messageSchema);