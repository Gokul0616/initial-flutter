class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:3001/api';
  static const String socketUrl = 'http://localhost:3001';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int commentsPageSize = 20;
  static const int usersPageSize = 20;
  
  // File Upload
  static const int maxVideoSizeMB = 100;
  static const int maxImageSizeMB = 5;
  static const int maxVideoDurationSeconds = 60;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // TikTok-like Settings
  static const double videoAspectRatio = 9 / 16;
  static const int maxCaptionLength = 500;
  static const int maxCommentLength = 500;
  static const int maxBioLength = 200;
  static const int maxDisplayNameLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  
  // Socket Events
  static const String socketConnect = 'connect';
  static const String socketDisconnect = 'disconnect';
  static const String socketJoin = 'join';
  static const String socketNewComment = 'new_comment';
  static const String socketCommentAdded = 'comment_added';
  static const String socketVideoLiked = 'video_liked';
  static const String socketLikeUpdated = 'like_updated';
  static const String socketUserFollowed = 'user_followed';
  static const String socketNewFollower = 'new_follower';
  static const String socketSendMessage = 'send_message';
  static const String socketNewMessage = 'new_message';
  static const String socketSendNotification = 'send_notification';
  static const String socketNotification = 'notification';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError = 'Please log in to continue.';
  static const String videoUploadError = 'Failed to upload video. Please try again.';
  static const String commentError = 'Failed to post comment. Please try again.';
  
  // Success Messages
  static const String videoUploadSuccess = 'Video uploaded successfully!';
  static const String commentSuccess = 'Comment posted!';
  static const String followSuccess = 'Following user!';
  static const String unfollowSuccess = 'Unfollowed user!';
  static const String likeSuccess = 'Liked!';
  static const String unlikeSuccess = 'Unliked!';
  
  // Regex Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String usernamePattern = r'^[a-zA-Z0-9._]{3,30}$';
  static const String hashtagPattern = r'#[\w]+';
  static const String mentionPattern = r'@[\w]+';
}

class AppStringsErrors {
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidUsername = 'Username must be 3-30 characters with letters, numbers, dots, and underscores only';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String usernameRequired = 'Username is required';
  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';
  static const String displayNameRequired = 'Display name is required';
  static const String captionTooLong = 'Caption must be less than 500 characters';
  static const String commentTooLong = 'Comment must be less than 500 characters';
  static const String bioTooLong = 'Bio must be less than 200 characters';
  static const String displayNameTooLong = 'Display name must be less than 50 characters';
}

class AppStrings {
  // General
  static const String appName = 'TikTok Clone';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String share = 'Share';
  static const String report = 'Report';
  static const String block = 'Block';
  
  // Authentication
  static const String login = 'Log In';
  static const String signup = 'Sign Up';
  static const String logout = 'Log Out';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String createAccount = 'Create Account';
  static const String welcomeBack = 'Welcome Back!';
  static const String getStarted = 'Get Started';
  
  // Profile
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String followers = 'Followers';
  static const String following = 'Following';
  static const String likes = 'Likes';
  static const String videos = 'Videos';
  static const String bio = 'Bio';
  static const String displayName = 'Display Name';
  static const String username = 'Username';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String changeProfilePicture = 'Change Profile Picture';
  
  // Video
  static const String forYou = 'For You';
  static const String trending = 'Trending';
  static const String upload = 'Upload';
  static const String record = 'Record';
  static const String selectVideo = 'Select Video';
  static const String addCaption = 'Add a caption...';
  static const String postVideo = 'Post';
  static const String uploadingVideo = 'Uploading video...';
  
  // Comments
  static const String comments = 'Comments';
  static const String addComment = 'Add a comment...';
  static const String postComment = 'Post';
  static const String reply = 'Reply';
  static const String replies = 'Replies';
  static const String viewReplies = 'View replies';
  static const String hideReplies = 'Hide replies';
  
  // Social
  static const String follow = 'Follow';
  static const String unfollow = 'Unfollow';
  static const String like = 'Like';
  static const String unlike = 'Unlike';
  static const String comment = 'Comment';
  static const String viewProfile = 'View Profile';
  static const String sendMessage = 'Send Message';
  
  // Search
  static const String search = 'Search';
  static const String searchUsers = 'Search users...';
  static const String searchVideos = 'Search videos...';
  static const String noResults = 'No results found';
  static const String searchHistory = 'Search History';
  static const String clearHistory = 'Clear History';
  
  // Notifications
  static const String notifications = 'Notifications';
  static const String noNotifications = 'No notifications yet';
  static const String markAllRead = 'Mark All Read';
  
  // Settings
  static const String settings = 'Settings';
  static const String privacy = 'Privacy';
  static const String security = 'Security';
  static const String aboutUs = 'About Us';
  static const String termsOfService = 'Terms of Service';
  static const String privacyPolicy = 'Privacy Policy';
  static const String version = 'Version';
  
  // Empty States
  static const String noVideos = 'No videos yet';
  static const String noComments = 'No comments yet';
  static const String noFollowers = 'No followers yet';
  static const String noFollowing = 'Not following anyone yet';
  static const String startExploring = 'Start exploring to see amazing videos!';
}