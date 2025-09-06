import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/video_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class VideoProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Feed Videos (For You)
  List<VideoModel> _feedVideos = [];
  bool _feedLoading = false;
  bool _feedHasMore = true;
  int _feedPage = 1;
  
  // Trending Videos
  List<VideoModel> _trendingVideos = [];
  bool _trendingLoading = false;
  bool _trendingHasMore = true;
  int _trendingPage = 1;
  
  // Upload
  bool _uploading = false;
  double _uploadProgress = 0.0;
  
  // Current playing video
  int _currentVideoIndex = 0;

  // Getters
  List<VideoModel> get feedVideos => _feedVideos;
  List<VideoModel> get trendingVideos => _trendingVideos;
  bool get feedLoading => _feedLoading;
  bool get trendingLoading => _trendingLoading;
  bool get feedHasMore => _feedHasMore;
  bool get trendingHasMore => _trendingHasMore;
  bool get uploading => _uploading;
  double get uploadProgress => _uploadProgress;
  int get currentVideoIndex => _currentVideoIndex;

  // Load feed videos (For You page)
  Future<void> loadFeedVideos({bool refresh = false}) async {
    if (_feedLoading) return;
    
    if (refresh) {
      _feedPage = 1;
      _feedHasMore = true;
      _feedVideos.clear();
    }
    
    if (!_feedHasMore) return;
    
    _feedLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get(
        '/videos/feed',
        queryParameters: {
          'page': _feedPage,
          'limit': AppConstants.defaultPageSize,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> videosJson = data['videos'];
        final List<VideoModel> newVideos = videosJson
            .map((json) => VideoModel.fromMap(json))
            .toList();
        
        if (refresh) {
          _feedVideos = newVideos;
        } else {
          _feedVideos.addAll(newVideos);
        }
        
        _feedHasMore = data['hasMore'] ?? false;
        _feedPage++;
      }
    } on DioException catch (e) {
      debugPrint('Error loading feed videos: ${e.message}');
    } catch (e) {
      debugPrint('Error loading feed videos: $e');
    }
    
    _feedLoading = false;
    notifyListeners();
  }

  // Load trending videos
  Future<void> loadTrendingVideos({bool refresh = false}) async {
    if (_trendingLoading) return;
    
    if (refresh) {
      _trendingPage = 1;
      _trendingHasMore = true;
      _trendingVideos.clear();
    }
    
    if (!_trendingHasMore) return;
    
    _trendingLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get(
        '/videos/trending',
        queryParameters: {
          'page': _trendingPage,
          'limit': AppConstants.defaultPageSize,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> videosJson = data['videos'];
        final List<VideoModel> newVideos = videosJson
            .map((json) => VideoModel.fromMap(json))
            .toList();
        
        if (refresh) {
          _trendingVideos = newVideos;
        } else {
          _trendingVideos.addAll(newVideos);
        }
        
        _trendingHasMore = data['hasMore'] ?? false;
        _trendingPage++;
      }
    } on DioException catch (e) {
      debugPrint('Error loading trending videos: ${e.message}');
    } catch (e) {
      debugPrint('Error loading trending videos: $e');
    }
    
    _trendingLoading = false;
    notifyListeners();
  }

  // Upload video
  Future<Map<String, dynamic>> uploadVideo({
    required String videoPath,
    String? caption,
    List<String>? hashtags,
    bool allowComments = true,
    bool allowDownload = true,
  }) async {
    _uploading = true;
    _uploadProgress = 0.0;
    notifyListeners();
    
    try {
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(videoPath),
        'caption': caption ?? '',
        'hashtags': hashtags?.join(',') ?? '',
        'allowComments': allowComments.toString(),
        'allowDownload': allowDownload.toString(),
      });
      
      final response = await _apiService.post(
        '/videos/upload',
        data: formData,
        onSendProgress: (sent, total) {
          _uploadProgress = sent / total;
          notifyListeners();
        },
      );
      
      if (response.statusCode == 201) {
        final data = response.data;
        final newVideo = VideoModel.fromMap(data['video']);
        
        // Add to beginning of feed
        _feedVideos.insert(0, newVideo);
        
        _uploading = false;
        _uploadProgress = 0.0;
        notifyListeners();
        
        return {'success': true, 'message': data['message'], 'video': newVideo};
      } else {
        _uploading = false;
        _uploadProgress = 0.0;
        notifyListeners();
        return {'success': false, 'error': response.data['error']};
      }
    } on DioException catch (e) {
      _uploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      
      if (e.response?.statusCode == 400) {
        return {'success': false, 'error': e.response?.data['error'] ?? 'Upload failed'};
      }
      return {'success': false, 'error': AppConstants.videoUploadError};
    } catch (e) {
      _uploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return {'success': false, 'error': AppConstants.videoUploadError};
    }
  }

  // Like/Unlike video
  Future<bool> toggleLike(String videoId) async {
    try {
      final response = await _apiService.post('/videos/$videoId/like');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final isLiked = data['isLiked'];
        final likesCount = data['likesCount'];
        
        // Update video in feed
        _updateVideoInteraction(videoId, isLiked: isLiked, likesCount: likesCount);
        
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Error toggling like: ${e.message}');
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
    return false;
  }

  // Share video
  Future<bool> shareVideo(String videoId) async {
    try {
      final response = await _apiService.post('/videos/$videoId/share');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final sharesCount = data['sharesCount'];
        
        // Update video in feed
        _updateVideoInteraction(videoId, sharesCount: sharesCount);
        
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Error sharing video: ${e.message}');
    } catch (e) {
      debugPrint('Error sharing video: $e');
    }
    return false;
  }

  // Get single video
  Future<VideoModel?> getVideo(String videoId) async {
    try {
      final response = await _apiService.get('/videos/$videoId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        return VideoModel.fromMap(data['video']);
      }
    } on DioException catch (e) {
      debugPrint('Error getting video: ${e.message}');
    } catch (e) {
      debugPrint('Error getting video: $e');
    }
    return null;
  }

  // Delete video
  Future<bool> deleteVideo(String videoId) async {
    try {
      final response = await _apiService.delete('/videos/$videoId');
      
      if (response.statusCode == 200) {
        // Remove from local lists
        _feedVideos.removeWhere((video) => video.id == videoId);
        _trendingVideos.removeWhere((video) => video.id == videoId);
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Error deleting video: ${e.message}');
    } catch (e) {
      debugPrint('Error deleting video: $e');
    }
    return false;
  }

  // Update video interaction (likes, shares, comments) locally
  void _updateVideoInteraction(
    String videoId, {
    bool? isLiked,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
  }) {
    // Update in feed videos
    final feedIndex = _feedVideos.indexWhere((video) => video.id == videoId);
    if (feedIndex != -1) {
      _feedVideos[feedIndex] = _feedVideos[feedIndex].copyWith(
        isLiked: isLiked,
        likesCount: likesCount,
        commentsCount: commentsCount,
        sharesCount: sharesCount,
      );
    }
    
    // Update in trending videos
    final trendingIndex = _trendingVideos.indexWhere((video) => video.id == videoId);
    if (trendingIndex != -1) {
      _trendingVideos[trendingIndex] = _trendingVideos[trendingIndex].copyWith(
        isLiked: isLiked,
        likesCount: likesCount,
        commentsCount: commentsCount,
        sharesCount: sharesCount,
      );
    }
    
    notifyListeners();
  }

  // Set current video index for video player
  void setCurrentVideoIndex(int index) {
    _currentVideoIndex = index;
    notifyListeners();
  }

  // Update comment count when comment is added/removed
  void updateVideoCommentCount(String videoId, int newCount) {
    _updateVideoInteraction(videoId, commentsCount: newCount);
  }

  // Clear all data
  void clear() {
    _feedVideos.clear();
    _trendingVideos.clear();
    _feedPage = 1;
    _trendingPage = 1;
    _feedHasMore = true;
    _trendingHasMore = true;
    _feedLoading = false;
    _trendingLoading = false;
    _uploading = false;
    _uploadProgress = 0.0;
    _currentVideoIndex = 0;
    notifyListeners();
  }
}