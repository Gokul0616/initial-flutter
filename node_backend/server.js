const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const videoRoutes = require('./routes/videos');
const commentRoutes = require('./routes/comments');
const messageRoutes = require('./routes/messages');
const storyRoutes = require('./routes/stories');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Make io available to routes
app.set('io', io);

// Database connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ Connected to MongoDB'))
.catch(err => console.error('❌ MongoDB connection error:', err));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/videos', videoRoutes);
app.use('/api/comments', commentRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/stories', storyRoutes);

// Socket.io for real-time features
const activeUsers = new Map();

io.on('connection', (socket) => {
  console.log('👤 User connected:', socket.id);

  // User joins with their ID
  socket.on('join', (userId) => {
    activeUsers.set(userId, socket.id);
    socket.userId = userId;
    console.log(`User ${userId} joined with socket ${socket.id}`);
  });

  // Real-time comments
  socket.on('new_comment', (data) => {
    socket.broadcast.emit('comment_added', data);
  });

  // Real-time likes
  socket.on('video_liked', (data) => {
    socket.broadcast.emit('like_updated', data);
  });

  // Real-time follows
  socket.on('user_followed', (data) => {
    const targetSocketId = activeUsers.get(data.targetUserId);
    if (targetSocketId) {
      io.to(targetSocketId).emit('new_follower', data);
    }
  });

  // Private messaging
  socket.on('send_message', (data) => {
    const recipientSocketId = activeUsers.get(data.recipientId);
    if (recipientSocketId) {
      io.to(recipientSocketId).emit('new_message', data);
    }
  });

  // Message reactions
  socket.on('message_reaction', (data) => {
    const recipientSocketId = activeUsers.get(data.recipientId);
    if (recipientSocketId) {
      io.to(recipientSocketId).emit('message_reaction', data);
    }
  });

  // Message deleted
  socket.on('message_deleted', (data) => {
    const recipientSocketId = activeUsers.get(data.recipientId);
    if (recipientSocketId) {
      io.to(recipientSocketId).emit('message_deleted', data);
    }
  });

  // Story events
  socket.on('new_story', (data) => {
    socket.broadcast.emit('new_story', data);
  });

  socket.on('story_viewed', (data) => {
    const creatorSocketId = activeUsers.get(data.creatorId);
    if (creatorSocketId) {
      io.to(creatorSocketId).emit('story_viewed', data);
    }
  });

  socket.on('story_reaction', (data) => {
    const creatorSocketId = activeUsers.get(data.creatorId);
    if (creatorSocketId) {
      io.to(creatorSocketId).emit('story_reaction', data);
    }
  });

  // Live notifications
  socket.on('send_notification', (data) => {
    const targetSocketId = activeUsers.get(data.targetUserId);
    if (targetSocketId) {
      io.to(targetSocketId).emit('notification', data);
    }
  });

  // Typing indicators
  socket.on('typing_start', (data) => {
    const recipientSocketId = activeUsers.get(data.recipientId);
    if (recipientSocketId) {
      io.to(recipientSocketId).emit('user_typing', {
        userId: socket.userId,
        isTyping: true
      });
    }
  });

  socket.on('typing_stop', (data) => {
    const recipientSocketId = activeUsers.get(data.recipientId);
    if (recipientSocketId) {
      io.to(recipientSocketId).emit('user_typing', {
        userId: socket.userId,
        isTyping: false
      });
    }
  });

  socket.on('disconnect', () => {
    if (socket.userId) {
      activeUsers.delete(socket.userId);
    }
    console.log('👤 User disconnected:', socket.id);
  });
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'TikTok Clone API is running!' });
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Server Error:', error);
  res.status(500).json({ error: 'Internal server error' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`🚀 TikTok Clone Server running on port ${PORT}`);
  console.log(`📱 API available at http://localhost:${PORT}/api`);
  console.log(`🔌 Socket.IO server running`);
});

module.exports = { app, io };