import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/constants.dart';

class SocketProvider extends ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentUserId;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  void connect(String userId) {
    if (_socket != null && _isConnected) {
      return; // Already connected
    }

    _currentUserId = userId;
    
    _socket = IO.io(AppConstants.socketUrl, 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build()
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      print('🔗 Socket connected');
      
      // Join with user ID
      _socket!.emit(AppConstants.socketJoin, userId);
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('🔌 Socket disconnected');
      notifyListeners();
    });

    _socket!.onConnectError((error) {
      print('❌ Socket connection error: $error');
      _isConnected = false;
      notifyListeners();
    });

    _socket!.connect();
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _currentUserId = null;
      notifyListeners();
    }
  }

  // Listen for new comments
  void onNewComment(Function(Map<String, dynamic>) callback) {
    _socket?.on(AppConstants.socketCommentAdded, (data) {
      callback(data);
    });
  }

  // Listen for like updates
  void onLikeUpdate(Function(Map<String, dynamic>) callback) {
    _socket?.on(AppConstants.socketLikeUpdated, (data) {
      callback(data);
    });
  }

  // Listen for new followers
  void onNewFollower(Function(Map<String, dynamic>) callback) {
    _socket?.on(AppConstants.socketNewFollower, (data) {
      callback(data);
    });
  }

  // Listen for new messages
  void onNewMessage(Function(Map<String, dynamic>) callback) {
    _socket?.on(AppConstants.socketNewMessage, (data) {
      callback(data);
    });
  }

  // Listen for notifications
  void onNotification(Function(Map<String, dynamic>) callback) {
    _socket?.on(AppConstants.socketNotification, (data) {
      callback(data);
    });
  }

  // Emit new comment
  void emitNewComment(Map<String, dynamic> data) {
    if (_isConnected) {
      _socket?.emit(AppConstants.socketNewComment, data);
    }
  }

  // Emit video liked
  void emitVideoLiked(Map<String, dynamic> data) {
    if (_isConnected) {
      _socket?.emit(AppConstants.socketVideoLiked, data);
    }
  }

  // Emit user followed
  void emitUserFollowed(Map<String, dynamic> data) {
    if (_isConnected) {
      _socket?.emit(AppConstants.socketUserFollowed, data);
    }
  }

  // Send private message
  void sendMessage(String recipientId, String message) {
    if (_isConnected) {
      _socket?.emit(AppConstants.socketSendMessage, {
        'recipientId': recipientId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Send notification
  void sendNotification(String targetUserId, Map<String, dynamic> notificationData) {
    if (_isConnected) {
      _socket?.emit(AppConstants.socketSendNotification, {
        'targetUserId': targetUserId,
        ...notificationData,
      });
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}