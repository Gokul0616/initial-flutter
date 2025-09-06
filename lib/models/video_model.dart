import 'dart:convert';
import 'user_model.dart';

class VideoModel {
  final String id;
  final UserModel user;
  final String caption;
  final String videoUrl;
  final String thumbnailUrl;
  final int duration;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final List<String> hashtags;
  final List<String> mentions;
  final MusicModel? music;
  final LocationModel? location;
  final bool isLiked;
  final bool allowComments;
  final bool allowDownload;
  final bool allowDuet;
  final DateTime createdAt;
  final DateTime updatedAt;

  VideoModel({
    required this.id,
    required this.user,
    required this.caption,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.viewsCount,
    required this.hashtags,
    required this.mentions,
    this.music,
    this.location,
    required this.isLiked,
    required this.allowComments,
    required this.allowDownload,
    required this.allowDuet,
    required this.createdAt,
    required this.updatedAt,
  });

  VideoModel copyWith({
    String? id,
    UserModel? user,
    String? caption,
    String? videoUrl,
    String? thumbnailUrl,
    int? duration,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    List<String>? hashtags,
    List<String>? mentions,
    MusicModel? music,
    LocationModel? location,
    bool? isLiked,
    bool? allowComments,
    bool? allowDownload,
    bool? allowDuet,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VideoModel(
      id: id ?? this.id,
      user: user ?? this.user,
      caption: caption ?? this.caption,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      music: music ?? this.music,
      location: location ?? this.location,
      isLiked: isLiked ?? this.isLiked,
      allowComments: allowComments ?? this.allowComments,
      allowDownload: allowDownload ?? this.allowDownload,
      allowDuet: allowDuet ?? this.allowDuet,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user.toMap(),
      'caption': caption,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'viewsCount': viewsCount,
      'hashtags': hashtags,
      'mentions': mentions,
      'music': music?.toMap(),
      'location': location?.toMap(),
      'isLiked': isLiked,
      'allowComments': allowComments,
      'allowDownload': allowDownload,
      'allowDuet': allowDuet,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] ?? '',
      user: UserModel.fromMap(map['user'] ?? {}),
      caption: map['caption'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      duration: map['duration']?.toInt() ?? 0,
      likesCount: map['likesCount']?.toInt() ?? 0,
      commentsCount: map['commentsCount']?.toInt() ?? 0,
      sharesCount: map['sharesCount']?.toInt() ?? 0,
      viewsCount: map['viewsCount']?.toInt() ?? 0,
      hashtags: List<String>.from(map['hashtags'] ?? []),
      mentions: List<String>.from(map['mentions'] ?? []),
      music: map['music'] != null ? MusicModel.fromMap(map['music']) : null,
      location: map['location'] != null ? LocationModel.fromMap(map['location']) : null,
      isLiked: map['isLiked'] ?? false,
      allowComments: map['allowComments'] ?? true,
      allowDownload: map['allowDownload'] ?? true,
      allowDuet: map['allowDuet'] ?? true,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory VideoModel.fromJson(String source) => VideoModel.fromMap(json.decode(source));

  String get fullVideoUrl {
    return videoUrl.startsWith('http') 
        ? videoUrl 
        : 'http://localhost:3001$videoUrl';
  }

  String get fullThumbnailUrl {
    if (thumbnailUrl.isEmpty) return '';
    return thumbnailUrl.startsWith('http') 
        ? thumbnailUrl 
        : 'http://localhost:3001$thumbnailUrl';
  }

  String get likesCountText {
    if (likesCount >= 1000000) {
      return '${(likesCount / 1000000).toStringAsFixed(1)}M';
    } else if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}K';
    }
    return likesCount.toString();
  }

  String get commentsCountText {
    if (commentsCount >= 1000000) {
      return '${(commentsCount / 1000000).toStringAsFixed(1)}M';
    } else if (commentsCount >= 1000) {
      return '${(commentsCount / 1000).toStringAsFixed(1)}K';
    }
    return commentsCount.toString();
  }

  String get sharesCountText {
    if (sharesCount >= 1000000) {
      return '${(sharesCount / 1000000).toStringAsFixed(1)}M';
    } else if (sharesCount >= 1000) {
      return '${(sharesCount / 1000).toStringAsFixed(1)}K';
    }
    return sharesCount.toString();
  }

  String get viewsCountText {
    if (viewsCount >= 1000000) {
      return '${(viewsCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewsCount >= 1000) {
      return '${(viewsCount / 1000).toStringAsFixed(1)}K';
    }
    return viewsCount.toString();
  }

  String get durationText {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'VideoModel(id: $id, caption: $caption, likesCount: $likesCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is VideoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class MusicModel {
  final String title;
  final String artist;
  final String url;
  final int duration;

  MusicModel({
    required this.title,
    required this.artist,
    required this.url,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'url': url,
      'duration': duration,
    };
  }

  factory MusicModel.fromMap(Map<String, dynamic> map) {
    return MusicModel(
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      url: map['url'] ?? '',
      duration: map['duration']?.toInt() ?? 0,
    );
  }
}

class LocationModel {
  final String name;
  final double latitude;
  final double longitude;

  LocationModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      name: map['name'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }
}