import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import 'video_player_widget.dart';

class VideoFeed extends StatefulWidget {
  final List<VideoModel> videos;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final String? emptyMessage;

  const VideoFeed({
    super.key,
    required this.videos,
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
    required this.onRefresh,
    this.emptyMessage,
  });

  @override
  State<VideoFeed> createState() => _VideoFeedState();
}

class _VideoFeedState extends State<VideoFeed> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty && !widget.isLoading) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Load more videos when approaching the end
          if (index >= widget.videos.length - 2 && 
              widget.hasMore && 
              !widget.isLoading) {
            widget.onLoadMore();
          }
        },
        itemCount: widget.videos.length + (widget.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.videos.length) {
            return _buildLoadingIndicator();
          }

          final video = widget.videos[index];
          final isCurrentVideo = index == _currentIndex;

          return VideoPlayerWidget(
            video: video,
            isPlaying: isCurrentVideo,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.video_library_outlined,
              size: 50,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.emptyMessage ?? AppStrings.noVideos,
            style: AppTextStyles.headline5.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage == null 
                ? AppStrings.startExploring
                : 'Follow creators to see their content here.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2,
      ),
    );
  }
}