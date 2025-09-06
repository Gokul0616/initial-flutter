import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/comment_model.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/user_avatar.dart';

class CommentsScreen extends StatefulWidget {
  final String videoId;

  const CommentsScreen({
    super.key,
    required this.videoId,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String? _replyingToCommentId;
  String? _replyingToUsername;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComments();
    });
  }

  void _loadComments() {
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);
    commentProvider.loadVideoComments(widget.videoId, refresh: true);
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final commentProvider = Provider.of<CommentProvider>(context, listen: false);
    
    final result = await commentProvider.addComment(
      videoId: widget.videoId,
      text: _commentController.text.trim(),
      parentCommentId: _replyingToCommentId,
    );

    if (result['success']) {
      _commentController.clear();
      _clearReply();
      _commentFocusNode.unfocus();
    } else {
      _showError(result['error']);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _replyToComment(CommentModel comment) {
    setState(() {
      _replyingToCommentId = comment.id;
      _replyingToUsername = comment.user.username;
    });
    _commentFocusNode.requestFocus();
  }

  void _clearReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Comments',
                  style: AppTextStyles.headline5,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: Consumer<CommentProvider>(
              builder: (context, commentProvider, child) {
                final comments = commentProvider.getVideoComments(widget.videoId);
                final isLoading = commentProvider.isCommentsLoading(widget.videoId);

                if (isLoading && comments.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No comments yet',
                          style: AppTextStyles.headline5,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to comment!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return _buildCommentItem(comment, commentProvider);
                  },
                );
              },
            ),
          ),

          // Reply indicator
          if (_replyingToUsername != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Replying to @$_replyingToUsername',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _clearReply,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Comment Input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Row(
                  children: [
                    UserAvatar(
                      imageUrl: authProvider.user?.profileImageUrl ?? '',
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        hintText: _replyingToUsername != null 
                            ? 'Reply to @$_replyingToUsername...'
                            : 'Add a comment...',
                        maxLines: 3,
                        maxLength: AppConstants.maxCommentLength,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _addComment(),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Consumer<CommentProvider>(
                      builder: (context, commentProvider, child) {
                        final canSend = _commentController.text.trim().isNotEmpty &&
                            !commentProvider.addingComment;
                        
                        return GestureDetector(
                          onTap: canSend ? _addComment : null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: canSend ? AppColors.primary : AppColors.textSecondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: commentProvider.addingComment
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, CommentProvider commentProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            imageUrl: comment.user.profileImageUrl,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info and timestamp
                Row(
                  children: [
                    Text(
                      comment.user.username,
                      style: AppTextStyles.username.copyWith(fontSize: 14),
                    ),
                    if (comment.user.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: AppColors.secondary,
                        size: 12,
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: AppTextStyles.timestamp,
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Comment text
                Text(
                  comment.text,
                  style: AppTextStyles.bodyMedium,
                ),
                
                const SizedBox(height: 8),
                
                // Actions
                Row(
                  children: [
                    // Like button
                    GestureDetector(
                      onTap: () => commentProvider.toggleCommentLike(comment.id),
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: comment.isLiked ? AppColors.like : AppColors.textSecondary,
                          ),
                          if (comment.likesCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              comment.likesCountText,
                              style: AppTextStyles.labelSmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Reply button
                    GestureDetector(
                      onTap: () => _replyToComment(comment),
                      child: Text(
                        'Reply',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Replies
                if (comment.repliesCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildRepliesSection(comment, commentProvider),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesSection(CommentModel comment, CommentProvider commentProvider) {
    final replies = commentProvider.getCommentReplies(comment.id);
    final isLoadingReplies = commentProvider.isRepliesLoading(comment.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // View replies button
        if (replies.isEmpty && !isLoadingReplies)
          GestureDetector(
            onTap: () => commentProvider.loadCommentReplies(comment.id),
            child: Text(
              'View ${comment.repliesCount} ${comment.repliesCount == 1 ? 'reply' : 'replies'}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

        // Loading indicator
        if (isLoadingReplies)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),

        // Replies list
        ...replies.map((reply) => Container(
          margin: const EdgeInsets.only(top: 8, left: 16),
          child: _buildReplyItem(reply, commentProvider),
        )),
      ],
    );
  }

  Widget _buildReplyItem(CommentModel reply, CommentProvider commentProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(
          imageUrl: reply.user.profileImageUrl,
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    reply.user.username,
                    style: AppTextStyles.username.copyWith(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    reply.timeAgo,
                    style: AppTextStyles.timestamp.copyWith(fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                reply.text,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => commentProvider.toggleCommentLike(reply.id),
                child: Row(
                  children: [
                    Icon(
                      reply.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 12,
                      color: reply.isLiked ? AppColors.like : AppColors.textSecondary,
                    ),
                    if (reply.likesCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        reply.likesCountText,
                        style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}