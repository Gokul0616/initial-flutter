import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/user_avatar.dart';
import '../profile/profile_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  late TabController _tabController;
  final List<String> _tabs = ['Users', 'Sounds', 'Hashtags'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  void _onSearchChanged(String query) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (query.trim().isEmpty) {
      userProvider.clearSearchResults();
    } else {
      userProvider.searchUsers(query);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  CustomTextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: 'Search users, sounds, hashtags...',
                    prefixIcon: Icons.search,
                    onChanged: _onSearchChanged,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUsersTab(),
                  _buildSoundsTab(),
                  _buildHashtagsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (_searchController.text.isEmpty) {
          return _buildDiscoverSuggestions();
        }

        if (userProvider.searchLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (userProvider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No users found',
                  style: AppTextStyles.headline5,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching with a different keyword',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: userProvider.searchResults.length,
          itemBuilder: (context, index) {
            final user = userProvider.searchResults[index];
            return _buildUserItem(user);
          },
        );
      },
    );
  }

  Widget _buildDiscoverSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Categories',
            style: AppTextStyles.headline5,
          ),
          const SizedBox(height: 16),
          
          // Trending Categories Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildCategoryCard('🎵', 'Music', '#FF6B6B'),
              _buildCategoryCard('💃', 'Dance', '#4ECDC4'),
              _buildCategoryCard('😂', 'Comedy', '#FFE66D'),
              _buildCategoryCard('🍳', 'Food', '#FF8B94'),
              _buildCategoryCard('✈️', 'Travel', '#95E1D3'),
              _buildCategoryCard('🎨', 'Art', '#A8E6CF'),
            ],
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Popular Hashtags',
            style: AppTextStyles.headline5,
          ),
          const SizedBox(height: 16),
          
          // Popular Hashtags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              '#fyp',
              '#viral',
              '#trending',
              '#dance',
              '#music',
              '#comedy',
              '#food',
              '#travel',
              '#art',
              '#lifestyle',
            ].map((hashtag) => _buildHashtagChip(hashtag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String emoji, String title, String colorHex) {
    final color = Color(int.parse('FF${colorHex.substring(1)}', radix: 16));
    
    return GestureDetector(
      onTap: () {
        _searchController.text = title.toLowerCase();
        _onSearchChanged(title.toLowerCase());
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashtagChip(String hashtag) {
    return GestureDetector(
      onTap: () {
        _searchController.text = hashtag;
        _onSearchChanged(hashtag);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          hashtag,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildUserItem(user) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(username: user.username),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            UserAvatar(
              imageUrl: user.profileImageUrl,
              size: 48,
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
                        style: AppTextStyles.username,
                      ),
                      if (user.isVerified) ...[
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
                    user.displayName,
                    style: AppTextStyles.displayName,
                  ),
                  if (user.bio.isNotEmpty)
                    Text(
                      user.bio,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  user.followersCountText,
                  style: AppTextStyles.counter,
                ),
                const Text(
                  'followers',
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'Sounds Coming Soon',
            style: AppTextStyles.headline5,
          ),
          SizedBox(height: 8),
          Text(
            'Search for trending sounds and music',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHashtagsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tag,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'Hashtags Coming Soon',
            style: AppTextStyles.headline5,
          ),
          SizedBox(height: 8),
          Text(
            'Discover trending hashtags and challenges',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}