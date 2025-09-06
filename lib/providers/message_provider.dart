import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class MessageProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Conversations
  List<ConversationModel> _conversations = [];
  bool _conversationsLoading = false;
  
  // Messages by conversation
  Map<String, List<MessageModel>> _conversationMessages = {};
  Map<String, bool> _messagesLoading = {};
  Map<String, bool> _messagesHasMore = {};
  
  // Sending message state
  bool _sendingMessage = false;

  // Getters
  List<ConversationModel> get conversations => _conversations;
  bool get conversationsLoading => _conversationsLoading;
  bool get sendingMessage => _sendingMessage;

  List<MessageModel> getConversationMessages(String userId) {
    return _conversationMessages[userId] ?? [];
  }

  bool isMessagesLoading(String userId) => _messagesLoading[userId] ?? false;
  bool hasMoreMessages(String userId) => _messagesHasMore[userId] ?? true;

  // Load conversations
  Future<void> loadConversations({bool refresh = false}) async {
    if (_conversationsLoading && !refresh) return;
    
    _conversationsLoading = true;
    if (refresh) _conversations.clear();
    notifyListeners();
    
    try {
      final response = await _apiService.get('/messages/conversations');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> conversationsJson = data['conversations'];
        _conversations = conversationsJson
            .map((json) => ConversationModel.fromMap(json))
            .toList();
      }
    } on DioException catch (e) {
      debugPrint('Error loading conversations: ${e.message}');
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    }
    
    _conversationsLoading = false;
    notifyListeners();
  }

  // Load messages for a conversation
  Future<void> loadMessages(String userId, {bool refresh = false}) async {
    if (_messagesLoading[userId] == true && !refresh) return;
    
    if (refresh) {
      _conversationMessages[userId] = [];
      _messagesHasMore[userId] = true;
    }
    
    if (_messagesHasMore[userId] != true) return;
    
    _messagesLoading[userId] = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/messages/conversation/$userId', queryParameters: {
        'page': 1,
        'limit': 50,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> messagesJson = data['messages'];
        final List<MessageModel> newMessages = messagesJson
            .map((json) => MessageModel.fromMap(json))
            .toList();
        
        if (refresh) {
          _conversationMessages[userId] = newMessages;
        } else {
          _conversationMessages[userId] = [
            ...(_conversationMessages[userId] ?? []),
            ...newMessages
          ];
        }
        
        _messagesHasMore[userId] = data['hasMore'] ?? false;
      }
    } on DioException catch (e) {
      debugPrint('Error loading messages: ${e.message}');
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
    
    _messagesLoading[userId] = false;
    notifyListeners();
  }

  // Send message
  Future<Map<String, dynamic>> sendMessage({
    required String recipientId,
    required String text,
    String? replyToId,
  }) async {
    if (text.trim().isEmpty) {
      return {'success': false, 'error': 'Message cannot be empty'};
    }

    _sendingMessage = true;
    notifyListeners();
    
    try {
      final response = await _apiService.post('/messages/send', data: {
        'recipientId': recipientId,
        'text': text.trim(),
      });
      
      if (response.statusCode == 201) {
        final data = response.data;
        final newMessage = MessageModel.fromMap(data['data']);
        
        // Add to local messages
        _conversationMessages[recipientId] = [
          ..._conversationMessages[recipientId] ?? [],
          newMessage
        ];
        
        // Update conversations list
        await loadConversations(refresh: true);
        
        _sendingMessage = false;
        notifyListeners();
        
        return {'success': true, 'message': data['message']};
      } else {
        _sendingMessage = false;
        notifyListeners();
        return {'success': false, 'error': response.data['error']};
      }
    } on DioException catch (e) {
      _sendingMessage = false;
      notifyListeners();
      
      if (e.response?.statusCode == 400) {
        return {'success': false, 'error': e.response?.data['error'] ?? 'Send failed'};
      }
      return {'success': false, 'error': AppConstants.networkError};
    } catch (e) {
      _sendingMessage = false;
      notifyListeners();
      return {'success': false, 'error': AppConstants.serverError};
    }
  }

  // Add message from real-time update
  void addMessageFromSocket(MessageModel message) {
    final conversationUserId = message.sender.id == message.recipient.id 
        ? message.recipient.id 
        : message.sender.id;
        
    _conversationMessages[conversationUserId] = [
      ..._conversationMessages[conversationUserId] ?? [],
      message
    ];
    
    // Update conversations
    loadConversations(refresh: true);
    notifyListeners();
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String userId) async {
    // This will be handled automatically when loading messages
    // The backend marks messages as read when fetching conversation
  }

  // Delete message
  Future<bool> deleteMessage(String messageId, String conversationUserId) async {
    try {
      final response = await _apiService.delete('/messages/$messageId');
      
      if (response.statusCode == 200) {
        // Remove from local messages
        _conversationMessages[conversationUserId]?.removeWhere(
          (message) => message.id == messageId
        );
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Error deleting message: ${e.message}');
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
    return false;
  }

  // Clear all data
  void clear() {
    _conversations.clear();
    _conversationMessages.clear();
    _messagesLoading.clear();
    _messagesHasMore.clear();
    _conversationsLoading = false;
    _sendingMessage = false;
    notifyListeners();
  }
}