import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_model.dart';
import '../providers/story_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/user_avatar.dart';
import '../screens/stories/story_viewer_screen.dart';
import '../screens/stories/story_creator_screen.dart';

class StoriesBar extends StatefulWidget {
  const StoriesBar({super.key});

  @override
  State<StoriesBar> createState() => _StoriesBarState();
}

class _StoriesBarState extends State<StoriesBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoryProvider>().loadFollowingStories();
      context.read<StoryProvider>().loadMyStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StoryProvider, AuthProvider>(
      builder: (context, storyProvider, authProvider, child) {
        final storyGroups = storyProvider.storyGroups;
        final myStories = storyProvider.myStories;
        final isLoading = storyProvider.storiesLoading;

        if (isLoading && storyGroups.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 1 + storyGroups.length, // +1 for "Your Story"
            itemBuilder: (context, index) {
              if (index == 0) {
                // Your Story item
                return _buildYourStoryItem(
                  context,
                  authProvider.user,
                  myStories,
                );
              }
              
              final storyGroup = storyGroups[index - 1];
              return _buildStoryItem(
                context,
                storyGroup,
                index - 1,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildYourStoryItem(
    BuildContext context,
    dynamic user,
    List<StoryModel> myStories,
  ) {
    final hasStories = myStories.isNotEmpty;
    
    return GestureDetector(
      onTap: () {
        if (hasStories) {
          // View my stories
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StoryViewerScreen(
                initialGroupIndex: -1, // -1 indicates my stories
                storyGroups: const [],
                myStories: myStories,
              ),
            ),
          );
        } else {
          // Create new story
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const StoryCreatorScreen(),
            ),
          );
        }
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasStories ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: UserAvatar(
                      imageUrl: user?.profilePicture ?? '',
                      size: 56,
                    ),
                  ),
                ),
                if (!hasStories)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2.0),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              hasStories ? 'Your Story' : 'Add Story',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(
    BuildContext context,
    StoryGroup storyGroup,
    int groupIndex,
  ) {
    final hasUnviewed = storyGroup.hasUnviewed;
    final latestStory = storyGroup.latestStoryModel;
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StoryViewerScreen(
              initialGroupIndex: groupIndex,
              storyGroups: context.read<StoryProvider>().storyGroups,
              myStories: const [],
            ),
          ),
        );
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasUnviewed
                        ? AppColors.primaryGradient
                        : null,
                    border: !hasUnviewed
                        ? Border.all(color: AppColors.border, width: 2)
                        : null,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: ClipOval(
                      child: latestStory != null && latestStory.mediaUrl.isNotEmpty
                          ? Image.network(
                              latestStory.mediaUrlFull,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return UserAvatar(
                                  imageUrl: storyGroup.user.profilePicture,
                                  size: 56,
                                );
                              },
                            )
                          : latestStory != null && latestStory.isText
                              ? Container(
                                  width: 56,
                                  height: 56,
                                  color: Color(int.parse(
                                    latestStory.backgroundColor.replaceFirst('#', '0xff'),
                                  )),
                                  child: Center(
                                    child: Text(
                                      latestStory.text.length > 20
                                          ? '${latestStory.text.substring(0, 20)}...'
                                          : latestStory.text,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Color(int.parse(
                                          latestStory.textColor.replaceFirst('#', '0xff'),
                                        )),
                                        fontSize: 8,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                              : UserAvatar(
                                  imageUrl: storyGroup.user.profilePicture,
                                  size: 56,
                                ),
                    ),
                  ),
                ),
                if (hasUnviewed && storyGroup.unviewedCount > 1)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        storyGroup.unviewedCount.toString(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              storyGroup.user.username,
              style: AppTextStyles.labelSmall.copyWith(
                color: hasUnviewed ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: hasUnviewed ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}