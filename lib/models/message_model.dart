import 'dart:convert';
import 'user_model.dart';

class MessageMedia {
  final String url;
  final String type; // 'image', 'video', 'audio', 'file', 'gif', 'sticker'
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

  MessageMedia copyWith({
    String? url,
    String? type,
    String? filename,
    int? size,
    String? thumbnail,
    int? duration,
    int? width,
    int? height,
  }) {
    return MessageMedia(
      url: url ?? this.url,
      type: type ?? this.type,
      filename: filename ?? this.filename,
      size: size ?? this.size,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

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
  bool get isGif => type == 'gif';
  bool get isSticker => type == 'sticker';

  String get sizeText {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class VoiceNote {
  final String url;
  final int duration;
  final List<double> visualData; // Waveform data

  VoiceNote({
    required this.url,
    required this.duration,
    this.visualData = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'duration': duration,
      'visualData': visualData,
    };
  }

  factory VoiceNote.fromMap(Map<String, dynamic> map) {
    return VoiceNote(
      url: map['url'] ?? '',
      duration: map['duration']?.toInt() ?? 0,
      visualData: List<double>.from(map['visualData'] ?? []),
    );
  }

  String get fullUrl {
    if (url.isEmpty) return '';
    return url.startsWith('http') 
        ? url 
        : 'http://localhost:3001$url';
  }

  String get durationText {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class MessagePosition {
  final double x;
  final double y;

  MessagePosition({
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
    };
  }

  factory MessagePosition.fromMap(Map<String, dynamic> map) {
    return MessagePosition(
      x: map['x']?.toDouble() ?? 0.0,
      y: map['y']?.toDouble() ?? 0.0,
    );
  }
}

class MessageMention {
  final String userId;
  final String username;
  final int start;
  final int end;

  MessageMention({
    required this.userId,
    required this.username,
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'start': start,
      'end': end,
    };
  }

  factory MessageMention.fromMap(Map<String, dynamic> map) {
    return MessageMention(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      start: map['start']?.toInt() ?? 0,
      end: map['end']?.toInt() ?? 0,
    );
  }
}

class MessageEditHistory {
  final String text;
  final DateTime editedAt;

  MessageEditHistory({
    required this.text,
    required this.editedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'editedAt': editedAt.toIso8601String(),
    };
  }

  factory MessageEditHistory.fromMap(Map<String, dynamic> map) {
    return MessageEditHistory(
      text: map['text'] ?? '',
      editedAt: DateTime.parse(map['editedAt'] ?? DateTime.now().toIso8601String()),
    );
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
  final String? mediaUrl;
  final String messageType;

  MessageReply({
    required this.messageId,
    required this.text,
    required this.senderName,
    this.mediaUrl,
    this.messageType = 'text',
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'text': text,
      'senderName': senderName,
      'mediaUrl': mediaUrl,
      'messageType': messageType,
    };
  }

  factory MessageReply.fromMap(Map<String, dynamic> map) {
    return MessageReply(
      messageId: map['messageId'] ?? '',
      text: map['text'] ?? '',
      senderName: map['senderName'] ?? '',
      mediaUrl: map['mediaUrl'],
      messageType: map['messageType'] ?? 'text',
    );
  }
}

class MessageModel {
  final String id;
  final String text;
  final UserModel sender;
  final UserModel recipient;
  final String messageType; // 'text', 'image', 'video', 'audio', 'story_reply', 'media_group', 'sticker', 'gif'
  final MessageMedia? media;
  final List<MessageMedia> mediaGroup;
  final StoryReplyData? storyReply;
  final List<MessageReaction> reactions;
  final MessageReply? replyTo;
  final MessagePosition? position; // For drag functionality
  final bool isRead;
  final DateTime? readAt;
  final String status; // 'sending', 'sent', 'delivered', 'read'
  final DateTime? expiresAt;
  final bool isEdited;
  final DateTime? editedAt;
  final List<MessageEditHistory> editHistory;
  final List<MessageMention> mentions;
  final List<String> hashtags;
  final VoiceNote? voiceNote;
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
    this.position,
    this.isRead = false,
    this.readAt,
    this.status = 'sent',
    this.expiresAt,
    this.isEdited = false,
    this.editedAt,
    this.editHistory = const [],
    this.mentions = const [],
    this.hashtags = const [],
    this.voiceNote,
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
    MessagePosition? position,
    bool? isRead,
    DateTime? readAt,
    String? status,
    DateTime? expiresAt,
    bool? isEdited,
    DateTime? editedAt,
    List<MessageEditHistory>? editHistory,
    List<MessageMention>? mentions,
    List<String>? hashtags,
    VoiceNote? voiceNote,
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
      position: position ?? this.position,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      editHistory: editHistory ?? this.editHistory,
      mentions: mentions ?? this.mentions,
      hashtags: hashtags ?? this.hashtags,
      voiceNote: voiceNote ?? this.voiceNote,
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
      'position': position?.toMap(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'status': status,
      'expiresAt': expiresAt?.toIso8601String(),
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'editHistory': editHistory.map((x) => x.toMap()).toList(),
      'mentions': mentions.map((x) => x.toMap()).toList(),
      'hashtags': hashtags,
      'voiceNote': voiceNote?.toMap(),
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
      position: map['position'] != null ? MessagePosition.fromMap(map['position']) : null,
      isRead: map['isRead'] ?? false,
      readAt: map['readAt'] != null ? DateTime.parse(map['readAt']) : null,
      status: map['status'] ?? 'sent',
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] != null ? DateTime.parse(map['editedAt']) : null,
      editHistory: List<MessageEditHistory>.from(
        map['editHistory']?.map((x) => MessageEditHistory.fromMap(x)) ?? []
      ),
      mentions: List<MessageMention>.from(
        map['mentions']?.map((x) => MessageMention.fromMap(x)) ?? []
      ),
      hashtags: List<String>.from(map['hashtags'] ?? []),
      voiceNote: map['voiceNote'] != null ? VoiceNote.fromMap(map['voiceNote']) : null,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) => MessageModel.fromMap(json.decode(source));

  // Check if message is editable (within 3 hours and not deleted)
  bool get canEdit {
    final threeHoursAgo = DateTime.now().subtract(const Duration(hours: 3));
    return createdAt.isAfter(threeHoursAgo) && messageType == 'text';
  }

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
    if (messageType == 'sticker') return '🎭 Sticker';
    if (messageType == 'gif') return '🎬 GIF';
    if (voiceNote != null) return '🎤 Voice message';
    return 'Message';
  }

  String get editTimeRemaining {
    if (!canEdit) return '';
    
    final threeHoursLater = createdAt.add(const Duration(hours: 3));
    final remaining = threeHoursLater.difference(DateTime.now());
    
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m left to edit';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m left to edit';
    } else {
      return 'Less than 1m left to edit';
    }
  }

  bool get hasMedia => media != null || mediaGroup.isNotEmpty;
  bool get isText => messageType == 'text' && !hasMedia;
  bool get isImage => messageType == 'image';
  bool get isVideo => messageType == 'video';
  bool get isAudio => messageType == 'audio';
  bool get isStoryReply => messageType == 'story_reply';
  bool get isMediaGroup => messageType == 'media_group';
  bool get isSticker => messageType == 'sticker';
  bool get isGif => messageType == 'gif';
  bool get hasVoiceNote => voiceNote != null;

  bool isFromCurrentUser(String currentUserId) => sender.id == currentUserId;

  bool get hasReactions => reactions.isNotEmpty;
  bool get hasMentions => mentions.isNotEmpty;
  bool get hasHashtags => hashtags.isNotEmpty;

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
  final bool isOnline;
  final DateTime? lastActive;

  ConversationModel({
    required this.user,
    required this.lastMessage,
    required this.unreadCount,
    this.hasStory = false,
    this.latestStory,
    this.isOnline = false,
    this.lastActive,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      user: UserModel.fromMap(map['user'] ?? {}),
      lastMessage: MessageModel.fromMap(map['lastMessage'] ?? {}),
      unreadCount: map['unreadCount']?.toInt() ?? 0,
      hasStory: map['hasStory'] ?? false,
      latestStory: map['latestStory'],
      isOnline: map['isOnline'] ?? false,
      lastActive: map['lastActive'] != null ? DateTime.parse(map['lastActive']) : null,
    );
  }

  bool get hasUnreadMessages => unreadCount > 0;

  String get unreadCountText {
    if (unreadCount > 99) return '99+';
    return unreadCount.toString();
  }

  String get lastActiveText {
    if (isOnline) return 'Online';
    if (lastActive == null) return 'Offline';
    
    final now = DateTime.now();
    final difference = now.difference(lastActive!);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return 'Last seen ${difference.inDays}d ago';
  }
}