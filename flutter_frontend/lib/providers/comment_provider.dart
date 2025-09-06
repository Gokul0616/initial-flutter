import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/comment_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class CommentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Comments by video ID
  Map<String, List<CommentModel>> _videoComments = {};
  Map<String, bool> _videoCommentsLoading = {};
  Map<String, bool> _videoCommentsHasMore = {};
  
  // Replies by comment ID
  Map<String, List<CommentModel>> _commentReplies = {};
  Map<String, bool> _commentRepliesLoading = {};
  
  // Adding comment state
  bool _addingComment = false;

  // Getters
  Map<String, List<CommentModel>> get videoComments => _videoComments;
  Map<String, List<CommentModel>> get commentReplies => _commentReplies;
  bool get addingComment => _addingComment;

  bool isCommentsLoading(String videoId) => _videoCommentsLoading[videoId] ?? false;
  bool hasMoreComments(String videoId) => _videoCommentsHasMore[videoId] ?? true;
  bool isRepliesLoading(String commentId) => _commentRepliesLoading[commentId] ?? false;

  List<CommentModel> getVideoComments(String videoId) {
    return _videoComments[videoId] ?? [];
  }

  List<CommentModel> getCommentReplies(String commentId) {
    return _commentReplies[commentId] ?? [];
  }

  // Load comments for a video
  Future<void> loadVideoComments(String videoId, {bool refresh = false}) async {
    if (_videoCommentsLoading[videoId] == true) return;
    
    if (refresh) {
      _videoComments[videoId] = [];
      _videoCommentsHasMore[videoId] = true;
    }
    
    if (_videoCommentsHasMore[videoId] != true) return;
    
    _videoCommentsLoading[videoId] = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/comments/video/$videoId', queryParameters: {
        'page': 1,
        'limit': AppConstants.commentsPageSize,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> commentsJson = data['comments'];
        final List<CommentModel> newComments = commentsJson
            .map((json) => CommentModel.fromMap(json))
            .toList();
        
        if (refresh) {
          _videoComments[videoId] = newComments;
        } else {
          _videoComments[videoId] = [...(_videoComments[videoId] ?? []), ...newComments];
        }
        
        _videoCommentsHasMore[videoId] = data['hasMore'] ?? false;
      }
    } on DioException catch (e) {
      debugPrint('Error loading comments: ${e.message}');
    } catch (e) {
      debugPrint('Error loading comments: $e');
    }
    
    _videoCommentsLoading[videoId] = false;
    notifyListeners();
  }

  // Add comment to video
  Future<Map<String, dynamic>> addComment({
    required String videoId,
    required String text,
    String? parentCommentId,
  }) async {
    if (text.trim().isEmpty) {
      return {'success': false, 'error': 'Comment cannot be empty'};
    }

    _addingComment = true;
    notifyListeners();
    
    try {
      final response = await _apiService.post('/comments/video/$videoId', data: {
        'text': text.trim(),
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      });
      
      if (response.statusCode == 201) {
        final data = response.data;
        final newComment = CommentModel.fromMap(data['comment']);
        
        if (parentCommentId != null) {
          // Add to replies
          _commentReplies[parentCommentId] = [
            ..._commentReplies[parentCommentId] ?? [],
            newComment
          ];
          
          // Update parent comment replies count
          final parentIndex = _videoComments[videoId]?.indexWhere(
            (comment) => comment.id == parentCommentId
          );
          if (parentIndex != null && parentIndex >= 0) {
            final parentComment = _videoComments[videoId]![parentIndex];
            _videoComments[videoId]![parentIndex] = parentComment.copyWith(
              repliesCount: parentComment.repliesCount + 1,
            );
          }
        } else {
          // Add to video comments
          _videoComments[videoId] = [newComment, ..._videoComments[videoId] ?? []];
        }
        
        _addingComment = false;
        notifyListeners();
        
        return {'success': true, 'message': data['message'], 'comment': newComment};
      } else {
        _addingComment = false;
        notifyListeners();
        return {'success': false, 'error': response.data['error']};
      }
    } on DioException catch (e) {
      _addingComment = false;
      notifyListeners();
      
      if (e.response?.statusCode == 400) {
        return {'success': false, 'error': e.response?.data['error'] ?? 'Comment failed'};
      }
      return {'success': false, 'error': AppConstants.commentError};
    } catch (e) {
      _addingComment = false;
      notifyListeners();
      return {'success': false, 'error': AppConstants.commentError};
    }
  }

  // Load replies for a comment
  Future<void> loadCommentReplies(String commentId, {bool refresh = false}) async {
    if (_commentRepliesLoading[commentId] == true) return;
    
    if (refresh) {
      _commentReplies[commentId] = [];
    }
    
    _commentRepliesLoading[commentId] = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/comments/$commentId/replies', queryParameters: {
        'page': 1,
        'limit': 10,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> repliesJson = data['replies'];
        final List<CommentModel> newReplies = repliesJson
            .map((json) => CommentModel.fromMap(json))
            .toList();
        
        if (refresh) {
          _commentReplies[commentId] = newReplies;
        } else {
          _commentReplies[commentId] = [
            ..._commentReplies[commentId] ?? [],
            ...newReplies
          ];
        }
      }
    } on DioException catch (e) {
      debugPrint('Error loading replies: ${e.message}');
    } catch (e) {
      debugPrint('Error loading replies: $e');
    }
    
    _commentRepliesLoading[commentId] = false;
    notifyListeners();
  }

  // Like/Unlike comment
  Future<bool> toggleCommentLike(String commentId) async {
    try {
      final response = await _apiService.post('/comments/$commentId/like');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final isLiked = data['isLiked'];
        final likesCount = data['likesCount'];
        
        // Update comment in all relevant lists
        _updateCommentLike(commentId, isLiked, likesCount);
        
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Error toggling comment like: ${e.message}');
    } catch (e) {
      debugPrint('Error toggling comment like: $e');
    }
    
    return false;
  }

  // Delete comment
  Future<bool> deleteComment(String commentId) async {
    try {
      final response = await _apiService.delete('/comments/$commentId');
      
      if (response.statusCode == 200) {
        // Remove comment from all lists
        _removeComment(commentId);
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Error deleting comment: ${e.message}');
    } catch (e) {
      debugPrint('Error deleting comment: $e');
    }
    
    return false;
  }

  // Add comment from real-time update
  void addCommentFromSocket(String videoId, CommentModel comment, String? parentCommentId) {
    if (parentCommentId != null) {
      // Add to replies
      _commentReplies[parentCommentId] = [
        ..._commentReplies[parentCommentId] ?? [],
        comment
      ];
    } else {
      // Add to video comments
      _videoComments[videoId] = [comment, ..._videoComments[videoId] ?? []];
    }
    notifyListeners();
  }

  // Update comment like from real-time update
  void updateCommentLikeFromSocket(String commentId, bool isLiked, int likesCount) {
    _updateCommentLike(commentId, isLiked, likesCount);
  }

  // Helper method to update comment like in all lists
  void _updateCommentLike(String commentId, bool isLiked, int likesCount) {
    // Update in video comments
    for (final videoId in _videoComments.keys) {
      final comments = _videoComments[videoId]!;
      final index = comments.indexWhere((comment) => comment.id == commentId);
      if (index >= 0) {
        _videoComments[videoId]![index] = comments[index].copyWith(
          isLiked: isLiked,
          likesCount: likesCount,
        );
      }
    }
    
    // Update in replies
    for (final parentCommentId in _commentReplies.keys) {
      final replies = _commentReplies[parentCommentId]!;
      final index = replies.indexWhere((reply) => reply.id == commentId);
      if (index >= 0) {
        _commentReplies[parentCommentId]![index] = replies[index].copyWith(
          isLiked: isLiked,
          likesCount: likesCount,
        );
      }
    }
    
    notifyListeners();
  }

  // Helper method to remove comment from all lists
  void _removeComment(String commentId) {
    // Remove from video comments
    for (final videoId in _videoComments.keys) {
      _videoComments[videoId]!.removeWhere((comment) => comment.id == commentId);
    }
    
    // Remove from replies
    for (final parentCommentId in _commentReplies.keys) {
      _commentReplies[parentCommentId]!.removeWhere((reply) => reply.id == commentId);
    }
    
    // Remove replies of this comment
    _commentReplies.remove(commentId);
    
    notifyListeners();
  }

  // Clear all data
  void clear() {
    _videoComments.clear();
    _videoCommentsLoading.clear();
    _videoCommentsHasMore.clear();
    _commentReplies.clear();
    _commentRepliesLoading.clear();
    _addingComment = false;
    notifyListeners();
  }
}