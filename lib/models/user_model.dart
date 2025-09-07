import 'dart:convert';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String bio;
  final String profilePicture;
  final String coverImage;
  final List<String> followers;
  final List<String> following;
  final int followersCount;
  final int followingCount;
  final int likesCount;
  final int videosCount;
  final bool isVerified;
  final bool isPrivate;
  final DateTime? lastActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.bio = '',
    this.profilePicture = '',
    this.coverImage = '',
    this.followers = const [],
    this.following = const [],
    this.followersCount = 0,
    this.followingCount = 0,
    this.likesCount = 0,
    this.videosCount = 0,
    this.isVerified = false,
    this.isPrivate = false,
    this.lastActive,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? bio,
    String? profilePicture,
    String? coverImage,
    List<String>? followers,
    List<String>? following,
    int? followersCount,
    int? followingCount,
    int? likesCount,
    int? videosCount,
    bool? isVerified,
    bool? isPrivate,
    DateTime? lastActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      coverImage: coverImage ?? this.coverImage,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      likesCount: likesCount ?? this.likesCount,
      videosCount: videosCount ?? this.videosCount,
      isVerified: isVerified ?? this.isVerified,
      isPrivate: isPrivate ?? this.isPrivate,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'profilePicture': profilePicture,
      'coverImage': coverImage,
      'followers': followers,
      'following': following,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'likesCount': likesCount,
      'videosCount': videosCount,
      'isVerified': isVerified,
      'isPrivate': isPrivate,
      'lastActive': lastActive?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? map['userId'] ?? map['_id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      bio: map['bio'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      coverImage: map['coverImage'] ?? '',
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      followersCount: map['followersCount']?.toInt() ?? 0,
      followingCount: map['followingCount']?.toInt() ?? 0,
      likesCount: map['likesCount']?.toInt() ?? 0,
      videosCount: map['videosCount']?.toInt() ?? 0,
      isVerified: map['isVerified'] ?? false,
      isPrivate: map['isPrivate'] ?? false,
      lastActive: map['lastActive'] != null 
          ? DateTime.parse(map['lastActive']) 
          : null,
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String()
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => 
      UserModel.fromMap(json.decode(source));

  String get profilePictureUrl {
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

  String get followersText {
    if (followersCount >= 1000000) {
      return '${(followersCount / 1000000).toStringAsFixed(1)}M';
    } else if (followersCount >= 1000) {
      return '${(followersCount / 1000).toStringAsFixed(1)}K';
    }
    return followersCount.toString();
  }

  String get followingText {
    if (followingCount >= 1000000) {
      return '${(followingCount / 1000000).toStringAsFixed(1)}M';
    } else if (followingCount >= 1000) {
      return '${(followingCount / 1000).toStringAsFixed(1)}K';
    }
    return followingCount.toString();
  }

  String get likesText {
    if (likesCount >= 1000000) {
      return '${(likesCount / 1000000).toStringAsFixed(1)}M';
    } else if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}K';
    }
    return likesCount.toString();
  }

  bool get isOnline {
    if (lastActive == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastActive!);
    return difference.inMinutes <= 5; // Online if active within 5 minutes
  }

  String get lastSeenText {
    if (lastActive == null) return 'Never';
    if (isOnline) return 'Online';
    
    final now = DateTime.now();
    final difference = now.difference(lastActive!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}