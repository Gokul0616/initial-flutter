import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/video_model.dart';
import '../providers/video_provider.dart';
import '../providers/user_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../screens/comments/comments_screen.dart';
import '../screens/profile/profile_screen.dart';
import 'user_avatar.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoModel video;
  final bool isPlaying;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.isPlaying,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _showPlayButton = false;
  
  late AnimationController _animationController;
  late Animation<double> _heartAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.isPlaying) {
      _initializeVideo();
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _initializeVideo();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _pauseVideo();
    }
  }

  Future<void> _initializeVideo() async {
    if (_videoController != null) {
      _videoController!.play();
      return;
    }

    try {
      _videoController = VideoPlayerController.network(widget.video.fullVideoUrl);
      await _videoController!.initialize();
      
      if (widget.isPlaying) {
        _videoController!.setLooping(true);
        _videoController!.play();
      }
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _pauseVideo() {
    _videoController?.pause();
  }

  void _togglePlayPause() {
    if (_videoController == null) return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _showPlayButton = true;
      } else {
        _videoController!.play();
        _showPlayButton = false;
      }
    });

    // Hide play button after 1 second
    if (_showPlayButton) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showPlayButton = false;
          });
        }
      });
    }
  }

  Future<void> _toggleLike() async {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    final success = await videoProvider.toggleLike(widget.video.id);
    
    if (success && widget.video.isLiked) {
      _animationController.forward().then((_) {
        _animationController.reset();
      });
    }
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsScreen(videoId: widget.video.id),
    );
  }

  void _shareVideo() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _viewProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(username: widget.video.user.username),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video Player
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: _isInitialized && _videoController != null
                ? GestureDetector(
                    onTap: _togglePlayPause,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
          ),
        ),

        // Play Button Overlay
        if (_showPlayButton)
          Positioned.fill(
            child: Center(
              child: AnimationLimiter(
                child: AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: const Duration(milliseconds: 300),
                  child: SlideAnimation(
                    verticalOffset: 30,
                    child: FadeInAnimation(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Like Animation Overlay
        Positioned.fill(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _heartAnimation.value * (1 + _scaleAnimation.value),
                  child: Opacity(
                    opacity: _heartAnimation.value * (1 - _scaleAnimation.value),
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.like,
                      size: 100,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Video Information
        Positioned(
          bottom: 0,
          left: 0,
          right: 80,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0x80000000),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // User Info
                GestureDetector(
                  onTap: _viewProfile,
                  child: Row(
                    children: [
                      UserAvatar(
                        imageUrl: widget.video.user.profileImageUrl,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '@${widget.video.user.username}',
                                  style: AppTextStyles.username.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                if (widget.video.user.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    color: AppColors.secondary,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              widget.video.user.displayName,
                              style: AppTextStyles.displayName.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Follow Button
                      if (widget.video.user.isFollowing != true)
                        Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Follow',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Caption
                if (widget.video.caption.isNotEmpty)
                  Text(
                    widget.video.caption,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 8),

                // Music Info
                if (widget.video.music != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${widget.video.music!.artist} - ${widget.video.music!.title}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),

        // Side Actions
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              // Like Button
              _buildActionButton(
                icon: widget.video.isLiked ? Icons.favorite : Icons.favorite_border,
                count: widget.video.likesCountText,
                color: widget.video.isLiked ? AppColors.like : Colors.white,
                onTap: _toggleLike,
              ),

              const SizedBox(height: 24),

              // Comment Button
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                count: widget.video.commentsCountText,
                color: Colors.white,
                onTap: _openComments,
              ),

              const SizedBox(height: 24),

              // Share Button
              _buildActionButton(
                icon: Icons.share_outlined,
                count: widget.video.sharesCountText,
                color: Colors.white,
                onTap: _shareVideo,
              ),

              const SizedBox(height: 24),

              // More Options
              _buildActionButton(
                icon: Icons.more_horiz,
                count: '',
                color: Colors.white,
                onTap: () {
                  // Show more options
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          if (count.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              count,
              style: AppTextStyles.counter.copyWith(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}