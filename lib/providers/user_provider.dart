import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // User profiles cache
  Map<String, UserModel> _userProfiles = {};
  
  // Search results
  List<UserModel> _searchResults = [];
  bool _searchLoading = false;
  
  // Following/Followers
  List<UserModel> _followers = [];
  List<UserModel> _following = [];
  bool _followersLoading = false;
  bool _followingLoading = false;

  // Getters
  Map<String, UserModel> get userProfiles => _userProfiles;
  List<UserModel> get searchResults => _searchResults;
  bool get searchLoading => _searchLoading;
  List<UserModel> get followers => _followers;
  List<UserModel> get following => _following;
  bool get followersLoading => _followersLoading;
  bool get followingLoading => _followingLoading;

  // Get user profile by username
  Future<UserModel?> getUserProfile(String username) async {
    // Check cache first
    if (_userProfiles.containsKey(username)) {
      return _userProfiles[username];
    }

    try {
      final response = await _apiService.get('/users/profile/$username');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final user = UserModel.fromMap(data['user']);
        
        // Cache the user
        _userProfiles[username] = user;
        notifyListeners();
        
        return user;
      }
    } on DioException catch (e) {
      debugPrint('Error getting user profile: ${e.message}');
    } catch (e) {
      debugPrint('Error getting user profile: $e');
    }
    
    return null;
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? bio,
    String? profilePicturePath,
  }) async {
    try {
      FormData formData = FormData();
      
      if (displayName != null) {
        formData.fields.add(MapEntry('displayName', displayName));
      }
      if (bio != null) {
        formData.fields.add(MapEntry('bio', bio));
      }
      if (profilePicturePath != null) {
        formData.files.add(MapEntry(
          'profilePicture',
          await MultipartFile.fromFile(profilePicturePath),
        ));
      }

      final response = await _apiService.put('/users/profile', data: formData);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final updatedUser = UserModel.fromMap(data['user']);
        
        // Update cache
        _userProfiles[updatedUser.username] = updatedUser;
        notifyListeners();
        
        return {'success': true, 'message': data['message'], 'user': updatedUser};
      } else {
        return {'success': false, 'error': response.data['error']};
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return {'success': false, 'error': e.response?.data['error'] ?? 'Update failed'};
      }
      return {'success': false, 'error': AppConstants.networkError};
    } catch (e) {
      return {'success': false, 'error': AppConstants.serverError};
    }
  }

  // Follow/Unfollow user
  Future<bool> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      final response = await _apiService.post('/users/follow/$targetUserId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final isNowFollowing = data['isFollowing'];
        
        // Update cached user if exists
        final targetUser = _userProfiles.values.firstWhere(
          (user) => user.id == targetUserId,
          orElse: () => _userProfiles.values.first,
        );
        
        if (_userProfiles.containsKey(targetUser.username)) {
          // Update followers list and count
          List<String> updatedFollowers = List.from(targetUser.followers);
          if (isNowFollowing) {
            updatedFollowers.add(currentUserId);
          } else {
            updatedFollowers.remove(currentUserId);
          }
          
          _userProfiles[targetUser.username] = targetUser.copyWith(
            followers: updatedFollowers,
            followersCount: updatedFollowers.length,
          );
          notifyListeners();
        }
        
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Error toggling follow: ${e.message}');
    } catch (e) {
      debugPrint('Error toggling follow: $e');
    }
    
    return false;
  }

  // Search users
  Future<void> searchUsers(String query) async {
    if (query.trim().length < 2) {
      _searchResults.clear();
      notifyListeners();
      return;
    }

    _searchLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/users/search', queryParameters: {
        'q': query,
        'page': 1,
        'limit': AppConstants.usersPageSize,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> usersJson = data['users'];
        _searchResults = usersJson.map((json) => UserModel.fromMap(json)).toList();
        
        // Cache the users
        for (final user in _searchResults) {
          _userProfiles[user.username] = user;
        }
      }
    } on DioException catch (e) {
      debugPrint('Error searching users: ${e.message}');
      _searchResults.clear();
    } catch (e) {
      debugPrint('Error searching users: $e');
      _searchResults.clear();
    }
    
    _searchLoading = false;
    notifyListeners();
  }

  // Get followers
  Future<void> getFollowers(String userId, {bool refresh = false}) async {
    if (_followersLoading) return;
    
    if (refresh) {
      _followers.clear();
    }
    
    _followersLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/users/$userId/followers', queryParameters: {
        'page': 1,
        'limit': AppConstants.usersPageSize,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> followersJson = data['followers'];
        _followers = followersJson.map((json) => UserModel.fromMap(json)).toList();
        
        // Cache the users
        for (final user in _followers) {
          _userProfiles[user.username] = user;
        }
      }
    } on DioException catch (e) {
      debugPrint('Error getting followers: ${e.message}');
    } catch (e) {
      debugPrint('Error getting followers: $e');
    }
    
    _followersLoading = false;
    notifyListeners();
  }

  // Get following
  Future<void> getFollowing(String userId, {bool refresh = false}) async {
    if (_followingLoading) return;
    
    if (refresh) {
      _following.clear();
    }
    
    _followingLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/users/$userId/following', queryParameters: {
        'page': 1,
        'limit': AppConstants.usersPageSize,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> followingJson = data['following'];
        _following = followingJson.map((json) => UserModel.fromMap(json)).toList();
        
        // Cache the users
        for (final user in _following) {
          _userProfiles[user.username] = user;
        }
      }
    } on DioException catch (e) {
      debugPrint('Error getting following: ${e.message}');
    } catch (e) {
      debugPrint('Error getting following: $e');
    }
    
    _followingLoading = false;
    notifyListeners();
  }

  // Clear search results
  void clearSearchResults() {
    _searchResults.clear();
    notifyListeners();
  }

  // Clear all data
  void clear() {
    _userProfiles.clear();
    _searchResults.clear();
    _followers.clear();
    _following.clear();
    _searchLoading = false;
    _followersLoading = false;
    _followingLoading = false;
    notifyListeners();
  }
}