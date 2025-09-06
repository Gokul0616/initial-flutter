import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StoryRing extends StatelessWidget {
  final Widget child;
  final bool hasStory;
  final bool hasUnviewed;
  final double size;

  const StoryRing({
    super.key,
    required this.child,
    this.hasStory = false,
    this.hasUnviewed = false,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasStory) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.border,
            width: 2,
          ),
        ),
        child: child,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasUnviewed
            ? AppColors.primaryGradient
            : LinearGradient(
                colors: [
                  AppColors.textSecondary.withOpacity(0.3),
                  AppColors.textSecondary.withOpacity(0.3),
                ],
              ),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.surface,
            width: 2,
          ),
        ),
        child: child,
      ),
    );
  }
}

class StoryIndicator extends StatelessWidget {
  final bool isViewed;
  final double progress;
  final Duration duration;

  const StoryIndicator({
    super.key,
    this.isViewed = false,
    this.progress = 0.0,
    this.duration = const Duration(seconds: 5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1.5),
        color: Colors.white.withOpacity(0.3),
        border: Border.all(
          color: Colors.black.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: AnimatedContainer(
        duration: duration,
        width: MediaQuery.of(context).size.width * progress,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1.5),
          color: isViewed
              ? Colors.white.withOpacity(0.5)
              : Colors.white,
        ),
      ),
    );
  }
}

class StoryProgress extends StatelessWidget {
  final int totalStories;
  final int currentStoryIndex;
  final double currentProgress;

  const StoryProgress({
    super.key,
    required this.totalStories,
    required this.currentStoryIndex,
    this.currentProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalStories, (index) {
        final isViewed = index < currentStoryIndex;
        final isCurrent = index == currentStoryIndex;
        final progress = isCurrent ? currentProgress : (isViewed ? 1.0 : 0.0);

        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 1),
            child: StoryIndicator(
              isViewed: isViewed,
              progress: progress,
            ),
          ),
        );
      }),
    );
  }
}