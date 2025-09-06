const mongoose = require('mongoose');

const videoSchema = new mongoose.Schema({
  id: {
    type: String,
    required: true,
    unique: true
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  caption: {
    type: String,
    maxlength: 500,
    default: ''
  },
  videoUrl: {
    type: String,
    required: true
  },
  thumbnailUrl: {
    type: String,
    default: ''
  },
  duration: {
    type: Number, // in seconds
    default: 0
  },
  likes: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  likesCount: {
    type: Number,
    default: 0
  },
  commentsCount: {
    type: Number,
    default: 0
  },
  sharesCount: {
    type: Number,
    default: 0
  },
  viewsCount: {
    type: Number,
    default: 0
  },
  hashtags: [{
    type: String,
    lowercase: true
  }],
  mentions: [{
    type: String,
    lowercase: true
  }],
  music: {
    title: String,
    artist: String,
    url: String,
    duration: Number
  },
  location: {
    name: String,
    latitude: Number,
    longitude: Number
  },
  isPrivate: {
    type: Boolean,
    default: false
  },
  allowComments: {
    type: Boolean,
    default: true
  },
  allowDownload: {
    type: Boolean,
    default: true
  },
  allowDuet: {
    type: Boolean,
    default: true
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Index for better performance
videoSchema.index({ user: 1, createdAt: -1 });
videoSchema.index({ hashtags: 1 });
videoSchema.index({ createdAt: -1 });
videoSchema.index({ likesCount: -1 });
videoSchema.index({ viewsCount: -1 });

// Virtual for comments
videoSchema.virtual('comments', {
  ref: 'Comment',
  localField: '_id',
  foreignField: 'video'
});

// Generate video response JSON
videoSchema.methods.toVideoJSON = function(currentUser = null) {
  const isLiked = currentUser ? 
    this.likes.some(like => like.user.toString() === currentUser.toString()) : false;

  return {
    id: this.id,
    user: this.user,
    caption: this.caption,
    videoUrl: this.videoUrl,
    thumbnailUrl: this.thumbnailUrl,
    duration: this.duration,
    likesCount: this.likesCount,
    commentsCount: this.commentsCount,
    sharesCount: this.sharesCount,
    viewsCount: this.viewsCount,
    hashtags: this.hashtags,
    mentions: this.mentions,
    music: this.music,
    location: this.location,
    isLiked: isLiked,
    allowComments: this.allowComments,
    allowDownload: this.allowDownload,
    allowDuet: this.allowDuet,
    createdAt: this.createdAt,
    updatedAt: this.updatedAt
  };
};

module.exports = mongoose.model('Video', videoSchema);