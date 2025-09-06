import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/socket_provider.dart';
import '../../utils/theme.dart';
import '../home/home_screen.dart';
import '../discover/discover_screen.dart';
import '../camera/camera_screen.dart';
import '../messages/messages_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeSocket();
  }

  void _initializeSocket() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      socketProvider.connect(authProvider.user!.id);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.disconnect();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // Camera tab - navigate to camera screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );
      return;
    }
    
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index > 2 ? index - 1 : index, // Adjust for camera tab
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index >= 2 ? index + 1 : index;
          });
        },
        children: [
          const HomeScreen(),
          const DiscoverScreen(),
          const MessagesScreen(),
          ProfileScreen(username: authProvider.user?.username ?? ''),
        ],
      ),
      bottomNavigationBar: Container(
        height: AppDimensions.bottomNavHeight,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, 'Home'),
            _buildNavItem(1, Icons.search, 'Discover'),
            _buildCameraButton(),
            _buildNavItem(3, Icons.message_outlined, 'Inbox'),
            _buildNavItem(4, Icons.person_outline, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimensions.bottomNavIconSize,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: () => _onTabTapped(2),
      child: Container(
        width: 48,
        height: 32,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}