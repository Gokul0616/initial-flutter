const express = require('express');
const User = require('../models/User');
const Video = require('../models/Video');
const { auth, optionalAuth } = require('../middleware/auth');
const multer = require('multer');
const path = require('path');
const fs = require('fs-extra');
const { v4: uuidv4 } = require('uuid');

const router = express.Router();

// Configure multer for profile picture uploads
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadPath = path.join(__dirname, '../uploads/profiles');
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
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
});

// Get user profile by username
router.get('/profile/:username', optionalAuth, async (req, res) => {
  try {
    const { username } = req.params;
    const currentUserId = req.user?._id;

    const user = await User.findOne({ username }).select('-password -email');
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Check if current user follows this user
    const isFollowing = currentUserId ? 
      user.followers.includes(currentUserId) : false;

    // Get user's videos
    const videos = await Video.find({ 
      user: user._id, 
      isActive: true 
    })
    .populate('user', 'username displayName profilePicture isVerified')
    .sort({ createdAt: -1 })
    .limit(20);

    const userProfile = {
      ...user.toProfileJSON(),
      isFollowing,
      videos: videos.map(video => video.toVideoJSON(currentUserId))
    };

    res.json({ user: userProfile });

  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({ error: 'Server error fetching user profile' });
  }
});

// Update user profile
router.put('/profile', auth, upload.single('profilePicture'), async (req, res) => {
  try {
    const { displayName, bio, themePreference } = req.body;
    const user = req.user;

    // Update basic info
    if (displayName) user.displayName = displayName;
    if (bio !== undefined) user.bio = bio;
    if (themePreference) {
      const validThemes = ['darkClassic', 'lightClassic', 'darkNeon', 'lightPastel', 'darkPurple', 'lightGreen', 'darkOrange', 'lightBlue'];
      if (validThemes.includes(themePreference)) {
        user.themePreference = themePreference;
      }
    }

    // Handle profile picture upload
    if (req.file) {
      // Delete old profile picture if exists
      if (user.profilePicture) {
        const oldImagePath = path.join(__dirname, '../uploads/profiles', path.basename(user.profilePicture));
        await fs.remove(oldImagePath).catch(() => {});
      }
      
      user.profilePicture = `/uploads/profiles/${req.file.filename}`;
    }

    await user.save();

    res.json({
      message: 'Profile updated successfully',
      user: user.toProfileJSON()
    });

  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ error: 'Server error updating profile' });
  }
});

// Update user theme preference
router.put('/theme', auth, async (req, res) => {
  try {
    const { themePreference } = req.body;
    const user = req.user;

    if (!themePreference) {
      return res.status(400).json({ error: 'Theme preference is required' });
    }

    const validThemes = ['darkClassic', 'lightClassic', 'darkNeon', 'lightPastel', 'darkPurple', 'lightGreen', 'darkOrange', 'lightBlue'];
    
    if (!validThemes.includes(themePreference)) {
      return res.status(400).json({ error: 'Invalid theme preference' });
    }

    user.themePreference = themePreference;
    await user.save();

    res.json({
      message: 'Theme updated successfully',
      themePreference: user.themePreference
    });

  } catch (error) {
    console.error('Update theme error:', error);
    res.status(500).json({ error: 'Server error updating theme' });
  }
});

// Get user theme preference
router.get('/theme', auth, async (req, res) => {
  try {
    const user = req.user;
    
    res.json({
      themePreference: user.themePreference || 'darkClassic'
    });

  } catch (error) {
    console.error('Get theme error:', error);
    res.status(500).json({ error: 'Server error fetching theme' });
  }
});

// Follow/Unfollow user
router.post('/follow/:userId', auth, async (req, res) => {
  try {
    const { userId } = req.params;
    const currentUser = req.user;

    if (userId === currentUser._id.toString()) {
      return res.status(400).json({ error: 'Cannot follow yourself' });
    }

    const targetUser = await User.findById(userId);
    if (!targetUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    const isFollowing = currentUser.following.includes(userId);

    if (isFollowing) {
      // Unfollow
      currentUser.following.pull(userId);
      targetUser.followers.pull(currentUser._id);
      currentUser.followingCount = Math.max(0, currentUser.followingCount - 1);
      targetUser.followersCount = Math.max(0, targetUser.followersCount - 1);
    } else {
      // Follow
      currentUser.following.push(userId);
      targetUser.followers.push(currentUser._id);
      currentUser.followingCount += 1;
      targetUser.followersCount += 1;
    }

    await Promise.all([currentUser.save(), targetUser.save()]);

    // Emit real-time notification
    if (!isFollowing) {
      req.app.get('io').emit('user_followed', {
        targetUserId: userId,
        follower: {
          id: currentUser._id,
          username: currentUser.username,
          displayName: currentUser.displayName,
          profilePicture: currentUser.profilePicture
        }
      });
    }

    res.json({
      message: isFollowing ? 'Unfollowed successfully' : 'Followed successfully',
      isFollowing: !isFollowing
    });

  } catch (error) {
    console.error('Follow/Unfollow error:', error);
    res.status(500).json({ error: 'Server error during follow action' });
  }
});

// Get followers list
router.get('/:userId/followers', optionalAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const user = await User.findById(userId)
      .populate({
        path: 'followers',
        select: 'username displayName profilePicture isVerified followersCount',
        options: { skip, limit }
      });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      followers: user.followers,
      hasMore: user.followers.length === limit
    });

  } catch (error) {
    console.error('Get followers error:', error);
    res.status(500).json({ error: 'Server error fetching followers' });
  }
});

// Get following list
router.get('/:userId/following', optionalAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const user = await User.findById(userId)
      .populate({
        path: 'following',
        select: 'username displayName profilePicture isVerified followersCount',
        options: { skip, limit }
      });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      following: user.following,
      hasMore: user.following.length === limit
    });

  } catch (error) {
    console.error('Get following error:', error);
    res.status(500).json({ error: 'Server error fetching following' });
  }
});

// Search users
router.get('/search', optionalAuth, async (req, res) => {
  try {
    const { q, page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    if (!q || q.trim().length < 2) {
      return res.status(400).json({ error: 'Search query must be at least 2 characters' });
    }

    const searchRegex = new RegExp(q.trim(), 'i');
    
    const users = await User.find({
      $or: [
        { username: searchRegex },
        { displayName: searchRegex }
      ]
    })
    .select('username displayName profilePicture isVerified followersCount')
    .sort({ followersCount: -1 })
    .skip(skip)
    .limit(parseInt(limit));

    res.json({
      users,
      hasMore: users.length === parseInt(limit)
    });

  } catch (error) {
    console.error('Search users error:', error);
    res.status(500).json({ error: 'Server error during user search' });
  }
});

module.exports = router;