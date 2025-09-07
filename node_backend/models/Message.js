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
    enum: ['text', 'image', 'video', 'audio', 'story_reply', 'media_group', 'sticker', 'gif'],
    default: 'text'
  },
  // Media attachments
  media: {
    url: String,
    type: {
      type: String,
      enum: ['image', 'video', 'audio', 'file', 'gif', 'sticker']
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
    senderName: String,
    mediaUrl: String,
    messageType: String
  },
  // For drag and drop functionality
  position: {
    x: Number,
    y: Number
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
  },
  // Edit functionality
  isEdited: {
    type: Boolean,
    default: false
  },
  editedAt: {
    type: Date
  },
  editHistory: [{
    text: String,
    editedAt: {
      type: Date,
      default: Date.now
    }
  }],
  // TikTok-like features
  mentions: [{
    userId: String,
    username: String,
    position: {
      start: Number,
      end: Number
    }
  }],
  hashtags: [String],
  // Voice message features
  voiceNote: {
    url: String,
    duration: Number,
    visualData: [Number] // Waveform data
  }
}, {
  timestamps: true
});

// Index for better performance
messageSchema.index({ sender: 1, recipient: 1, createdAt: -1 });
messageSchema.index({ recipient: 1, isRead: 1 });
messageSchema.index({ createdAt: -1 });
messageSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

// Check if message is editable (within 3 hours)
messageSchema.methods.isEditable = function() {
  const threeHoursAgo = new Date(Date.now() - 3 * 60 * 60 * 1000);
  return this.createdAt > threeHoursAgo && !this.isDeleted;
};

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
    position: this.position,
    isRead: this.isRead,
    readAt: this.readAt,
    status: this.status,
    expiresAt: this.expiresAt,
    isEdited: this.isEdited,
    editedAt: this.editedAt,
    editHistory: this.editHistory,
    mentions: this.mentions,
    hashtags: this.hashtags,
    voiceNote: this.voiceNote,
    isEditable: this.isEditable(),
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
  if (this.messageType === 'sticker') return '🎭 Sticker';
  if (this.messageType === 'gif') return '🎬 GIF';
  if (this.voiceNote) return '🎤 Voice message';
  return 'Message';
};

module.exports = mongoose.model('Message', messageSchema);