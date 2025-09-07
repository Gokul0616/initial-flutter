import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/story_model.dart';
import '../../providers/story_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/draggable_story_element.dart';

class EnhancedStoryViewerScreen extends StatefulWidget {
  final List<StoryGroup> storyGroups;
  final int initialGroupIndex;
  final int initialStoryIndex;

  const EnhancedStoryViewerScreen({
    super.key,
    required this.storyGroups,
    this.initialGroupIndex = 0,
    this.initialStoryIndex = 0,
  });

  @override
  State<EnhancedStoryViewerScreen> createState() => _EnhancedStoryViewerScreenState();
}

class _EnhancedStoryViewerScreenState extends State<EnhancedStoryViewerScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _reactionController;
  VideoPlayerController? _videoController;
  
  int _currentGroupIndex = 0;
  int _currentStoryIndex = 0;
  bool _isPaused = false;
  bool _isEditMode = false;
  String? _reactionEmoji;
  
  final TextEditingController _replyController = TextEditingController();
  final List<String> _quickReactions = ['❤️', '😂', '😮', '😢', '🔥', '👏'];

  @override
  void initState() {
    super.initState();
    _currentGroupIndex = widget.initialGroupIndex;
    _currentStoryIndex = widget.initialStoryIndex;
    
    _pageController = PageController(initialPage: _currentGroupIndex);
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _reactionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _startStoryTimer();
    _markStoryAsViewed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _reactionController.dispose();
    _videoController?.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _startStoryTimer() {
    _progressController.reset();
    final currentStory = _getCurrentStory();
    
    if (currentStory != null) {
      if (currentStory.isVideo) {
        _initializeVideo(currentStory);
      } else {
        _progressController.forward();
      }
      
      _progressController.addStatusListener(_onProgressComplete);
    }
  }

  void _onProgressComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isPaused) {
      _nextStory();
    }
  }

  void _initializeVideo(StoryModel story) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(story.mediaUrlFull);
    _videoController!.initialize().then((_) {
      if (mounted) {
        setState(() {});
        _videoController!.play();
        _progressController.duration = Duration(
          milliseconds: _videoController!.value.duration.inMilliseconds
        );
        _progressController.forward();
      }
    });
  }

  StoryModel? _getCurrentStory() {
    if (_currentGroupIndex < widget.storyGroups.length) {
      final group = widget.storyGroups[_currentGroupIndex];
      if (_currentStoryIndex < group.stories.length) {
        return group.stories[_currentStoryIndex];
      }
    }
    return null;
  }

  void _nextStory() {
    final currentGroup = widget.storyGroups[_currentGroupIndex];
    
    if (_currentStoryIndex < currentGroup.stories.length - 1) {
      // Next story in current group
      setState(() {
        _currentStoryIndex++;
      });
      _startStoryTimer();
      _markStoryAsViewed();
    } else if (_currentGroupIndex < widget.storyGroups.length - 1) {
      // Next group
      setState(() {
        _currentGroupIndex++;
        _currentStoryIndex = 0;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStoryTimer();
      _markStoryAsViewed();
    } else {
      // End of stories
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      // Previous story in current group
      setState(() {
        _currentStoryIndex--;
      });
      _startStoryTimer();
    } else if (_currentGroupIndex > 0) {
      // Previous group
      setState(() {
        _currentGroupIndex--;
        _currentStoryIndex = widget.storyGroups[_currentGroupIndex].stories.length - 1;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStoryTimer();
    }
  }

  void _pauseStory() {
    setState(() {
      _isPaused = true;
    });
    _progressController.stop();
    _videoController?.pause();
  }

  void _resumeStory() {
    setState(() {
      _isPaused = false;
    });
    _progressController.forward();
    _videoController?.play();
  }

  void _markStoryAsViewed() {
    final currentStory = _getCurrentStory();
    if (currentStory != null) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<StoryProvider>().viewStory(
          currentStory.id,
          authProvider.user!.id,
        );
      }
    }
  }

  void _showReactionPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.primarySurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              'React to this story',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              children: _quickReactions.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    _reactToStory(emoji);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _reactToStory(String emoji) {
    final currentStory = _getCurrentStory();
    if (currentStory != null) {
      setState(() {
        _reactionEmoji = emoji;
      });
      
      _reactionController.forward().then((_) {
        _reactionController.reverse();
      });
      
      // Send reaction to backend
      context.read<StoryProvider>().reactToStory(
        currentStory.id,
        emoji,
      );
    }
  }

  void _showReplyDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.primarySurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text(
                'Reply to this story',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _replyController,
                decoration: const InputDecoration(
                  hintText: 'Write a reply...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _replyToStory();
                      },
                      child: const Text('Send'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _replyToStory() async {
    if (_replyController.text.trim().isEmpty) return;
    
    final currentStory = _getCurrentStory();
    if (currentStory != null) {
      final success = await context.read<StoryProvider>().replyToStory(
        currentStory.id,
        _replyController.text.trim(),
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply sent successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send reply. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _replyController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.storyGroups.length,
        onPageChanged: (index) {
          setState(() {
            _currentGroupIndex = index;
            _currentStoryIndex = 0;
          });
          _startStoryTimer();
          _markStoryAsViewed();
        },
        itemBuilder: (context, index) {
          return _buildStoryPage(widget.storyGroups[index]);
        },
      ),
    );
  }

  Widget _buildStoryPage(StoryGroup group) {
    final currentStory = group.stories[_currentStoryIndex];
    
    return GestureDetector(
      onTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth / 3) {
          _previousStory();
        } else if (details.globalPosition.dx > screenWidth * 2 / 3) {
          _nextStory();
        } else {
          if (_isPaused) {
            _resumeStory();
          } else {
            _pauseStory();
          }
        }
      },
      onLongPress: _pauseStory,
      onLongPressUp: _resumeStory,
      child: Stack(
        children: [
          // Story Content
          _buildStoryContent(currentStory),
          
          // Draggable Elements
          if (currentStory.stickers.isNotEmpty || currentStory.textElements.isNotEmpty)
            ..._buildDraggableElements(currentStory),
          
          // Progress Indicators
          _buildProgressIndicators(group),
          
          // Top Bar
          _buildTopBar(group.user),
          
          // Reaction Animation
          if (_reactionEmoji != null) _buildReactionAnimation(),
          
          // Bottom Actions
          _buildBottomActions(currentStory),
          
          // Pause Indicator
          if (_isPaused) _buildPauseIndicator(),
        ],
      ),
    );
  }

  Widget _buildStoryContent(StoryModel story) {
    if (story.isVideo) {
      return _videoController != null && _videoController!.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator());
    } else if (story.isPhoto) {
      return SizedBox.expand(
        child: CachedNetworkImage(
          imageUrl: story.mediaUrlFull,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[800],
            child: const Center(
              child: Icon(Icons.error, color: Colors.white),
            ),
          ),
        ),
      );
    } else {
      // Text story
      Color backgroundColor;
      Color textColor;
      
      try {
        backgroundColor = Color(int.parse(story.backgroundColor.replaceFirst('#', '0xff')));
        textColor = Color(int.parse(story.textColor.replaceFirst('#', '0xff')));
      } catch (e) {
        backgroundColor = Colors.black;
        textColor = Colors.white;
      }
      
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: backgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              story.text,
              style: TextStyle(
                color: textColor,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }

  List<Widget> _buildDraggableElements(StoryModel story) {
    List<Widget> elements = [];
    
    // Add stickers
    for (int i = 0; i < story.stickers.length; i++) {
      elements.add(
        DraggableStoryElement(
          key: ValueKey('sticker_$i'),
          sticker: story.stickers[i],
          isEditMode: _isEditMode,
          onPositionChanged: (x, y) {
            // Update story sticker position
          },
          onRotationChanged: (rotation) {
            // Update story sticker rotation
          },
          onScaleChanged: (scale) {
            // Update story sticker scale
          },
        ),
      );
    }
    
    // Add text elements
    for (int i = 0; i < story.textElements.length; i++) {
      elements.add(
        DraggableStoryElement(
          key: ValueKey('text_$i'),
          textElement: story.textElements[i],
          isEditMode: _isEditMode,
          onPositionChanged: (x, y) {
            // Update story text element position
          },
          onRotationChanged: (rotation) {
            // Update story text element rotation
          },
          onScaleChanged: (scale) {
            // Update story text element scale
          },
        ),
      );
    }
    
    return elements;
  }

  Widget _buildProgressIndicators(StoryGroup group) {
    return Positioned(
      top: 50,
      left: 8,
      right: 8,
      child: Row(
        children: List.generate(group.stories.length, (index) {
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  double progress = 0.0;
                  if (index < _currentStoryIndex) {
                    progress = 1.0;
                  } else if (index == _currentStoryIndex) {
                    progress = _progressController.value;
                  }
                  
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopBar(UserModel user) {
    return Positioned(
      top: 70,
      left: 16,
      right: 16,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: user.profilePictureUrl.isNotEmpty
                ? NetworkImage(user.profilePictureUrl)
                : null,
            child: user.profilePictureUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 4),
                       Icon(
                        Icons.verified,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Text(
                  _getCurrentStory()?.timeRemaining ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionAnimation() {
    return Positioned.fill(
      child: Center(
        child: AnimatedBuilder(
          animation: _reactionController,
          builder: (context, child) {
            return Transform.scale(
              scale: _reactionController.value * 3 + 1,
              child: Opacity(
                opacity: 1 - _reactionController.value,
                child: Text(
                  _reactionEmoji!,
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomActions(StoryModel story) {
    final authProvider = context.read<AuthProvider>();
    final isOwnStory = story.creator.id == authProvider.user?.id;
    
    return Positioned(
      bottom: 40,
      left: 16,
      right: 16,
      child: Row(
        children: [
          if (!isOwnStory) ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: GestureDetector(
                  onTap: _showReplyDialog,
                  child: Text(
                    'Send message',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _showReactionPicker,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ] else ...[
            // Own story - show insights
            Expanded(
              child: Text(
                '${story.viewsCount} views',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              },
              icon: Icon(
                _isEditMode ? Icons.check : Icons.edit,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPauseIndicator() {
    return const Positioned.fill(
      child: Center(
        child: Icon(
          Icons.pause_circle_filled,
          color: Colors.white,
          size: 80,
        ),
      ),
    );
  }
}