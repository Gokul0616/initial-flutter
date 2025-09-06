import 'dart:convert';
import 'user_model.dart';

class CommentModel {
  final String id;
  final String text;
  final UserModel user;
  final int likesCount;
  final int repliesCount;
  final bool isLiked;
  final List<String> mentions;
  final String? parentComment;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentModel({
    required this.id,
    required this.text,
    required this.user,
    required this.likesCount,
    required this.repliesCount,
    required this.isLiked,
    required this.mentions,
    this.parentComment,
    required this.createdAt,
    required this.updatedAt,
  });

  CommentModel copyWith({
    String? id,
    String? text,
    UserModel? user,
    int? likesCount,
    int? repliesCount,
    bool? isLiked,
    List<String>? mentions,
    String? parentComment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      text: text ?? this.text,
      user: user ?? this.user,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      isLiked: isLiked ?? this.isLiked,
      mentions: mentions ?? this.mentions,
      parentComment: parentComment ?? this.parentComment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'user': user.toMap(),
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'isLiked': isLiked,
      'mentions': mentions,
      'parentComment': parentComment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      user: UserModel.fromMap(map['user'] ?? {}),
      likesCount: map['likesCount']?.toInt() ?? 0,
      repliesCount: map['repliesCount']?.toInt() ?? 0,
      isLiked: map['isLiked'] ?? false,
      mentions: List<String>.from(map['mentions'] ?? []),
      parentComment: map['parentComment'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentModel.fromJson(String source) => CommentModel.fromMap(json.decode(source));

  String get likesCountText {
    if (likesCount >= 1000000) {
      return '${(likesCount / 1000000).toStringAsFixed(1)}M';
    } else if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}K';
    }
    return likesCount.toString();
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  bool get isReply => parentComment != null;

  @override
  String toString() {
    return 'CommentModel(id: $id, text: $text, user: ${user.username}, likesCount: $likesCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CommentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}