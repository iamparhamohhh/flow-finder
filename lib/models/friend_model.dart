// lib/models/friend_model.dart

import 'user_model.dart';

enum FriendshipStatus { none, pending, accepted, blocked }

class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final DateTime createdAt;
  final FriendshipStatus status;
  final UserModel? fromUser;
  final UserModel? toUser;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.createdAt,
    required this.status,
    this.fromUser,
    this.toUser,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      fromUserId: json['fromUserId'],
      toUserId: json['toUserId'],
      createdAt: DateTime.parse(json['createdAt']),
      status: FriendshipStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendshipStatus.none,
      ),
      fromUser: json['fromUser'] != null
          ? UserModel.fromJson(json['fromUser'])
          : null,
      toUser: json['toUser'] != null
          ? UserModel.fromJson(json['toUser'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'fromUser': fromUser?.toJson(),
      'toUser': toUser?.toJson(),
    };
  }
}

class Friendship {
  final String id;
  final String userId1;
  final String userId2;
  final DateTime createdAt;
  final UserModel? friend;

  Friendship({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.createdAt,
    this.friend,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'],
      userId1: json['userId1'],
      userId2: json['userId2'],
      createdAt: DateTime.parse(json['createdAt']),
      friend: json['friend'] != null
          ? UserModel.fromJson(json['friend'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'createdAt': createdAt.toIso8601String(),
      'friend': friend?.toJson(),
    };
  }
}
