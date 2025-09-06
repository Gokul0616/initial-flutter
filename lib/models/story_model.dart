import 'dart:convert';
import 'user_model.dart';

class StorySticker {
  final String type;
  final String? url;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;

  StorySticker({
    required this.type,
    this.url,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'url': url,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
    };
  }

  factory StorySticker.fromMap(Map<String, dynamic> map) {
    return StorySticker(
      type: map['type'] ?? '',
      url: map['url'],
      x: map['x']?.toDouble() ?? 0.0,
      y: map['y']?.toDouble() ?? 0.0,
      width: map['width']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 0.0,
      rotation: map['rotation']?.toDouble() ?? 0.0,
    );
  }
}

class StoryMusic {
  final String title;
  final String artist;
  final String url;
  final int startTime;

  StoryMusic({
    required this.title,
    required this.artist,
    required this.url,
    this.startTime = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'url': url,
      'startTime': startTime,
    };
  }

  factory StoryMusic.fromMap(Map<String, dynamic> map) {
    return StoryMusic(
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      url: map['url'] ?? '',
      startTime: map['startTime']?.toInt() ?? 0,
    );
  }
}

class StoryViewer {
  final String userId;
  final DateTime viewedAt;

  StoryViewer({
    required this.userId,
    required this.viewedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'viewedAt': viewedAt.toIso8601String(),
    };
  }

  factory StoryViewer.fromMap(Map<String, dynamic> map) {
    return StoryViewer(
      userId: map['userId'] ?? '',
      viewedAt: DateTime.parse(map['viewedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class StoryReaction {
  final String userId;
  final String emoji;
  final DateTime createdAt;

  StoryReaction({
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

  factory StoryReaction.fromMap(Map<String, dynamic> map) {
    return StoryReaction(
      userId: map['userId'] ?? '',
      emoji: map['emoji'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class StoryReply {
  final String userId;
  final String message;
  final DateTime createdAt;

  StoryReply({
    required this.userId,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StoryReply.fromMap(Map<String, dynamic> map) {
    return StoryReply(
      userId: map['userId'] ?? '',
      message: map['message'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class StoryModel {
  final String id;
  final UserModel creator;
  final String content; // 'photo', 'video', 'text'
  final String mediaUrl;
  final String text;
  final String textColor;
  final String backgroundColor;
  final List<StorySticker> stickers;
  final StoryMusic? music;
  final int duration;
  final DateTime expiresAt;
  final List<StoryViewer> viewers;
  final int viewsCount;
  final String privacy; // 'public', 'friends', 'close_friends'
  final bool isHighlight;
  final String highlightTitle;
  final List<StoryReaction> reactions;
  final List<StoryReply> replies;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoryModel({
    required this.id,
    required this.creator,
    required this.content,
    this.mediaUrl = '',
    this.text = '',
    this.textColor = '#FFFFFF',
    this.backgroundColor = '#000000',
    this.stickers = const [],
    this.music,
    this.duration = 86400000, // 24 hours in milliseconds
    required this.expiresAt,
    this.viewers = const [],
    this.viewsCount = 0,
    this.privacy = 'public',
    this.isHighlight = false,
    this.highlightTitle = '',
    this.reactions = const [],
    this.replies = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  StoryModel copyWith({
    String? id,
    UserModel? creator,
    String? content,
    String? mediaUrl,
    String? text,
    String? textColor,
    String? backgroundColor,
    List<StorySticker>? stickers,
    StoryMusic? music,
    int? duration,
    DateTime? expiresAt,
    List<StoryViewer>? viewers,
    int? viewsCount,
    String? privacy,
    bool? isHighlight,
    String? highlightTitle,
    List<StoryReaction>? reactions,
    List<StoryReply>? replies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      creator: creator ?? this.creator,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      text: text ?? this.text,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      stickers: stickers ?? this.stickers,
      music: music ?? this.music,
      duration: duration ?? this.duration,
      expiresAt: expiresAt ?? this.expiresAt,
      viewers: viewers ?? this.viewers,
      viewsCount: viewsCount ?? this.viewsCount,
      privacy: privacy ?? this.privacy,
      isHighlight: isHighlight ?? this.isHighlight,
      highlightTitle: highlightTitle ?? this.highlightTitle,
      reactions: reactions ?? this.reactions,
      replies: replies ?? this.replies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creator': creator.toMap(),
      'content': content,
      'mediaUrl': mediaUrl,
      'text': text,
      'textColor': textColor,
      'backgroundColor': backgroundColor,
      'stickers': stickers.map((x) => x.toMap()).toList(),
      'music': music?.toMap(),
      'duration': duration,
      'expiresAt': expiresAt.toIso8601String(),
      'viewers': viewers.map((x) => x.toMap()).toList(),
      'viewsCount': viewsCount,
      'privacy': privacy,
      'isHighlight': isHighlight,
      'highlightTitle': highlightTitle,
      'reactions': reactions.map((x) => x.toMap()).toList(),
      'replies': replies.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      id: map['id'] ?? map['_id'] ?? '',
      creator: UserModel.fromMap(map['creator'] ?? {}),
      content: map['content'] ?? 'text',
      mediaUrl: map['mediaUrl'] ?? '',
      text: map['text'] ?? '',
      textColor: map['textColor'] ?? '#FFFFFF',
      backgroundColor: map['backgroundColor'] ?? '#000000',
      stickers: List<StorySticker>.from(
        map['stickers']?.map((x) => StorySticker.fromMap(x)) ?? []
      ),
      music: map['music'] != null ? StoryMusic.fromMap(map['music']) : null,
      duration: map['duration']?.toInt() ?? 86400000,
      expiresAt: DateTime.parse(map['expiresAt'] ?? DateTime.now().toIso8601String()),
      viewers: List<StoryViewer>.from(
        map['viewers']?.map((x) => StoryViewer.fromMap(x)) ?? []
      ),
      viewsCount: map['viewsCount']?.toInt() ?? 0,
      privacy: map['privacy'] ?? 'public',
      isHighlight: map['isHighlight'] ?? false,
      highlightTitle: map['highlightTitle'] ?? '',
      reactions: List<StoryReaction>.from(
        map['reactions']?.map((x) => StoryReaction.fromMap(x)) ?? []
      ),
      replies: List<StoryReply>.from(
        map['replies']?.map((x) => StoryReply.fromMap(x)) ?? []
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory StoryModel.fromJson(String source) => StoryModel.fromMap(json.decode(source));

  String get mediaUrlFull {
    if (mediaUrl.isEmpty) return '';
    return mediaUrl.startsWith('http') 
        ? mediaUrl 
        : 'http://localhost:3001$mediaUrl';
  }

  bool get isExpired {
    return !isHighlight && DateTime.now().isAfter(expiresAt);
  }

  bool get isPhoto => content == 'photo';
  bool get isVideo => content == 'video';
  bool get isText => content == 'text';

  String get timeRemaining {
    if (isHighlight) return '';
    
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return 'Expired';
    
    final difference = expiresAt.difference(now);
    if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inSeconds}s';
    }
  }

  bool hasViewedBy(String userId) {
    return viewers.any((viewer) => viewer.userId == userId);
  }

  @override
  String toString() {
    return 'StoryModel(id: $id, creator: ${creator.username}, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is StoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class StoryGroup {
  final UserModel user;
  final List<StoryModel> stories;
  final bool hasUnviewed;
  final DateTime latestStory;

  StoryGroup({
    required this.user,
    required this.stories,
    required this.hasUnviewed,
    required this.latestStory,
  });

  factory StoryGroup.fromMap(Map<String, dynamic> map) {
    return StoryGroup(
      user: UserModel.fromMap(map['user'] ?? {}),
      stories: List<StoryModel>.from(
        map['stories']?.map((x) => StoryModel.fromMap(x)) ?? []
      ),
      hasUnviewed: map['hasUnviewed'] ?? false,
      latestStory: DateTime.parse(map['latestStory'] ?? DateTime.now().toIso8601String()),
    );
  }

  int get unviewedCount {
    return stories.where((story) => !story.hasViewedBy('')).length; // Should check with current user ID
  }

  StoryModel? get latestStoryModel {
    if (stories.isEmpty) return null;
    return stories.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
  }
}