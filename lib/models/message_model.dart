import 'dart:convert';
import 'user_model.dart';

class MessageMedia {
  final String url;
  final String type; // 'image', 'video', 'audio', 'file'
  final String filename;
  final int size;
  final String? thumbnail;
  final int? duration; // For videos/audio
  final int? width; // For images/videos
  final int? height; // For images/videos

  MessageMedia({
    required this.url,
    required this.type,
    required this.filename,
    required this.size,
    this.thumbnail,
    this.duration,
    this.width,
    this.height,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'type': type,
      'filename': filename,
      'size': size,
      'thumbnail': thumbnail,
      'duration': duration,
      'width': width,
      'height': height,
    };
  }

  factory MessageMedia.fromMap(Map<String, dynamic> map) {
    return MessageMedia(
      url: map['url'] ?? '',
      type: map['type'] ?? 'file',
      filename: map['filename'] ?? '',
      size: map['size']?.toInt() ?? 0,
      thumbnail: map['thumbnail'],
      duration: map['duration']?.toInt(),
      width: map['width']?.toInt(),
      height: map['height']?.toInt(),
    );
  }

  String get fullUrl {
    if (url.isEmpty) return '';
    return url.startsWith('http') 
        ? url 
        : 'http://localhost:3001$url';
  }

  String get fullThumbnailUrl {
    if (thumbnail == null || thumbnail!.isEmpty) return '';
    return thumbnail!.startsWith('http') 
        ? thumbnail! 
        : 'http://localhost:3001$thumbnail';
  }

  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isAudio => type == 'audio';
  bool get isFile => type == 'file';

  String get sizeText {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class StoryReplyData {
  final String storyId;
  final String storyMediaUrl;
  final String storyText;

  StoryReplyData({
    required this.storyId,
    required this.storyMediaUrl,
    required this.storyText,
  });

  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'storyMediaUrl': storyMediaUrl,
      'storyText': storyText,
    };
  }

  factory StoryReplyData.fromMap(Map<String, dynamic> map) {
    return StoryReplyData(
      storyId: map['storyId'] ?? '',
      storyMediaUrl: map['storyMediaUrl'] ?? '',
      storyText: map['storyText'] ?? '',
    );
  }
}

class MessageReaction {
  final String userId;
  final String emoji;
  final DateTime createdAt;

  MessageReaction({
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MessageReaction.fromMap(Map<String, dynamic> map) {
    return MessageReaction(
      userId: map['userId'] ?? '',
      emoji: map['emoji'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class MessageReply {
  final String messageId;
  final String text;
  final String senderName;

  MessageReply({
    required this.messageId,
    required this.text,
    required this.senderName,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'text': text,
      'senderName': senderName,
    };
  }

  factory MessageReply.fromMap(Map<String, dynamic> map) {
    return MessageReply(
      messageId: map['messageId'] ?? '',
      text: map['text'] ?? '',
      senderName: map['senderName'] ?? '',
    );
  }
}

class MessageModel {
  final String id;
  final String text;
  final UserModel sender;
  final UserModel recipient;
  final String messageType; // 'text', 'image', 'video', 'audio', 'story_reply', 'media_group'
  final MessageMedia? media;
  final List<MessageMedia> mediaGroup;
  final StoryReplyData? storyReply;
  final List<MessageReaction> reactions;
  final MessageReply? replyTo;
  final bool isRead;
  final DateTime? readAt;
  final String status; // 'sending', 'sent', 'delivered', 'read'
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.id,
    this.text = '',
    required this.sender,
    required this.recipient,
    this.messageType = 'text',
    this.media,
    this.mediaGroup = const [],
    this.storyReply,
    this.reactions = const [],
    this.replyTo,
    this.isRead = false,
    this.readAt,
    this.status = 'sent',
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  MessageModel copyWith({
    String? id,
    String? text,
    UserModel? sender,
    UserModel? recipient,
    String? messageType,
    MessageMedia? media,
    List<MessageMedia>? mediaGroup,
    StoryReplyData? storyReply,
    List<MessageReaction>? reactions,
    MessageReply? replyTo,
    bool? isRead,
    DateTime? readAt,
    String? status,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      recipient: recipient ?? this.recipient,
      messageType: messageType ?? this.messageType,
      media: media ?? this.media,
      mediaGroup: mediaGroup ?? this.mediaGroup,
      storyReply: storyReply ?? this.storyReply,
      reactions: reactions ?? this.reactions,
      replyTo: replyTo ?? this.replyTo,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
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
      'messageType': messageType,
      'media': media?.toMap(),
      'mediaGroup': mediaGroup.map((x) => x.toMap()).toList(),
      'storyReply': storyReply?.toMap(),
      'reactions': reactions.map((x) => x.toMap()).toList(),
      'replyTo': replyTo?.toMap(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'status': status,
      'expiresAt': expiresAt?.toIso8601String(),
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
      messageType: map['messageType'] ?? 'text',
      media: map['media'] != null ? MessageMedia.fromMap(map['media']) : null,
      mediaGroup: List<MessageMedia>.from(
        map['mediaGroup']?.map((x) => MessageMedia.fromMap(x)) ?? []
      ),
      storyReply: map['storyReply'] != null ? StoryReplyData.fromMap(map['storyReply']) : null,
      reactions: List<MessageReaction>.from(
        map['reactions']?.map((x) => MessageReaction.fromMap(x)) ?? []
      ),
      replyTo: map['replyTo'] != null ? MessageReply.fromMap(map['replyTo']) : null,
      isRead: map['isRead'] ?? false,
      readAt: map['readAt'] != null ? DateTime.parse(map['readAt']) : null,
      status: map['status'] ?? 'sent',
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
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

  String get previewText {
    if (text.isNotEmpty) return text;
    if (messageType == 'image') return '📷 Photo';
    if (messageType == 'video') return '🎥 Video';
    if (messageType == 'audio') return '🎵 Audio';
    if (messageType == 'story_reply') return '💬 Replied to story';
    if (messageType == 'media_group') return '📷 ${mediaGroup.length} photos';
    return 'Message';
  }

  bool get hasMedia => media != null || mediaGroup.isNotEmpty;
  bool get isText => messageType == 'text' && !hasMedia;
  bool get isImage => messageType == 'image';
  bool get isVideo => messageType == 'video';
  bool get isAudio => messageType == 'audio';
  bool get isStoryReply => messageType == 'story_reply';
  bool get isMediaGroup => messageType == 'media_group';

  bool isFromCurrentUser(String currentUserId) => sender.id == currentUserId;

  bool get hasReactions => reactions.isNotEmpty;

  @override
  String toString() {
    return 'MessageModel(id: $id, text: $text, messageType: $messageType, sender: ${sender.username})';
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
  final bool hasStory;
  final Map<String, dynamic>? latestStory;

  ConversationModel({
    required this.user,
    required this.lastMessage,
    required this.unreadCount,
    this.hasStory = false,
    this.latestStory,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      user: UserModel.fromMap(map['user'] ?? {}),
      lastMessage: MessageModel.fromMap(map['lastMessage'] ?? {}),
      unreadCount: map['unreadCount']?.toInt() ?? 0,
      hasStory: map['hasStory'] ?? false,
      latestStory: map['latestStory'],
    );
  }

  bool get hasUnreadMessages => unreadCount > 0;

  String get unreadCountText {
    if (unreadCount > 99) return '99+';
    return unreadCount.toString();
  }
}