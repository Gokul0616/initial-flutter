import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  String? _authToken;

  ApiService._internal() {
    _dio = Dio();
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token to requests
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          
          if (kDebugMode) {
            print('📤 REQUEST: ${options.method} ${options.path}');
            print('📤 Headers: ${options.headers}');
            if (options.data != null) {
              print('📤 Data: ${options.data}');
            }
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('📥 RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
            print('📥 Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('❌ ERROR: ${error.requestOptions.path}');
            print('❌ Status: ${error.response?.statusCode}');
            print('❌ Message: ${error.message}');
            print('❌ Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }
  }

  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Handle errors
  DioException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw DioException(
          requestOptions: error.requestOptions,
          error: 'Connection timeout. Please check your internet connection.',
          type: error.type,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            throw DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: error.response?.data['error'] ?? 'Bad request',
              type: error.type,
            );
          case 401:
            throw DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: 'Unauthorized. Please log in again.',
              type: error.type,
            );
          case 403:
            throw DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: 'Access forbidden',
              type: error.type,
            );
          case 404:
            throw DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: 'Resource not found',
              type: error.type,
            );
          case 500:
            throw DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: 'Server error. Please try again later.',
              type: error.type,
            );
          default:
            throw DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: error.response?.data['error'] ?? 'Something went wrong',
              type: error.type,
            );
        }
      
      case DioExceptionType.cancel:
        throw DioException(
          requestOptions: error.requestOptions,
          error: 'Request cancelled',
          type: error.type,
        );
      
      case DioExceptionType.unknown:
      default:
        throw DioException(
          requestOptions: error.requestOptions,
          error: 'Network error. Please check your internet connection.',
          type: error.type,
        );
    }
  }

  // Cancel all requests
  void cancelRequests() {
    _dio.close();
  }
}