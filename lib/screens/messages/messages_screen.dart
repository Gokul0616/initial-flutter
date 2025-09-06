import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/stories_bar.dart';
import '../../widgets/story_ring.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/message_model.dart';
import '../chat/chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages', style: AppTextStyles.headline4),
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              // Start new chat
            },
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: _buildMessagesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    // Mock data - replace with actual messages
    final mockMessages = [
      {
        'user': {'username': 'sarah_jones', 'displayName': 'Sarah Jones', 'avatar': ''},
        'lastMessage': 'Hey! Love your latest video 🔥',
        'timestamp': '2m ago',
        'unread': true,
      },
      {
        'user': {'username': 'mike_creator', 'displayName': 'Mike Creator', 'avatar': ''},
        'lastMessage': 'Thanks for the collaboration!',
        'timestamp': '1h ago',
        'unread': false,
      },
      {
        'user': {'username': 'dance_queen', 'displayName': 'Dance Queen', 'avatar': ''},
        'lastMessage': 'Can you teach me that move?',
        'timestamp': '3h ago',
        'unread': true,
      },
    ];

    if (mockMessages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: AppTextStyles.headline5,
            ),
            SizedBox(height: 8),
            Text(
              'Start connecting with creators!',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: mockMessages.length,
      itemBuilder: (context, index) {
        final message = mockMessages[index];
        return _buildMessageItem(message);
      },
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final user = message['user'] as Map<String, dynamic>;
    final isUnread = message['unread'] as bool;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isUnread ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
        leading: Stack(
          children: [
            UserAvatar(
              imageUrl: user['avatar'] ?? '',
              size: 48,
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Text(
              user['username'],
              style: AppTextStyles.username.copyWith(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Text(
              message['timestamp'],
              style: AppTextStyles.timestamp.copyWith(
                color: isUnread ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            message['lastMessage'],
            style: AppTextStyles.bodySmall.copyWith(
              color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onTap: () {
          // Navigate to chat screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat feature coming soon!')),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}