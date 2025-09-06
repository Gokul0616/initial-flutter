import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/video_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/video_feed.dart';
import '../../widgets/custom_tab_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  final List<String> _tabs = ['For You', 'Following', 'Trending'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _pageController = PageController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialVideos();
    });
  }

  void _loadInitialVideos() {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    videoProvider.loadFeedVideos(refresh: true);
    videoProvider.loadTrendingVideos(refresh: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Video Feed
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              _tabController.animateTo(index);
            },
            children: [
              // For You Tab
              Consumer<VideoProvider>(
                builder: (context, videoProvider, child) {
                  return VideoFeed(
                    videos: videoProvider.feedVideos,
                    isLoading: videoProvider.feedLoading,
                    hasMore: videoProvider.feedHasMore,
                    onLoadMore: () => videoProvider.loadFeedVideos(),
                    onRefresh: () => videoProvider.loadFeedVideos(refresh: true),
                  );
                },
              ),
              
              // Following Tab
              Consumer<VideoProvider>(
                builder: (context, videoProvider, child) {
                  // Filter videos from followed users
                  final followingVideos = videoProvider.feedVideos
                      .where((video) => video.user.isFollowing == true)
                      .toList();
                      
                  return VideoFeed(
                    videos: followingVideos,
                    isLoading: videoProvider.feedLoading,
                    hasMore: false,
                    onLoadMore: () {},
                    onRefresh: () => videoProvider.loadFeedVideos(refresh: true),
                    emptyMessage: "You're not following anyone yet.\nFind people to follow!",
                  );
                },
              ),
              
              // Trending Tab
              Consumer<VideoProvider>(
                builder: (context, videoProvider, child) {
                  return VideoFeed(
                    videos: videoProvider.trendingVideos,
                    isLoading: videoProvider.trendingLoading,
                    hasMore: videoProvider.trendingHasMore,
                    onLoadMore: () => videoProvider.loadTrendingVideos(),
                    onRefresh: () => videoProvider.loadTrendingVideos(refresh: true),
                  );
                },
              ),
            ],
          ),

          // Top Tab Bar
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: CustomTabBar(
                controller: _tabController,
                tabs: _tabs,
                onTap: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),

          // Live Indicator (when live streams are available)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            child: _buildLiveIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    // This would be shown when there are live streams
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}