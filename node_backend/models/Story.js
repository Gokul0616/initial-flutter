const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const storyViewSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true
  },
  viewedAt: {
    type: Date,
    default: Date.now
  }
});

const storySchema = new mongoose.Schema({
  _id: {
    type: String,
    default: uuidv4
  },
  creator: {
    type: String,
    ref: 'User',
    required: true
  },
  content: {
    type: String,
    enum: ['photo', 'video', 'text'],
    required: true
  },
  mediaUrl: {
    type: String,
    default: ''
  },
  text: {
    type: String,
    default: '',
    maxlength: 500
  },
  textColor: {
    type: String,
    default: '#FFFFFF'
  },
  backgroundColor: {
    type: String,
    default: '#000000'
  },
  stickers: [{
    type: String,
    url: String,
    x: Number,
    y: Number,
    width: Number,
    height: Number,
    rotation: Number
  }],
  music: {
    title: String,
    artist: String,
    url: String,
    startTime: {
      type: Number,
      default: 0
    }
  },
  duration: {
    type: Number,
    default: 24 * 60 * 60 * 1000 // 24 hours in milliseconds
  },
  expiresAt: {
    type: Date,
    default: function() {
      return new Date(Date.now() + this.duration);
    }
  },
  viewers: [storyViewSchema],
  viewsCount: {
    type: Number,
    default: 0
  },
  privacy: {
    type: String,
    enum: ['public', 'friends', 'close_friends'],
    default: 'public'
  },
  isHighlight: {
    type: Boolean,
    default: false
  },
  highlightTitle: {
    type: String,
    default: ''
  },
  reactions: [{
    userId: String,
    emoji: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  replies: [{
    userId: String,
    message: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  isDeleted: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// Index for better performance
storySchema.index({ creator: 1, createdAt: -1 });
storySchema.index({ expiresAt: 1 });
storySchema.index({ isHighlight: 1, creator: 1 });

// Auto-delete expired stories
storySchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

// Get story response JSON
storySchema.methods.toStoryJSON = function() {
  return {
    id: this._id,
    creator: this.creator,
    content: this.content,
    mediaUrl: this.mediaUrl,
    text: this.text,
    textColor: this.textColor,
    backgroundColor: this.backgroundColor,
    stickers: this.stickers,
    music: this.music,
    duration: this.duration,
    expiresAt: this.expiresAt,
    viewers: this.viewers,
    viewsCount: this.viewsCount,
    privacy: this.privacy,
    isHighlight: this.isHighlight,
    highlightTitle: this.highlightTitle,
    reactions: this.reactions,
    replies: this.replies,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt
  };
};

// Check if story is expired
storySchema.methods.isExpired = function() {
  return !this.isHighlight && new Date() > this.expiresAt;
};

// Add viewer
storySchema.methods.addViewer = function(userId) {
  const existingViewer = this.viewers.find(v => v.userId === userId);
  if (!existingViewer) {
    this.viewers.push({ userId });
    this.viewsCount += 1;
  }
};

module.exports = mongoose.model('Story', storySchema);