import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/video_provider.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';
import '../../widgets/profile_options_drawer.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _user;
  bool _isCurrentUser = false;
  bool _isFollowing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
     
    if (widget.userId == null || widget.userId == authProvider.user?.username) {
      // Current user profile
      _user = authProvider.user;
    
      _isCurrentUser = true;
    } else {
      // Other user profile
      _user = await userProvider.getUserProfile(widget.userId!);
      _isCurrentUser = false;
      if (_user != null) {
        _isFollowing = authProvider.user?.following.contains(_user!.id) ?? false;
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.primaryBackground,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: context.primaryBackground,
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: Text('User not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.primaryBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 400,
            floating: false,
            pinned: true,
            backgroundColor: context.primarySurface,
            elevation: 0,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(),
            ),
            actions: [
              if (_isCurrentUser)
                IconButton(
                  onPressed: _showOptionsDrawer,
                  icon: const Icon(Icons.more_vert),
                )
              else
                IconButton(
                  onPressed: () {
                    // Share profile
                  },
                  icon: const Icon(Icons.share),
                ),
            ],
          ),
        ],
        body: Column(
          children: [
            // Tab Bar
            Container(
              color: context.primarySurface,
              child: TabBar(
                controller: _tabController,
                indicatorColor: context.colorScheme.primary,
                labelColor: context.primaryText,
                unselectedLabelColor: context.secondaryText,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
                  Tab(icon: Icon(Icons.favorite_border), text: 'Liked'),
                  Tab(icon: Icon(Icons.bookmark_border), text: 'Saved'),
                ],
              ),
            ),
            
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostsGrid(),
                  _buildLikedGrid(),
                  _buildSavedGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 60), // Status bar padding
          
          // Profile Picture and Stats
          Row(
            children: [
              // Profile Picture
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _user!.profilePictureUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: _user!.profilePictureUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: context.primarySurface,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: context.secondaryText,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: context.primarySurface,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: context.secondaryText,
                            ),
                          ),
                        )
                      : Container(
                          color: context.primarySurface,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: context.secondaryText,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('Posts', _user!.videosCount.toString()),
                    _buildStatColumn('Followers', _user!.followersText),
                    _buildStatColumn('Following', _user!.followingText),
                    _buildStatColumn('Likes', _user!.likesText),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // User Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _user!.displayName,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: context.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_user!.isVerified) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 4),
              
              Text(
                '@${_user!.username}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.secondaryText,
                ),
              ),
              
              if (_user!.bio.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _user!.bio,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.primaryText,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          if (_isCurrentUser)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primarySurface,
                      foregroundColor: context.primaryText,
                      side: BorderSide(color: context.primaryBorder),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showOptionsDrawer();
                    },
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text('Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primarySurface,
                      foregroundColor: context.primaryText,
                      side: BorderSide(color: context.primaryBorder),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing 
                          ? context.primarySurface 
                          : context.colorScheme.primary,
                      foregroundColor: _isFollowing 
                          ? context.primaryText 
                          : Colors.white,
                      side: _isFollowing 
                          ? BorderSide(color: context.primaryBorder) 
                          : null,
                    ),
                    child: Text(_isFollowing ? 'Following' : 'Follow'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to chat with this user
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primarySurface,
                      foregroundColor: context.primaryText,
                      side: BorderSide(color: context.primaryBorder),
                    ),
                    child: const Text('Message'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: context.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: context.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildPostsGrid() {
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, child) {
        // This would fetch user's videos
        return GridView.builder(
          padding: const EdgeInsets.all(1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.75,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: 12, // Placeholder
          itemBuilder: (context, index) {
            return Container(
              color: context.primarySurface,
              child: Stack(
                children: [
                  // Video thumbnail would go here
                  Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  // Video stats
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(index + 1) * 1234}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLikedGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 8, // Placeholder
      itemBuilder: (context, index) {
        return Container(
          color: context.primarySurface,
          child: Stack(
            children: [
              Container(
                color: Colors.grey[700],
                child: const Center(
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 5, // Placeholder
      itemBuilder: (context, index) {
        return Container(
          color: context.primarySurface,
          child: Stack(
            children: [
              Container(
                color: Colors.grey[600],
                child: const Center(
                  child: Icon(
                    Icons.bookmark,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOptionsDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProfileOptionsDrawer(),
    );
  }

  Future<void> _toggleFollow() async {
    if (_user == null) return;
    
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser == null) {
      // Show sign in dialog or navigate to login
      return;
    }
    
    final wasFollowing = _user!.isFollowedBy(currentUser.id);
    setState(() {
      _isFollowing = !wasFollowing;
      if (_isFollowing) {
        _user = _user!.copyWith(followersCount: _user!.followersCount + 1);
      } else {
        _user = _user!.copyWith(followersCount: _user!.followersCount - 1);
      }
    });

    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.toggleFollow(currentUser.id, _user!.id);
    } catch (e) {
      // Revert on error
      setState(() {
        _isFollowing = !_isFollowing;
        if (_isFollowing) {
          _user = _user!.copyWith(followersCount: _user!.followersCount + 1);
        } else {
          _user = _user!.copyWith(followersCount: _user!.followersCount - 1);
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}