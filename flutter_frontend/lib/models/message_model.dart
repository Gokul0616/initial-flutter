import 'dart:convert';
import 'user_model.dart';

class MessageModel {
  final String id;
  final String text;
  final UserModel sender;
  final UserModel recipient;
  final bool isRead;
  final String messageType;
  final String attachmentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.recipient,
    required this.isRead,
    required this.messageType,
    required this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  MessageModel copyWith({
    String? id,
    String? text,
    UserModel? sender,
    UserModel? recipient,
    bool? isRead,
    String? messageType,
    String? attachmentUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      recipient: recipient ?? this.recipient,
      isRead: isRead ?? this.isRead,
      messageType: messageType ?? this.messageType,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender.toMap(),
      'recipient': recipient.toMap(),
      'isRead': isRead,
      'messageType': messageType,
      'attachmentUrl': attachmentUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['_id'] ?? map['id'] ?? '',
      text: map['text'] ?? '',
      sender: UserModel.fromMap(map['sender'] ?? {}),
      recipient: UserModel.fromMap(map['recipient'] ?? {}),
      isRead: map['isRead'] ?? false,
      messageType: map['messageType'] ?? 'text',
      attachmentUrl: map['attachmentUrl'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) => MessageModel.fromMap(json.decode(source));

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  String get shortTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  bool get isFromCurrentUser => false; // This should be set based on current user context

  @override
  String toString() {
    return 'MessageModel(id: $id, text: $text, sender: ${sender.username}, recipient: ${recipient.username})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ConversationModel {
  final UserModel user;
  final MessageModel lastMessage;
  final int unreadCount;

  ConversationModel({
    required this.user,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      user: UserModel.fromMap(map['user'] ?? {}),
      lastMessage: MessageModel.fromMap(map['lastMessage'] ?? {}),
      unreadCount: map['unreadCount']?.toInt() ?? 0,
    );
  }

  bool get hasUnreadMessages => unreadCount > 0;

  String get unreadCountText {
    if (unreadCount > 99) return '99+';
    return unreadCount.toString();
  }
}