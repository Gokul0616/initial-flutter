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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadConversations();
    });
  }

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
              // Start new chat - show user search
              _showNewChatDialog();
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stories Bar
          const StoriesBar(),
          
          // Divider
          Container(
            height: 1,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          
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
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
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
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final conversations = messageProvider.conversations;
        final isLoading = messageProvider.conversationsLoading;

        if (isLoading && conversations.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (conversations.isEmpty) {
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

        return RefreshIndicator(
          onRefresh: () => messageProvider.loadConversations(refresh: true),
          color: AppColors.primary,
          child: ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _buildMessageItem(conversation);
            },
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(ConversationModel conversation) {
    final isUnread = conversation.hasUnreadMessages;
    final currentUser = context.read<AuthProvider>().user;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(user: conversation.user),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnread ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnread ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              // Profile Picture with Story Ring
              Stack(
                children: [
                  StoryRing(
                    hasStory: conversation.hasStory,
                    hasUnviewed: conversation.hasStory,
                    size: 56,
                    child: ClipOval(
                      child: conversation.hasStory && conversation.latestStory != null
                          ? _buildStoryPreview(conversation.latestStory!)
                          : UserAvatar(
                              imageUrl: conversation.user.profilePicture,
                              size: 52,
                            ),
                    ),
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
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 12),
              
              // Message Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                conversation.user.username,
                                style: AppTextStyles.username.copyWith(
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              if (conversation.user.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: AppColors.primary,
                                  size: 14,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              conversation.lastMessage.shortTimeAgo,
                              style: AppTextStyles.timestamp.copyWith(
                                color: isUnread ? AppColors.primary : AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                            if (isUnread && conversation.unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  conversation.unreadCountText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (conversation.lastMessage.sender.id == currentUser?.id)
                          Icon(
                            conversation.lastMessage.isRead ? Icons.done_all : Icons.done,
                            size: 16,
                            color: conversation.lastMessage.isRead ? AppColors.primary : AppColors.textSecondary,
                          ),
                        if (conversation.lastMessage.sender.id == currentUser?.id)
                          const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            conversation.lastMessage.previewText,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryPreview(Map<String, dynamic> story) {
    final mediaUrl = story['mediaUrl'] ?? '';
    final text = story['text'] ?? '';
    final backgroundColor = story['backgroundColor'] ?? '#000000';
    final textColor = story['textColor'] ?? '#FFFFFF';

    if (mediaUrl.isNotEmpty) {
      return Image.network(
        mediaUrl.startsWith('http') ? mediaUrl : 'http://localhost:3001$mediaUrl',
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 52,
            height: 52,
            color: Colors.grey[800],
            child: const Icon(Icons.error, color: Colors.white, size: 20),
          );
        },
      );
    } else if (text.isNotEmpty) {
      return Container(
        width: 52,
        height: 52,
        color: Color(int.parse(backgroundColor.replaceFirst('#', '0xff'))),
        child: Center(
          child: Text(
            text.length > 10 ? '${text.substring(0, 10)}...' : text,
            style: TextStyle(
              color: Color(int.parse(textColor.replaceFirst('#', '0xff'))),
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return UserAvatar(
      imageUrl: '',
      size: 52,
    );
  }

  void _showNewChatDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'New Message',
                style: AppTextStyles.headline5,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Expanded(
                child: Center(
                  child: Text(
                    'Search for users to start a conversation',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}