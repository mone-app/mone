// lib/data/entities/user_entity.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mone/data/entities/transaction_entity.dart';

class UserEntity {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? profilePicture;
  final double balance;
  final List<String> bill;
  final List<String> friend;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? fcmToken;

  UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.profilePicture,
    required this.balance,
    required this.bill,
    required this.friend,
    required this.createdAt,
    this.updatedAt,
    this.fcmToken,
  });

  factory UserEntity.fromMap(String id, Map<String, dynamic> map) {
    return UserEntity(
      id: id,
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profilePicture: map['profilePicture'],
      balance: (map['balance'] ?? 0.0).toDouble(),
      bill: List<String>.from(map['bill'] ?? []),
      friend: List<String>.from(map['friend'] ?? []),
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      fcmToken: map['fcmToken'],

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
      'balance': balance,
      'bill': bill,
      'friend': friend,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'fcmToken': fcmToken,
    };
  }

  UserEntity copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? profilePicture,
    double? balance,
    List<String>? bill,
    List<String>? friend,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fcmToken,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      balance: balance ?? this.balance,
      bill: bill ?? this.bill,
      friend: friend ?? this.friend,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  // Utility functions

  /// Get the number of friends
  int get friendCount => friend.length;

  /// Check if user has friends
  bool get hasFriends => friend.isNotEmpty;

  /// Check if a specific user is a friend
  bool isFriend(String userId) => friend.contains(userId);

  /// Get the number of bills
  int get billCount => bill.length;

  /// Check if user has bills
  bool get hasBills => bill.isNotEmpty;

  /// Check if user has FCM token for notifications
  bool get hasNotificationToken => fcmToken != null && fcmToken!.isNotEmpty;
}
