import 'dart:convert';

class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String profilePicture;
  final String coverImage;
  final int followersCount;
  final int followingCount;
  final int likesCount;
  final int videosCount;
  final bool isVerified;
  final bool isPrivate;
  final bool? isFollowing;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.profilePicture,
    required this.coverImage,
    required this.followersCount,
    required this.followingCount,
    required this.likesCount,
    required this.videosCount,
    required this.isVerified,
    required this.isPrivate,
    this.isFollowing,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? bio,
    String? profilePicture,
    String? coverImage,
    int? followersCount,
    int? followingCount,
    int? likesCount,
    int? videosCount,
    bool? isVerified,
    bool? isPrivate,
    bool? isFollowing,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      coverImage: coverImage ?? this.coverImage,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      likesCount: likesCount ?? this.likesCount,
      videosCount: videosCount ?? this.videosCount,
      isVerified: isVerified ?? this.isVerified,
      isPrivate: isPrivate ?? this.isPrivate,
      isFollowing: isFollowing ?? this.isFollowing,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'bio': bio,
      'profilePicture': profilePicture,
      'coverImage': coverImage,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'likesCount': likesCount,
      'videosCount': videosCount,
      'isVerified': isVerified,
      'isPrivate': isPrivate,
      'isFollowing': isFollowing,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      displayName: map['displayName'] ?? '',
      bio: map['bio'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      coverImage: map['coverImage'] ?? '',
      followersCount: map['followersCount']?.toInt() ?? 0,
      followingCount: map['followingCount']?.toInt() ?? 0,
      likesCount: map['likesCount']?.toInt() ?? 0,
      videosCount: map['videosCount']?.toInt() ?? 0,
      isVerified: map['isVerified'] ?? false,
      isPrivate: map['isPrivate'] ?? false,
      isFollowing: map['isFollowing'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

  String get profileImageUrl {
    if (profilePicture.isEmpty) return '';
    return profilePicture.startsWith('http') 
        ? profilePicture 
        : 'http://localhost:3001$profilePicture';
  }

  String get coverImageUrl {
    if (coverImage.isEmpty) return '';
    return coverImage.startsWith('http') 
        ? coverImage 
        : 'http://localhost:3001$coverImage';
  }

  String get followersCountText {
    if (followersCount >= 1000000) {
      return '${(followersCount / 1000000).toStringAsFixed(1)}M';
    } else if (followersCount >= 1000) {
      return '${(followersCount / 1000).toStringAsFixed(1)}K';
    }
    return followersCount.toString();
  }

  String get followingCountText {
    if (followingCount >= 1000000) {
      return '${(followingCount / 1000000).toStringAsFixed(1)}M';
    } else if (followingCount >= 1000) {
      return '${(followingCount / 1000).toStringAsFixed(1)}K';
    }
    return followingCount.toString();
  }

  String get likesCountText {
    if (likesCount >= 1000000) {
      return '${(likesCount / 1000000).toStringAsFixed(1)}M';
    } else if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}K';
    }
    return likesCount.toString();
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, displayName: $displayName, followersCount: $followersCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.id == id &&
      other.username == username &&
      other.displayName == displayName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      username.hashCode ^
      displayName.hashCode;
  }
}