import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/story_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class StoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Stories data
  List<StoryGroup> _storyGroups = [];
  List<StoryModel> _myStories = [];
  List<StoryModel> _highlights = [];
  
  // Loading states
  bool _storiesLoading = false;
  bool _myStoriesLoading = false;
  bool _creatingStory = false;
  bool _uploadingMedia = false;
  
  // Story viewer data
  List<Map<String, dynamic>> _storyViewers = [];
  bool _viewersLoading = false;
  
  // Current story being viewed
  int _currentStoryGroupIndex = 0;
  int _currentStoryIndex = 0;

  // Getters
  List<StoryGroup> get storyGroups => _storyGroups;
  List<StoryModel> get myStories => _myStories;
  List<StoryModel> get highlights => _highlights;
  bool get storiesLoading => _storiesLoading;
  bool get myStoriesLoading => _myStoriesLoading;
  bool get creatingStory => _creatingStory;
  bool get uploadingMedia => _uploadingMedia;
  List<Map<String, dynamic>> get storyViewers => _storyViewers;
  bool get viewersLoading => _viewersLoading;
  int get currentStoryGroupIndex => _currentStoryGroupIndex;
  int get currentStoryIndex => _currentStoryIndex;

  // Load stories from following users
  Future<void> loadFollowingStories({bool refresh = false}) async {
    if (_storiesLoading && !refresh) return;
    
    _storiesLoading = true;
    if (refresh) _storyGroups.clear();
    notifyListeners();
    
    try {
      final response = await _apiService.get('/stories/following-stories');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> storyGroupsJson = data['storiesGroups'];
        _storyGroups = storyGroupsJson
            .map((json) => StoryGroup.fromMap(json))
            .toList();
      }
    } on DioException catch (e) {
      debugPrint('Error loading following stories: ${e.message}');
    } catch (e) {
      debugPrint('Error loading following stories: $e');
    }
    
    _storiesLoading = false;
    notifyListeners();
  }

  // Load user's own stories
  Future<void> loadMyStories({bool refresh = false}) async {
    if (_myStoriesLoading && !refresh) return;
    
    _myStoriesLoading = true;
    if (refresh) {
      _myStories.clear();
      _highlights.clear();
    }
    notifyListeners();
    
    try {
      final response = await _apiService.get('/stories/my-stories');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> storiesJson = data['stories'];
        final stories = storiesJson
            .map((json) => StoryModel.fromMap(json))
            .toList();
            
        _myStories = stories.where((story) => !story.isHighlight).toList();
        _highlights = stories.where((story) => story.isHighlight).toList();
      }
    } on DioException catch (e) {
      debugPrint('Error loading my stories: ${e.message}');
    } catch (e) {
      debugPrint('Error loading my stories: $e');
    }
    
    _myStoriesLoading = false;
    notifyListeners();
  }

  // Create text story
  Future<Map<String, dynamic>> createTextStory({
    required String text,
    String textColor = '#FFFFFF',
    String backgroundColor = '#000000',
    List<StorySticker> stickers = const [],
    String privacy = 'public',
  }) async {
    _creatingStory = true;
    notifyListeners();
    
    try {
      final response = await _apiService.post('/stories/create', data: {
        'content': 'text',
        'text': text,
        'textColor': textColor,
        'backgroundColor': backgroundColor,
        'stickers': stickers.map((s) => s.toMap()).toList(),
        'privacy': privacy,
      });
      
      if (response.statusCode == 201) {
        final data = response.data;
        final newStory = StoryModel.fromMap(data['data']);
        
        // Add to my stories
        _myStories.insert(0, newStory);
        
        // Refresh following stories to update UI
        await loadFollowingStories(refresh: true);
        
        _creatingStory = false;
        notifyListeners();
        
        return {'success': true, 'message': data['message']};
      } else {
        _creatingStory = false;
        notifyListeners();
        return {'success': false, 'error': response.data['error']};
      }
    } on DioException catch (e) {
      _creatingStory = false;
      notifyListeners();
      
      if (e.response?.statusCode == 400) {
        return {'success': false, 'error': e.response?.data['error'] ?? 'Create failed'};
      }
      return {'success': false, 'error': AppConstants.networkError};
    } catch (e) {
      _creatingStory = false;
      notifyListeners();
      return {'success': false, 'error': AppConstants.serverError};
    }
  }

  // Create media story (photo/video)
  Future<Map<String, dynamic>> createMediaStory({
    required String filePath,
    String text = '',
    String textColor = '#FFFFFF',
    List<StorySticker> stickers = const [],
    StoryMusic? music,
    String privacy = 'public',
  }) async {
    _creatingStory = true;
    _uploadingMedia = true;
    notifyListeners();
    
    try {
      FormData formData = FormData.fromMap({
        'text': text,
        'textColor': textColor,
        'stickers': stickers.map((s) => s.toMap()).toList(),
        'privacy': privacy,
        'media': await MultipartFile.fromFile(filePath),
      });
      
      if (music != null) {
        formData.fields.add(MapEntry('music', music.toMap().toString()));
      }
      
      final response = await _apiService.post('/stories/create', data: formData);
      
      if (response.statusCode == 201) {
        final data = response.data;
        final newStory = StoryModel.fromMap(data['data']);
        
        // Add to my stories
        _myStories.insert(0, newStory);
        
        // Refresh following stories to update UI
        await loadFollowingStories(refresh: true);
        
        _creatingStory = false;
        _uploadingMedia = false;
        notifyListeners();
        
        return {'success': true, 'message': data['message']};
      } else {
        _creatingStory = false;
        _uploadingMedia = false;
        notifyListeners();
        return {'success': false, 'error': response.data['error']};
      }
    } on DioException catch (e) {
      _creatingStory = false;
      _uploadingMedia = false;
      notifyListeners();
      
      if (e.response?.statusCode == 400) {
        return {'success': false, 'error': e.response?.data['error'] ?? 'Upload failed'};
      }
      return {'success': false, 'error': AppConstants.networkError};
    } catch (e) {
      _creatingStory = false;
      _uploadingMedia = false;
      notifyListeners();
      return {'success': false, 'error': AppConstants.serverError};
    }
  }

  // View story (mark as viewed)
  Future<void> viewStory(String storyId, String id) async {
    try {
      await _apiService.post('/stories/$storyId/view');
      
      // Update local data
      for (var group in _storyGroups) {
        for (var story in group.stories) {
          if (story.id == storyId) {
            // Should add current user to viewers list
            // This would need current user ID from auth provider
            break;
          }
        }
      }
    } on DioException catch (e) {
      debugPrint('Error viewing story: ${e.message}');
    } catch (e) {
      debugPrint('Error viewing story: $e');
    }
  }

  // Get story viewers
  Future<void> loadStoryViewers(String storyId) async {
    _viewersLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/stories/$storyId/viewers');
      
      if (response.statusCode == 200) {
        final data = response.data;
        _storyViewers = List<Map<String, dynamic>>.from(data['viewers']);
      }
    } on DioException catch (e) {
      debugPrint('Error loading story viewers: ${e.message}');
    } catch (e) {
      debugPrint('Error loading story viewers: $e');
    }
    
    _viewersLoading = false;
    notifyListeners();
  }

  // Add story to highlights
  Future<bool> addToHighlights(String storyId, String title) async {
    try {
      final response = await _apiService.post('/stories/$storyId/highlight', data: {
        'title': title,
      });
      
      if (response.statusCode == 200) {
        // Move story from regular stories to highlights
        final storyIndex = _myStories.indexWhere((s) => s.id == storyId);
        if (storyIndex != -1) {
          final story = _myStories.removeAt(storyIndex);
          _highlights.add(story.copyWith(isHighlight: true, highlightTitle: title));
          notifyListeners();
        }
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Error adding to highlights: ${e.message}');
    } catch (e) {
      debugPrint('Error adding to highlights: $e');
    }
    return false;
  }

  // Delete story
  Future<bool> deleteStory(String storyId) async {
    try {
      final response = await _apiService.delete('/stories/$storyId');
      
      if (response.statusCode == 200) {
        // Remove from local data
        _myStories.removeWhere((story) => story.id == storyId);
        _highlights.removeWhere((story) => story.id == storyId);
        
        // Also remove from story groups
        for (var group in _storyGroups) {
          group.stories.removeWhere((story) => story.id == storyId);
        }
        
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Error deleting story: ${e.message}');
    } catch (e) {
      debugPrint('Error deleting story: $e');
    }
    return false;
  }

  // React to story
  Future<bool> reactToStory(String storyId, String emoji) async {
    try {
      final response = await _apiService.post('/stories/$storyId/react', data: {
        'emoji': emoji,
      });
      
      if (response.statusCode == 200) {
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Error reacting to story: ${e.message}');
    } catch (e) {
      debugPrint('Error reacting to story: $e');
    }
    return false;
  }

  // Navigation helpers for story viewer
  void setCurrentStoryPosition(int groupIndex, int storyIndex) {
    _currentStoryGroupIndex = groupIndex;
    _currentStoryIndex = storyIndex;
    notifyListeners();
  }

  void nextStory() {
    if (_currentStoryGroupIndex < _storyGroups.length) {
      final currentGroup = _storyGroups[_currentStoryGroupIndex];
      if (_currentStoryIndex < currentGroup.stories.length - 1) {
        _currentStoryIndex++;
      } else if (_currentStoryGroupIndex < _storyGroups.length - 1) {
        _currentStoryGroupIndex++;
        _currentStoryIndex = 0;
      }
      notifyListeners();
    }
  }

  void previousStory() {
    if (_currentStoryIndex > 0) {
      _currentStoryIndex--;
    } else if (_currentStoryGroupIndex > 0) {
      _currentStoryGroupIndex--;
      _currentStoryIndex = _storyGroups[_currentStoryGroupIndex].stories.length - 1;
    }
    notifyListeners();
  }

  // Add story from real-time update
  void addStoryFromSocket(StoryModel story) {
    // Find existing group or create new one
    final existingGroupIndex = _storyGroups.indexWhere(
      (group) => group.user.id == story.creator.id
    );
    
    if (existingGroupIndex != -1) {
      _storyGroups[existingGroupIndex].stories.insert(0, story);
    } else {
      // Create new group
      final newGroup = StoryGroup(
        user: story.creator,
        stories: [story],
        hasUnviewed: true,
        latestStory: story.createdAt,
      );
      _storyGroups.insert(0, newGroup);
    }
    
    notifyListeners();
  }

    // Reply to a story
  Future<bool> replyToStory(String storyId, String message) async {
    try {
      final response = await _apiService.post(
        '/stories/$storyId/reply',
        data: {'message': message},
      );
      
      if (response.statusCode == 200) {
        // Update local data if needed
        for (var group in _storyGroups) {
          for (var story in group.stories) {
            if (story.id == storyId) {
              // Add reply to story's replies if we're maintaining that locally
              break;
            }
          }
        }
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Error replying to story: ${e.message}');
    } catch (e) {
      debugPrint('Error replying to story: $e');
    }
    return false;
  }

  // Clear all data
  void clear() {
    _storyGroups.clear();
    _myStories.clear();
    _highlights.clear();
    _storyViewers.clear();
    _storiesLoading = false;
    _myStoriesLoading = false;
    _creatingStory = false;
    _uploadingMedia = false;
    _viewersLoading = false;
    notifyListeners();
  }
}