import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/user_model.dart';
import '../../models/message_model.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/media_picker_bottom_sheet.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user;

  const ChatScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isTyping = false;
  MessageModel? _replyingTo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadMessages(widget.user.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          if (_replyingTo != null) _buildReplyPreview(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
      ),
      title: Row(
        children: [
          UserAvatar(
            imageUrl: widget.user.profilePicture,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.user.username,
                      style: AppTextStyles.username.copyWith(fontSize: 16),
                    ),
                    if (widget.user.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Text(
                  widget.user.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showChatOptions(),
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final messages = messageProvider.getConversationMessages(widget.user.id);
        final isLoading = messageProvider.isMessagesLoading(widget.user.id);
        final currentUser = context.read<AuthProvider>().user;

        if (isLoading && messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UserAvatar(
                  imageUrl: widget.user.profilePicture,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user.displayName,
                  style: AppTextStyles.headline5,
                ),
                const SizedBox(height: 8),
                Text(
                  '@${widget.user.username}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Start your conversation!',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - 1 - index];
            final isMe = message.isFromCurrentUser(currentUser?.id ?? '');
            final showAvatar = index == 0 || 
                !messages[messages.length - index].isFromCurrentUser(currentUser?.id ?? '') == isMe;

            return MessageBubble(
              message: message,
              isMe: isMe,
              showAvatar: showAvatar,
              onReply: () => _setReplyingTo(message),
              onReact: (emoji) => _reactToMessage(message.id, emoji),
            );
          },
        );
      },
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyingTo!.sender.displayName}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _replyingTo!.previewText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _replyingTo = null),
            icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: _showMediaPicker,
              icon: const Icon(Icons.add, color: AppColors.textSecondary),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Message...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (text) {
                    final isTypingNow = text.trim().isNotEmpty;
                    if (isTypingNow != _isTyping) {
                      setState(() => _isTyping = isTypingNow);
                    }
                  },
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                return GestureDetector(
                  onTap: messageProvider.sendingMessage ? null : _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isTyping && !messageProvider.sendingMessage
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: messageProvider.sendingMessage
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : Icon(
                            _isTyping ? Icons.send : Icons.mic,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final messageProvider = context.read<MessageProvider>();
    
    // Prepare reply data if replying
    Map<String, dynamic>? replyData;
    if (_replyingTo != null) {
      replyData = {
        'messageId': _replyingTo!.id,
      };
    }

    _messageController.clear();
    setState(() {
      _isTyping = false;
      _replyingTo = null;
    });

    final result = await messageProvider.sendMessage(
      recipientId: widget.user.id,
      text: text,
      replyTo: replyData,
    );

    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'])),
      );
    } else {
      // Scroll to bottom
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _setReplyingTo(MessageModel message) {
    setState(() {
      _replyingTo = message;
    });
  }

  void _reactToMessage(String messageId, String emoji) {
    // TODO: Implement message reactions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reacted with $emoji')),
    );
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MediaPickerBottomSheet(
        onMediaSelected: _sendMediaMessage,
      ),
    );
  }

  void _sendMediaMessage(List<File> files) async {
    if (files.isEmpty) return;

    final messageProvider = context.read<MessageProvider>();
    
    // TODO: Implement media message sending
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sending ${files.length} files...')),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.textSecondary),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navigate to user profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off, color: AppColors.textSecondary),
              title: const Text('Mute Notifications'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement mute functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: AppColors.error),
              title: const Text('Block User'),
              onTap: () {
                Navigator.of(context).pop();
                _showBlockConfirmation();
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Block User'),
          content: Text('Are you sure you want to block @${widget.user.username}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement block functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Blocked @${widget.user.username}')),
                );
              },
              child: const Text('Block', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}