import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  final ApiService _apiService = ApiService();

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(AppConstants.tokenKey);
      
      if (_token != null) {
        _apiService.setAuthToken(_token!);
        final userData = prefs.getString(AppConstants.userKey);
        if (userData != null) {
          _user = UserModel.fromJson(userData);
          _isLoggedIn = true;
          notifyListeners();
          
          // Verify token is still valid
          await _verifyToken();
        }
      }
    } catch (e) {
      debugPrint('Error loading stored auth: $e');
      await _clearAuth();
    }
  }

  Future<bool> _verifyToken() async {
    try {
      final response = await _apiService.post('/auth/verify-token');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['valid'] == true) {
          _user = UserModel.fromMap(data['user']);
          _isLoggedIn = true;
          await _saveUserData();
          notifyListeners();
          return true;
        }
      }
      await _clearAuth();
      return false;
    } catch (e) {
      debugPrint('Token verification failed: $e');
      await _clearAuth();
      return false;
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    
    try {
      final response = await _apiService.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'displayName': displayName,
      });

      if (response.statusCode == 201) {
        final data = response.data;
        _token = data['token'];
        _user = UserModel.fromMap(data['user']);
        _isLoggedIn = true;

        _apiService.setAuthToken(_token!);
        await _saveAuthData();
        
        _setLoading(false);
        return {'success': true, 'message': data['message']};
      } else {
        _setLoading(false);
        return {'success': false, 'error': response.data['error']};
      }
    } on DioException catch (e) {
      _setLoading(false);
      if (e.response?.statusCode == 400) {
        return {'success': false, 'error': e.response?.data['error'] ?? 'Registration failed'};
      }
      return {'success': false, 'error': AppConstants.networkError};
    } catch (e) {
      _setLoading(false);
      return {'success': false, 'error': AppConstants.serverError};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    
    try {
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        _token = data['token'];
        _user = UserModel.fromMap(data['user']);
        _isLoggedIn = true;

        _apiService.setAuthToken(_token!);
        await _saveAuthData();
        
        _setLoading(false);
        return {'success': true, 'message': data['message']};
      } else {
        _setLoading(false);
        return {'success': false, 'error': response.data['error']};
      }
    } on DioException catch (e) {
      _setLoading(false);
      if (e.response?.statusCode == 400) {
        return {'success': false, 'error': e.response?.data['error'] ?? 'Invalid credentials'};
      }
      return {'success': false, 'error': AppConstants.networkError};
    } catch (e) {
      _setLoading(false);
      return {'success': false, 'error': AppConstants.serverError};
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      if (_token != null) {
        await _apiService.post('/auth/logout');
      }
    } catch (e) {
      debugPrint('Logout API call failed: $e');
    }
    
    await _clearAuth();
    _setLoading(false);
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    _user = updatedUser;
    await _saveUserData();
    notifyListeners();
  }

  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, _token!);
    await _saveUserData();
  }

  Future<void> _saveUserData() async {
    if (_user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, _user!.toJson());
    }
  }

  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    
    _token = null;
    _user = null;
    _isLoggedIn = false;
    _apiService.clearAuthToken();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}