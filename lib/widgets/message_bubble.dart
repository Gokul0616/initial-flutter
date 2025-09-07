import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message_model.dart';
import '../utils/theme.dart';
import '../widgets/user_avatar.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;
  final VoidCallback? onReply;
  final Function(String)? onReact;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    this.onReply,
    this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe && showAvatar) ...[
              UserAvatar(
                imageUrl: message.sender.profilePicture,
                size: 28,
              ),
              const SizedBox(width: 8),
            ],
            if (!isMe && !showAvatar)
              const SizedBox(width: 36),
            
            Flexible(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Reply preview
                  if (message.replyTo != null) _buildReplyPreview(),
                  
                  // Main message content
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMe ? 20 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 20),
                      ),
                    ),
                    child: _buildMessageContent(),
                  ),
                  
                  // Message reactions
                  if (message.hasReactions) _buildReactions(),
                  
                  // Message info
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timeAgo,
                        style: AppTextStyles.timestamp.copyWith(fontSize: 10),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color: message.isRead ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            if (isMe && showAvatar) ...[
              const SizedBox(width: 8),
              UserAvatar(
                imageUrl: message.sender.profilePicture,
                size: 28,
              ),
            ],
            if (isMe && !showAvatar)
              const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    if (message.isText) {
      return Text(
        message.text,
        style: TextStyle(
          color: isMe ? Colors.white : AppColors.textPrimary,
          fontSize: 16,
        ),
      );
    } else if (message.isImage && message.media != null) {
      return _buildImageMessage();
    } else if (message.isVideo && message.media != null) {
      return _buildVideoMessage();
    } else if (message.isMediaGroup && message.mediaGroup.isNotEmpty) {
      return _buildMediaGroupMessage();
    } else if (message.isStoryReply && message.storyReply != null) {
      return _buildStoryReplyMessage();
    }

    return Text(
      'Unsupported message type',
      style: TextStyle(
        color: isMe ? Colors.white70 : AppColors.textSecondary,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildImageMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            message.media!.fullUrl,
            width: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 250,
                height: 150,
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image, color: Colors.white),
              );
            },
          ),
        ),
        if (message.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message.text,
            style: TextStyle(
              color: isMe ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 250,
                height: 150,
                color: Colors.black,
                child: message.media!.fullThumbnailUrl.isNotEmpty
                    ? Image.network(
                        message.media!.fullThumbnailUrl,
                        width: 250,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Icon(Icons.play_circle_outline, color: Colors.white, size: 48),
                      ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black26,
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_filled, color: Colors.white, size: 48),
                ),
              ),
            ),
            if (message.media!.duration != null)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(message.media!.duration!),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
        if (message.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message.text,
            style: TextStyle(
              color: isMe ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMediaGroupMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.mediaGroup.length == 1)
          _buildSingleMedia(message.mediaGroup.first)
        else
          _buildMediaGrid(),
        if (message.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message.text,
            style: TextStyle(
              color: isMe ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSingleMedia(MessageMedia media) {
    if (media.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          media.fullUrl,
          width: 250,
          fit: BoxFit.cover,
        ),
      );
    } else if (media.isVideo) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 250,
              height: 150,
              color: Colors.black,
              child: media.fullThumbnailUrl.isNotEmpty
                  ? Image.network(media.fullThumbnailUrl, fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.play_circle_outline, color: Colors.white)),
            ),
          ),
          const Positioned.fill(
            child: Center(
              child: Icon(Icons.play_circle_filled, color: Colors.white, size: 48),
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildMediaGrid() {
    final mediaCount = message.mediaGroup.length;
    
    if (mediaCount == 2) {
      return Row(
        children: message.mediaGroup.take(2).map((media) => 
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 2),
              child: _buildGridItem(media, 120),
            ),
          )
        ).toList(),
      );
    } else if (mediaCount == 3) {
      return Column(
        children: [
          _buildGridItem(message.mediaGroup[0], 120),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(child: _buildGridItem(message.mediaGroup[1], 60)),
              const SizedBox(width: 2),
              Expanded(child: _buildGridItem(message.mediaGroup[2], 60)),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildGridItem(message.mediaGroup[0], 60)),
              const SizedBox(width: 2),
              Expanded(child: _buildGridItem(message.mediaGroup[1], 60)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(child: _buildGridItem(message.mediaGroup[2], 60)),
              const SizedBox(width: 2),
              Expanded(
                child: Stack(
                  children: [
                    _buildGridItem(message.mediaGroup[3], 60),
                    if (mediaCount > 4)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '+${mediaCount - 4}',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildGridItem(MessageMedia media, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: height,
        child: media.isImage
            ? Image.network(media.fullUrl, fit: BoxFit.cover)
            : Stack(
                children: [
                  Container(
                    color: Colors.black,
                    child: media.fullThumbnailUrl.isNotEmpty
                        ? Image.network(media.fullThumbnailUrl, fit: BoxFit.cover)
                        : const Center(child: Icon(Icons.videocam, color: Colors.white)),
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Icon(Icons.play_circle_filled, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStoryReplyMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isMe ? Colors.white : AppColors.surface).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (message.storyReply!.storyMediaUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    message.storyReply!.storyMediaUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Story reply',
                      style: TextStyle(
                        color: isMe ? Colors.white70 : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (message.storyReply!.storyText.isNotEmpty)
                      Text(
                        message.storyReply!.storyText,
                        style: TextStyle(
                          color: isMe ? Colors.white : AppColors.textPrimary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (message.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message.text,
            style: TextStyle(
              color: isMe ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (isMe ? Colors.white : AppColors.surface).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white : AppColors.primary,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.replyTo!.senderName,
            style: TextStyle(
              color: isMe ? Colors.white : AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            message.replyTo!.text,
            style: TextStyle(
              color: isMe ? Colors.white70 : AppColors.textSecondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReactions() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: message.reactions.map((reaction) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              reaction.emoji,
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showMessageOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    
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
            if (!isMe)
              ListTile(
                leading: const Icon(Icons.reply, color: AppColors.textSecondary),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.of(context).pop();
                  onReply?.call();
                },
              ),
            ListTile(
              leading: const Icon(Icons.add_reaction_outlined, color: AppColors.textSecondary),
              title: const Text('Add Reaction'),
              onTap: () {
                Navigator.of(context).pop();
                _showReactionPicker(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: AppColors.textSecondary),
              title: const Text('Copy'),
              onTap: () {
                Navigator.of(context).pop();
                Clipboard.setData(ClipboardData(text: message.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied')),
                );
              },
            ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmation(context);
                },
              ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _showReactionPicker(BuildContext context) {
    final reactions = ['❤️', '😂', '😮', '😢', '😡', '👍', '👎', '🔥'];
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('React to message', style: AppTextStyles.headline5),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: reactions.map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        onReact?.call(emoji);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement delete message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message deleted')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}