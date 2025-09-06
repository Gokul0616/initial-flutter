# 🎵 TikTok Clone - Complete Social Video Platform

A comprehensive TikTok clone built with **Flutter** + **Node.js** + **MongoDB** featuring real-time interactions, video sharing, and social features.

## 🌟 Features

### 📱 **Mobile App (Flutter)**
- **TikTok-like UI**: Dark theme with neon pink/cyan colors
- **Video Feed**: Infinite scroll with For You, Following, and Trending tabs
- **Camera Integration**: Record videos with filters and effects
- **Video Upload**: Caption, hashtags, privacy settings
- **Social Features**: Like, comment, share, follow/unfollow
- **Real-time Updates**: Live comments, likes, and notifications
- **User Profiles**: Custom profiles with stats and video galleries
- **Search & Discovery**: Find users, sounds, and hashtags
- **Messages**: Direct messaging system (coming soon)

### 🔧 **Backend API (Node.js)**
- **Authentication**: JWT-based login/register system
- **Video Management**: Upload, stream, and manage videos
- **User System**: Profiles, followers, following relationships
- **Comments System**: Nested comments with likes and replies
- **Real-time Features**: Socket.IO for live interactions
- **File Upload**: Multer for handling video and image uploads
- **Database**: MongoDB with optimized schemas

### ⚡ **Real-time Features**
- Live comment notifications
- Real-time like updates
- Follower notifications
- Socket-based messaging
- Live user status

## 🏗 **Tech Stack**

### **Frontend (Flutter)**
```yaml
- Flutter 3.0+
- Provider (State Management)
- Dio (HTTP Client)
- Socket.IO Client
- Video Player & Camera
- Cached Network Image
- Lottie Animations
- Google Fonts
```

### **Backend (Node.js)**
```json
- Express.js
- MongoDB + Mongoose
- Socket.IO
- JWT Authentication
- Multer (File Upload)
- bcryptjs (Password Hashing)
- CORS Support
```

## 🚀 **Quick Start**

### **Prerequisites**
- Node.js 16+
- Flutter 3.0+
- MongoDB (local or Atlas)

### **Backend Setup**
```bash
cd node_backend
npm install
npm run dev
```

The backend will run on `http://localhost:3001`

### **Flutter Setup**
```bash
cd flutter_frontend
flutter pub get
flutter run
```

### **Environment Configuration**

#### Backend (.env)
```env
PORT=3001
MONGODB_URI=mongodb+srv://test2:Test123@cluster0.afoaf7o.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0
JWT_SECRET=your_super_secret_jwt_key_here_change_in_production
UPLOAD_PATH=./uploads
NODE_ENV=development
```

#### Flutter (lib/utils/constants.dart)
```dart
static const String baseUrl = 'http://localhost:3001/api';
static const String socketUrl = 'http://localhost:3001';
```

## 📁 **Project Structure**

```
tiktok_clone/
├── node_backend/              # Express.js API
│   ├── models/               # MongoDB schemas
│   ├── routes/               # API endpoints
│   ├── middleware/           # Auth middleware
│   ├── uploads/              # File storage
│   └── server.js             # Main server
│
└── flutter_frontend/         # Flutter mobile app
    ├── lib/
    │   ├── models/           # Data models
    │   ├── providers/        # State management
    │   ├── screens/          # UI screens
    │   ├── widgets/          # Reusable widgets
    │   ├── services/         # API services
    │   └── utils/            # Utilities & theme
    └── assets/               # Static assets
```

## 🎨 **Design System**

### **Colors**
- **Primary**: #FF0050 (TikTok Pink)
- **Secondary**: #00F2EA (TikTok Cyan)  
- **Background**: #000000 (Pure Black)
- **Surface**: #161823 (Dark Surface)
- **Accent**: #FEBD38 (Golden Yellow)

### **Typography**
- **Font Family**: Proxima Nova
- **Responsive text scales**
- **TikTok-inspired styling**

## 🔌 **API Endpoints**

### **Authentication**
```
POST /api/auth/register     # User registration
POST /api/auth/login        # User login  
GET  /api/auth/me           # Get current user
POST /api/auth/verify-token # Verify JWT token
```

### **Videos**
```
GET  /api/videos/feed       # Get video feed
GET  /api/videos/trending   # Get trending videos
POST /api/videos/upload     # Upload new video
GET  /api/videos/:id        # Get single video
POST /api/videos/:id/like   # Like/unlike video
POST /api/videos/:id/share  # Share video
```

### **Users**
```
GET  /api/users/profile/:username  # Get user profile
PUT  /api/users/profile            # Update profile
POST /api/users/follow/:userId     # Follow/unfollow user
GET  /api/users/search             # Search users
```

### **Comments**
```
GET  /api/comments/video/:videoId  # Get video comments
POST /api/comments/video/:videoId  # Add comment
GET  /api/comments/:id/replies     # Get comment replies
POST /api/comments/:id/like        # Like comment
```

## 🔄 **Real-time Events**

### **Socket.IO Events**
```javascript
// Client → Server
'join'                  // Join user room
'new_comment'          // New comment added
'video_liked'          // Video liked/unliked
'user_followed'        // User followed
'send_message'         // Send private message

// Server → Client
'comment_added'        // New comment notification
'like_updated'         // Like count updated
'new_follower'         // New follower notification
'new_message'          // New message received
'notification'         // General notification
```

## 📱 **Screens & Features**

### **Authentication**
- ✅ Splash screen with animations
- ✅ Login with email/username
- ✅ Registration with validation
- ✅ JWT token management

### **Home Feed**
- ✅ Vertical video feed
- ✅ For You / Following / Trending tabs
- ✅ Infinite scroll with pagination
- ✅ Video interactions (like, comment, share)

### **Camera & Upload**
- ✅ Video recording with camera
- ✅ Gallery video selection  
- ✅ Video preview with editing
- ✅ Caption and hashtag support
- ✅ Privacy settings

### **Profile**
- ✅ User profile with stats
- ✅ Video grid layout
- ✅ Edit profile functionality
- ✅ Follow/unfollow actions
- ✅ Profile picture upload

### **Discovery**
- ✅ User search functionality
- ✅ Trending categories
- ✅ Popular hashtags
- ✅ Search suggestions

### **Social Features**
- ✅ Comments with nested replies
- ✅ Real-time comment updates
- ✅ Like animations
- ✅ Follow system
- ✅ User avatars and verification badges

## 🔧 **Development Features**

### **State Management**
- Provider pattern for clean architecture
- Separate providers for auth, videos, users, comments
- Real-time state updates via Socket.IO

### **API Integration**
- Dio for HTTP requests with interceptors
- Error handling and retry logic
- File upload with progress tracking
- Token-based authentication

### **UI/UX**
- Smooth page transitions
- Loading states and shimmer effects
- Error handling with user-friendly messages
- Responsive design for all screen sizes

## 🚀 **Deployment**

### **Backend Deployment**
```bash
# Set production environment
NODE_ENV=production

# Install dependencies
npm install --production

# Start with PM2
pm2 start server.js --name "tiktok-api"
```

### **Flutter Build**
```bash
# Android
flutter build apk --release

# iOS  
flutter build ios --release
```

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 **Acknowledgments**

- TikTok for UI/UX inspiration
- Flutter team for the amazing framework
- Node.js community for excellent packages
- MongoDB for flexible database solution

---

**Built with ❤️ for the creative community**

🎵 **Create • Share • Discover**