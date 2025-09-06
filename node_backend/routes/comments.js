const express = require('express');
const Comment = require('../models/Comment');
const Video = require('../models/Video');
const { auth, optionalAuth } = require('../middleware/auth');

const router = express.Router();

// Get comments for a video
router.get('/video/:videoId', optionalAuth, async (req, res) => {
  try {
    const { videoId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const currentUserId = req.user?._id;

    // Find video
    const video = await Video.findOne({ 
      $or: [{ _id: videoId }, { id: videoId }],
      isActive: true 
    });

    if (!video) {
      return res.status(404).json({ error: 'Video not found' });
    }

    // Get top-level comments (no parent)
    const comments = await Comment.find({
      video: video._id,
      parentComment: null,
      isActive: true
    })
    .populate('user', 'username displayName profilePicture isVerified')
    .populate({
      path: 'replies',
      populate: {
        path: 'user',
        select: 'username displayName profilePicture isVerified'
      },
      match: { isActive: true },
      options: { limit: 3, sort: { createdAt: 1 } } // Show first 3 replies
    })
    .sort({ likesCount: -1, createdAt: -1 })
    .skip(skip)
    .limit(limit);

    const commentsWithInteraction = comments.map(comment => ({
      ...comment.toCommentJSON(currentUserId),
      replies: comment.replies.map(reply => reply.toCommentJSON(currentUserId))
    }));

    res.json({
      comments: commentsWithInteraction,
      hasMore: comments.length === limit
    });

  } catch (error) {
    console.error('Get comments error:', error);
    res.status(500).json({ error: 'Server error fetching comments' });
  }
});

// Add comment to video
router.post('/video/:videoId', auth, async (req, res) => {
  try {
    const { videoId } = req.params;
    const { text, parentCommentId } = req.body;
    const userId = req.user._id;

    if (!text || text.trim().length === 0) {
      return res.status(400).json({ error: 'Comment text is required' });
    }

    if (text.length > 500) {
      return res.status(400).json({ error: 'Comment must be less than 500 characters' });
    }

    // Find video
    const video = await Video.findOne({ 
      $or: [{ _id: videoId }, { id: videoId }],
      isActive: true 
    });

    if (!video) {
      return res.status(404).json({ error: 'Video not found' });
    }

    if (!video.allowComments) {
      return res.status(403).json({ error: 'Comments are disabled for this video' });
    }

    // Check if replying to a comment
    let parentComment = null;
    if (parentCommentId) {
      parentComment = await Comment.findOne({
        _id: parentCommentId,
        video: video._id,
        isActive: true
      });

      if (!parentComment) {
        return res.status(404).json({ error: 'Parent comment not found' });
      }
    }

    // Extract mentions from comment text
    const mentions = text.match(/@[\w]+/g)?.map(mention => mention.toLowerCase().slice(1)) || [];

    // Create comment
    const comment = new Comment({
      video: video._id,
      user: userId,
      text: text.trim(),
      parentComment: parentCommentId || null,
      mentions
    });

    await comment.save();

    // Update counters
    if (parentComment) {
      parentComment.repliesCount += 1;
      parentComment.replies.push(comment._id);
      await parentComment.save();
    } else {
      video.commentsCount += 1;
      await video.save();
    }

    // Populate user data for response
    await comment.populate('user', 'username displayName profilePicture isVerified');

    // Emit real-time comment
    req.app.get('io').emit('new_comment', {
      videoId: video.id,
      comment: comment.toCommentJSON(userId),
      parentCommentId: parentCommentId
    });

    res.status(201).json({
      message: 'Comment added successfully',
      comment: comment.toCommentJSON(userId)
    });

  } catch (error) {
    console.error('Add comment error:', error);
    res.status(500).json({ error: 'Server error adding comment' });
  }
});

// Get replies for a comment
router.get('/:commentId/replies', optionalAuth, async (req, res) => {
  try {
    const { commentId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;
    const currentUserId = req.user?._id;

    const parentComment = await Comment.findOne({
      _id: commentId,
      isActive: true
    });

    if (!parentComment) {
      return res.status(404).json({ error: 'Comment not found' });
    }

    const replies = await Comment.find({
      parentComment: commentId,
      isActive: true
    })
    .populate('user', 'username displayName profilePicture isVerified')
    .sort({ createdAt: 1 })
    .skip(skip)
    .limit(limit);

    const repliesWithInteraction = replies.map(reply => reply.toCommentJSON(currentUserId));

    res.json({
      replies: repliesWithInteraction,
      hasMore: replies.length === limit
    });

  } catch (error) {
    console.error('Get replies error:', error);
    res.status(500).json({ error: 'Server error fetching replies' });
  }
});

// Like/Unlike comment
router.post('/:commentId/like', auth, async (req, res) => {
  try {
    const { commentId } = req.params;
    const userId = req.user._id;

    const comment = await Comment.findOne({
      _id: commentId,
      isActive: true
    });

    if (!comment) {
      return res.status(404).json({ error: 'Comment not found' });
    }

    const existingLike = comment.likes.find(like => like.user.toString() === userId.toString());

    if (existingLike) {
      // Unlike
      comment.likes.pull({ _id: existingLike._id });
      comment.likesCount = Math.max(0, comment.likesCount - 1);
    } else {
      // Like
      comment.likes.push({ user: userId });
      comment.likesCount += 1;
    }

    await comment.save();

    res.json({
      message: existingLike ? 'Comment unliked' : 'Comment liked',
      isLiked: !existingLike,
      likesCount: comment.likesCount
    });

  } catch (error) {
    console.error('Like comment error:', error);
    res.status(500).json({ error: 'Server error liking comment' });
  }
});

// Delete comment
router.delete('/:commentId', auth, async (req, res) => {
  try {
    const { commentId } = req.params;
    const userId = req.user._id;

    const comment = await Comment.findOne({
      _id: commentId,
      user: userId,
      isActive: true
    });

    if (!comment) {
      return res.status(404).json({ error: 'Comment not found or unauthorized' });
    }

    // Soft delete comment and its replies
    comment.isActive = false;
    await comment.save();

    await Comment.updateMany(
      { parentComment: commentId },
      { isActive: false }
    );

    // Update parent comment or video counters
    if (comment.parentComment) {
      const parentComment = await Comment.findById(comment.parentComment);
      if (parentComment) {
        parentComment.repliesCount = Math.max(0, parentComment.repliesCount - 1);
        parentComment.replies.pull(commentId);
        await parentComment.save();
      }
    } else {
      const video = await Video.findById(comment.video);
      if (video) {
        video.commentsCount = Math.max(0, video.commentsCount - 1);
        await video.save();
      }
    }

    res.json({ message: 'Comment deleted successfully' });

  } catch (error) {
    console.error('Delete comment error:', error);
    res.status(500).json({ error: 'Server error deleting comment' });
  }
});

module.exports = router;