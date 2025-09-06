import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/story_model.dart';
import '../../providers/story_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/story_ring.dart';
import 'dart:async';

class StoryViewerScreen extends StatefulWidget {
  final int initialGroupIndex;
  final List<StoryGroup> storyGroups;
  final List<StoryModel> myStories;

  const StoryViewerScreen({
    super.key,
    required this.initialGroupIndex,
    required this.storyGroups,
    this.myStories = const [],
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late PageController _pageController;
  Timer? _storyTimer;
  double _progress = 0.0;
  int _currentGroupIndex = 0;
  int _currentStoryIndex = 0;
  bool _isViewingMyStories = false;

  @override
  void initState() {
    super.initState();
    _currentGroupIndex = widget.initialGroupIndex;
    _isViewingMyStories = widget.initialGroupIndex == -1;
    _pageController = PageController(initialPage: _isViewingMyStories ? 0 : widget.initialGroupIndex);
    _startStoryTimer();
  }

  @override
  void dispose() {
    _storyTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startStoryTimer() {
    _storyTimer?.cancel();
    _progress = 0.0;
    
    _storyTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.01; // 5 seconds total (100 * 50ms)
      });
      
      if (_progress >= 1.0) {
        _nextStory();
      }
    });
  }

  void _nextStory() {
    _storyTimer?.cancel();
    
    if (_isViewingMyStories) {
      if (_currentStoryIndex < widget.myStories.length - 1) {
        setState(() {
          _currentStoryIndex++;
        });
        _startStoryTimer();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      final currentGroup = widget.storyGroups[_currentGroupIndex];
      if (_currentStoryIndex < currentGroup.stories.length - 1) {
        setState(() {
          _currentStoryIndex++;
        });
        _startStoryTimer();
      } else if (_currentGroupIndex < widget.storyGroups.length - 1) {
        setState(() {
          _currentGroupIndex++;
          _currentStoryIndex = 0;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startStoryTimer();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _previousStory() {
    _storyTimer?.cancel();
    
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _startStoryTimer();
    } else if (!_isViewingMyStories && _currentGroupIndex > 0) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          _storyTimer?.cancel();
        },
        onTapUp: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < screenWidth / 2) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: _isViewingMyStories
            ? _buildMyStoryView()
            : PageView.builder(
                controller: _pageController,
                itemCount: widget.storyGroups.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentGroupIndex = index;
                    _currentStoryIndex = 0;
                  });
                  _startStoryTimer();
                },
                itemBuilder: (context, index) {
                  return _buildStoryGroupView(widget.storyGroups[index]);
                },
              ),
      ),
    );
  }

  Widget _buildMyStoryView() {
    if (widget.myStories.isEmpty) {
      return const Center(
        child: Text(
          'No stories to show',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final story = widget.myStories[_currentStoryIndex];
    return _buildStoryView(story, isMyStory: true);
  }

  Widget _buildStoryGroupView(StoryGroup storyGroup) {
    if (storyGroup.stories.isEmpty) {
      return const Center(
        child: Text(
          'No stories to show',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final story = storyGroup.stories[_currentStoryIndex];
    
    // Mark story as viewed
    context.read<StoryProvider>().viewStory(story.id);
    
    return _buildStoryView(story);
  }

  Widget _buildStoryView(StoryModel story, {bool isMyStory = false}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Story Content
        if (story.isText)
          Container(
            color: Color(int.parse(story.backgroundColor.replaceFirst('#', '0xff'))),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  story.text,
                  style: TextStyle(
                    color: Color(int.parse(story.textColor.replaceFirst('#', '0xff'))),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else if (story.mediaUrl.isNotEmpty)
          Image.network(
            story.mediaUrlFull,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.error, color: Colors.white, size: 48),
                ),
              );
            },
          ),

        // Top Gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black54,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Progress Indicators
        Positioned(
          top: 50,
          left: 12,
          right: 12,
          child: StoryProgress(
            totalStories: isMyStory ? widget.myStories.length : story.creator.id == story.creator.id ? 1 : 1,
            currentStoryIndex: _currentStoryIndex,
            currentProgress: _progress,
          ),
        ),

        // User Info
        Positioned(
          top: 70,
          left: 16,
          right: 16,
          child: Row(
            children: [
              UserAvatar(
                imageUrl: story.creator.profilePicture,
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
                          story.creator.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (story.creator.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      story.timeRemaining.isEmpty ? story.timeAgo : story.timeRemaining,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMyStory) ...[
                IconButton(
                  onPressed: () => _showStoryOptions(story),
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ],
          ),
        ),

        // Story Actions (for others' stories)
        if (!isMyStory)
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.favorite_border,
                  onTap: () => _reactToStory(story.id, '❤️'),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.send,
                  onTap: () => _replyToStory(story),
                ),
              ],
            ),
          ),

        // Reply Bar (for others' stories)
        if (!isMyStory)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  UserAvatar(
                    imageUrl: context.read<AuthProvider>().user?.profilePicture ?? '',
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Send message',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const Icon(Icons.send, color: Colors.white70, size: 20),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  void _reactToStory(String storyId, String emoji) {
    context.read<StoryProvider>().reactToStory(storyId, emoji);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reacted with $emoji'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.black87,
      ),
    );
  }

  void _replyToStory(StoryModel story) {
    // Navigate to chat with story reply
    Navigator.of(context).pop();
    // TODO: Navigate to chat screen with story reply data
  }

  void _showStoryOptions(StoryModel story) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.star_outline, color: AppColors.accent),
              title: const Text('Add to Highlights'),
              onTap: () {
                Navigator.of(context).pop();
                _addToHighlights(story);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility, color: AppColors.textSecondary),
              title: const Text('View Story Insights'),
              onTap: () {
                Navigator.of(context).pop();
                _showStoryInsights(story);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Story'),
              onTap: () {
                Navigator.of(context).pop();
                _deleteStory(story);
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _addToHighlights(StoryModel story) {
    // Show dialog to enter highlight title
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Add to Highlights'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Highlight title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  final success = await context.read<StoryProvider>().addToHighlights(story.id, title);
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Added to highlights' : 'Failed to add to highlights'),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showStoryInsights(StoryModel story) {
    context.read<StoryProvider>().loadStoryViewers(story.id);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Consumer<StoryProvider>(
            builder: (context, storyProvider, child) {
              final viewers = storyProvider.storyViewers;
              
              return Column(
                children: [
                  Text(
                    '${story.viewsCount} views',
                    style: AppTextStyles.headline5,
                  ),
                  const SizedBox(height: 16),
                  if (storyProvider.viewersLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: viewers.length,
                        itemBuilder: (context, index) {
                          final viewer = viewers[index];
                          final user = viewer['user'];
                          return ListTile(
                            leading: UserAvatar(
                              imageUrl: user['profilePicture'] ?? '',
                              size: 40,
                            ),
                            title: Text(user['username'] ?? ''),
                            subtitle: Text(viewer['viewedAt'] ?? ''),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _deleteStory(StoryModel story) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Delete Story'),
          content: const Text('Are you sure you want to delete this story?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final success = await context.read<StoryProvider>().deleteStory(story.id);
                Navigator.of(context).pop();
                
                if (success) {
                  Navigator.of(context).pop(); // Close story viewer
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Story deleted')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete story')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}