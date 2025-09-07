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
  final bool isDraggable;

  StorySticker({
    required this.type,
    this.url,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0.0,
    this.isDraggable = true,
  });

  StorySticker copyWith({
    String? type,
    String? url,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    bool? isDraggable,
  }) {
    return StorySticker(
      type: type ?? this.type,
      url: url ?? this.url,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      isDraggable: isDraggable ?? this.isDraggable,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'url': url,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
      'isDraggable': isDraggable,
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
      isDraggable: map['isDraggable'] ?? true,
    );
  }
}

class StoryTextElement {
  final String text;
  final double x;
  final double y;
  final double fontSize;
  final String color;
  final String fontFamily;
  final double rotation;
  final bool isDraggable;

  StoryTextElement({
    required this.text,
    required this.x,
    required this.y,
    this.fontSize = 24.0,
    this.color = '#FFFFFF',
    this.fontFamily = 'Inter',
    this.rotation = 0.0,
    this.isDraggable = true,
  });

  StoryTextElement copyWith({
    String? text,
    double? x,
    double? y,
    double? fontSize,
    String? color,
    String? fontFamily,
    double? rotation,
    bool? isDraggable,
  }) {
    return StoryTextElement(
      text: text ?? this.text,
      x: x ?? this.x,
      y: y ?? this.y,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      fontFamily: fontFamily ?? this.fontFamily,
      rotation: rotation ?? this.rotation,
      isDraggable: isDraggable ?? this.isDraggable,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'x': x,
      'y': y,
      'fontSize': fontSize,
      'color': color,
      'fontFamily': fontFamily,
      'rotation': rotation,
      'isDraggable': isDraggable,
    };
  }

  factory StoryTextElement.fromMap(Map<String, dynamic> map) {
    return StoryTextElement(
      text: map['text'] ?? '',
      x: map['x']?.toDouble() ?? 0.0,
      y: map['y']?.toDouble() ?? 0.0,
      fontSize: map['fontSize']?.toDouble() ?? 24.0,
      color: map['color'] ?? '#FFFFFF',
      fontFamily: map['fontFamily'] ?? 'Inter',
      rotation: map['rotation']?.toDouble() ?? 0.0,
      isDraggable: map['isDraggable'] ?? true,
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

class StoryLayoutElement {
  final String type; // 'text', 'sticker', 'media'
  final String id;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final int zIndex;

  StoryLayoutElement({
    required this.type,
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0.0,
    this.zIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'id': id,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
      'zIndex': zIndex,
    };
  }

  factory StoryLayoutElement.fromMap(Map<String, dynamic> map) {
    return StoryLayoutElement(
      type: map['type'] ?? '',
      id: map['id'] ?? '',
      x: map['x']?.toDouble() ?? 0.0,
      y: map['y']?.toDouble() ?? 0.0,
      width: map['width']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 0.0,
      rotation: map['rotation']?.toDouble() ?? 0.0,
      zIndex: map['zIndex']?.toInt() ?? 0,
    );
  }
}

class StoryLayout {
  final List<StoryLayoutElement> elements;

  StoryLayout({
    this.elements = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'elements': elements.map((x) => x.toMap()).toList(),
    };
  }

  factory StoryLayout.fromMap(Map<String, dynamic> map) {
    return StoryLayout(
      elements: List<StoryLayoutElement>.from(
        map['elements']?.map((x) => StoryLayoutElement.fromMap(x)) ?? []
      ),
    );
  }
}

class StoryMention {
  final String userId;
  final String username;
  final double x;
  final double y;

  StoryMention({
    required this.userId,
    required this.username,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'x': x,
      'y': y,
    };
  }

  factory StoryMention.fromMap(Map<String, dynamic> map) {
    return StoryMention(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      x: map['x']?.toDouble() ?? 0.0,
      y: map['y']?.toDouble() ?? 0.0,
    );
  }
}

class StoryModel {
  final String id;
  final UserModel creator;
  final String content; // 'photo', 'video', 'text'
  final String mediaUrl;
  final String thumbnailUrl;
  final String text;
  final String textColor;
  final String backgroundColor;
  final List<StorySticker> stickers;
  final List<StoryTextElement> textElements;
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
  final List<String> hashtags;
  final List<StoryMention> mentions;
  final StoryLayout layout;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoryModel({
    required this.id,
    required this.creator,
    required this.content,
    this.mediaUrl = '',
    this.thumbnailUrl = '',
    this.text = '',
    this.textColor = '#FFFFFF',
    this.backgroundColor = '#000000',
    this.stickers = const [],
    this.textElements = const [],
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
    this.hashtags = const [],
    this.mentions = const [],
    required this.layout,
    required this.createdAt,
    required this.updatedAt,
  });

  StoryModel copyWith({
    String? id,
    UserModel? creator,
    String? content,
    String? mediaUrl,
    String? thumbnailUrl,
    String? text,
    String? textColor,
    String? backgroundColor,
    List<StorySticker>? stickers,
    List<StoryTextElement>? textElements,
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
    List<String>? hashtags,
    List<StoryMention>? mentions,
    StoryLayout? layout,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      creator: creator ?? this.creator,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      text: text ?? this.text,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      stickers: stickers ?? this.stickers,
      textElements: textElements ?? this.textElements,
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
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      layout: layout ?? this.layout,
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
      'thumbnailUrl': thumbnailUrl,
      'text': text,
      'textColor': textColor,
      'backgroundColor': backgroundColor,
      'stickers': stickers.map((x) => x.toMap()).toList(),
      'textElements': textElements.map((x) => x.toMap()).toList(),
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
      'hashtags': hashtags,
      'mentions': mentions.map((x) => x.toMap()).toList(),
      'layout': layout.toMap(),
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
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      text: map['text'] ?? '',
      textColor: map['textColor'] ?? '#FFFFFF',
      backgroundColor: map['backgroundColor'] ?? '#000000',
      stickers: List<StorySticker>.from(
        map['stickers']?.map((x) => StorySticker.fromMap(x)) ?? []
      ),
      textElements: List<StoryTextElement>.from(
        map['textElements']?.map((x) => StoryTextElement.fromMap(x)) ?? []
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
      hashtags: List<String>.from(map['hashtags'] ?? []),
      mentions: List<StoryMention>.from(
        map['mentions']?.map((x) => StoryMention.fromMap(x)) ?? []
      ),
      layout: map['layout'] != null 
          ? StoryLayout.fromMap(map['layout']) 
          : StoryLayout(),
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

  String get thumbnailUrlFull {
    if (thumbnailUrl.isEmpty) return '';
    return thumbnailUrl.startsWith('http') 
        ? thumbnailUrl 
        : 'http://localhost:3001$thumbnailUrl';
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