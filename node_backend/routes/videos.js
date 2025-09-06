const express = require('express');
const Video = require('../models/Video');
const User = require('../models/User');
const Comment = require('../models/Comment');
const { auth, optionalAuth } = require('../middleware/auth');
const multer = require('multer');
const path = require('path');
const fs = require('fs-extra');
const { v4: uuidv4 } = require('uuid');

const router = express.Router();

// Configure multer for video uploads
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadPath = path.join(__dirname, '../uploads/videos');
    await fs.ensureDir(uploadPath);
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueName = `${uuidv4()}-${Date.now()}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 100 * 1024 * 1024 }, // 100MB limit
  fileFilter: (req, file, cb) => {
    const allowedTypes = /mp4|avi|mov|wmv|flv|webm|mkv/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = file.mimetype.startsWith('video/');

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only video files are allowed'));
    }
  }
});

// Get feed videos (For You page)
router.get('/feed', optionalAuth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;
    const currentUserId = req.user?._id;

    // Algorithm: Mix of popular videos and random videos
    let videos;
    
    if (currentUserId) {
      // For logged-in users: personalized feed
      const user = await User.findById(currentUserId);
      const followingIds = user.following;
      
      // 70% from following, 30% discover new content
      const followingVideos = await Video.find({
        user: { $in: followingIds },
        isActive: true
      })
      .populate('user', 'username displayName profilePicture isVerified')
      .sort({ createdAt: -1 })
      .limit(Math.floor(limit * 0.7));

      const discoverVideos = await Video.find({
        user: { $nin: [currentUserId, ...followingIds] },
        isActive: true
      })
      .populate('user', 'username displayName profilePicture isVerified')
      .sort({ likesCount: -1, viewsCount: -1 })
      .limit(Math.ceil(limit * 0.3));

      videos = [...followingVideos, ...discoverVideos]
        .sort(() => Math.random() - 0.5) // Shuffle
        .slice(skip, skip + limit);
    } else {
      // For guests: popular videos
      videos = await Video.find({ isActive: true })
        .populate('user', 'username displayName profilePicture isVerified')
        .sort({ likesCount: -1, viewsCount: -1 })
        .skip(skip)
        .limit(limit);
    }

    const videosWithInteraction = videos.map(video => video.toVideoJSON(currentUserId));

    res.json({
      videos: videosWithInteraction,
      hasMore: videos.length === limit
    });

  } catch (error) {
    console.error('Get feed error:', error);
    res.status(500).json({ error: 'Server error fetching feed' });
  }
});

// Get trending videos
router.get('/trending', optionalAuth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;
    const currentUserId = req.user?._id;

    // Get videos from last 7 days, sorted by engagement
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);

    const videos = await Video.find({
      isActive: true,
      createdAt: { $gte: weekAgo }
    })
    .populate('user', 'username displayName profilePicture isVerified')
    .sort({ 
      likesCount: -1, 
      commentsCount: -1, 
      sharesCount: -1,
      viewsCount: -1 
    })
    .skip(skip)
    .limit(limit);

    const videosWithInteraction = videos.map(video => video.toVideoJSON(currentUserId));

    res.json({
      videos: videosWithInteraction,
      hasMore: videos.length === limit
    });

  } catch (error) {
    console.error('Get trending error:', error);
    res.status(500).json({ error: 'Server error fetching trending videos' });
  }
});

// Upload new video
router.post('/upload', auth, upload.single('video'), async (req, res) => {
  try {
    const { caption, hashtags, allowComments = true, allowDownload = true } = req.body;
    const user = req.user;

    if (!req.file) {
      return res.status(400).json({ error: 'Video file is required' });
    }

    // Parse hashtags
    let parsedHashtags = [];
    if (hashtags) {
      parsedHashtags = typeof hashtags === 'string' 
        ? hashtags.split(',').map(tag => tag.trim().toLowerCase())
        : hashtags;
    }

    // Extract hashtags from caption
    const captionHashtags = caption ? 
      caption.match(/#[\w]+/g)?.map(tag => tag.toLowerCase().slice(1)) || [] : [];
    
    parsedHashtags = [...new Set([...parsedHashtags, ...captionHashtags])];

    // Create video document
    const video = new Video({
      id: uuidv4(),
      user: user._id,
      caption: caption || '',
      videoUrl: `/uploads/videos/${req.file.filename}`,
      hashtags: parsedHashtags,
      allowComments: allowComments === 'true',
      allowDownload: allowDownload === 'true'
    });

    await video.save();

    // Update user's video count
    user.videosCount += 1;
    await user.save();

    // Populate user data for response
    await video.populate('user', 'username displayName profilePicture isVerified');

    res.status(201).json({
      message: 'Video uploaded successfully',
      video: video.toVideoJSON(user._id)
    });

  } catch (error) {
    console.error('Upload video error:', error);
    res.status(500).json({ error: 'Server error uploading video' });
  }
});

// Get single video
router.get('/:videoId', optionalAuth, async (req, res) => {
  try {
    const { videoId } = req.params;
    const currentUserId = req.user?._id;

    const video = await Video.findOne({ 
      $or: [{ _id: videoId }, { id: videoId }],
      isActive: true 
    })
    .populate('user', 'username displayName profilePicture isVerified');

    if (!video) {
      return res.status(404).json({ error: 'Video not found' });
    }

    // Increment view count
    video.viewsCount += 1;
    await video.save();

    res.json({
      video: video.toVideoJSON(currentUserId)
    });

  } catch (error) {
    console.error('Get video error:', error);
    res.status(500).json({ error: 'Server error fetching video' });
  }
});

// Like/Unlike video
router.post('/:videoId/like', auth, async (req, res) => {
  try {
    const { videoId } = req.params;
    const userId = req.user._id;

    const video = await Video.findOne({ 
      $or: [{ _id: videoId }, { id: videoId }],
      isActive: true 
    });

    if (!video) {
      return res.status(404).json({ error: 'Video not found' });
    }

    const existingLike = video.likes.find(like => like.user.toString() === userId.toString());

    if (existingLike) {
      // Unlike
      video.likes.pull({ _id: existingLike._id });
      video.likesCount = Math.max(0, video.likesCount - 1);
    } else {
      // Like
      video.likes.push({ user: userId });
      video.likesCount += 1;
    }

    await video.save();

    // Emit real-time update
    req.app.get('io').emit('video_liked', {
      videoId: video.id,
      likesCount: video.likesCount,
      isLiked: !existingLike
    });

    res.json({
      message: existingLike ? 'Video unliked' : 'Video liked',
      isLiked: !existingLike,
      likesCount: video.likesCount
    });

  } catch (error) {
    console.error('Like video error:', error);
    res.status(500).json({ error: 'Server error liking video' });
  }
});

// Share video (increment share count)
router.post('/:videoId/share', optionalAuth, async (req, res) => {
  try {
    const { videoId } = req.params;

    const video = await Video.findOne({ 
      $or: [{ _id: videoId }, { id: videoId }],
      isActive: true 
    });

    if (!video) {
      return res.status(404).json({ error: 'Video not found' });
    }

    video.sharesCount += 1;
    await video.save();

    res.json({
      message: 'Video shared',
      sharesCount: video.sharesCount
    });

  } catch (error) {
    console.error('Share video error:', error);
    res.status(500).json({ error: 'Server error sharing video' });
  }
});

// Delete video
router.delete('/:videoId', auth, async (req, res) => {
  try {
    const { videoId } = req.params;
    const userId = req.user._id;

    const video = await Video.findOne({ 
      $or: [{ _id: videoId }, { id: videoId }],
      user: userId,
      isActive: true 
    });

    if (!video) {
      return res.status(404).json({ error: 'Video not found or unauthorized' });
    }

    // Soft delete
    video.isActive = false;
    await video.save();

    // Delete associated comments
    await Comment.updateMany(
      { video: video._id },
      { isActive: false }
    );

    // Update user's video count
    req.user.videosCount = Math.max(0, req.user.videosCount - 1);
    await req.user.save();

    res.json({ message: 'Video deleted successfully' });

  } catch (error) {
    console.error('Delete video error:', error);
    res.status(500).json({ error: 'Server error deleting video' });
  }
});

module.exports = router;