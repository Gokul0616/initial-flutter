import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/custom_alert_dialog.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({
    super.key,
    required this.username,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _user;
  bool _isLoading = true;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    final user = await userProvider.getUserProfile(widget.username);
    
    setState(() {
      _user = user;
      _isLoading = false;
      _isCurrentUser = authProvider.user?.username == widget.username;
    });
  }

  Future<void> _toggleFollow() async {
    if (_user == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.toggleFollow(_user!.id);
    
    if (success) {
      // Refresh user profile
      await _loadUserProfile();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _user == null
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_off_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'User not found',
            style: AppTextStyles.headline5,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          pinned: true,
          title: Text(
            _user!.username,
            style: AppTextStyles.headline5,
          ),
          actions: [
            if (_isCurrentUser)
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                      break;
                    case 'logout':
                      _showLogoutDialog();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit Profile'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
              )
            else
              IconButton(
                onPressed: () {
                  // Share profile
                },
                icon: const Icon(Icons.share_outlined),
              ),
          ],
        ),

        // Profile Header
        SliverToBoxAdapter(
          child: _buildProfileHeader(),
        ),

        // Tab Bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverTabBarDelegate(
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.grid_on), text: 'Videos'),
                Tab(icon: Icon(Icons.favorite_border), text: 'Liked'),
              ],
              indicatorColor: AppColors.primary,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
            ),
          ),
        ),

        // Tab Content
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildVideosTab(),
              _buildLikedTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Picture and Stats
          Row(
            children: [
              // Profile Picture
              UserAvatar(
                imageUrl: _user!.profileImageUrl,
                size: 100,
              ),
              
              const SizedBox(width: 24),
              
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Following', _user!.followingCountText),
                    _buildStatItem('Followers', _user!.followersCountText),
                    _buildStatItem('Likes', _user!.likesCountText),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Display Name
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _user!.displayName,
              style: AppTextStyles.headline4,
            ),
          ),

          // Bio
          if (_user!.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _user!.bio,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              if (_isCurrentUser) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _user!.isFollowing == true
                          ? AppColors.surfaceVariant
                          : AppColors.primary,
                      foregroundColor: _user!.isFollowing == true
                          ? AppColors.textPrimary
                          : Colors.white,
                    ),
                    child: Text(
                      _user!.isFollowing == true ? 'Following' : 'Follow',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    // Send message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message feature coming soon!')),
                    );
                  },
                  child: const Icon(Icons.message_outlined),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: AppTextStyles.headline4,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVideosTab() {
    // Mock video grid - replace with actual user videos
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 12, // Mock count
      itemBuilder: (context, index) {
        return Container(
          color: AppColors.surfaceVariant,
          child: Stack(
            children: [
              // Video thumbnail would go here
              const Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              // View count
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${(index + 1) * 123}K',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLikedTab() {
    if (_isCurrentUser) {
      return _buildVideosTab(); // Show liked videos for current user
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Private',
              style: AppTextStyles.headline5,
            ),
            SizedBox(height: 8),
            Text(
              'This user\'s liked videos are private',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}