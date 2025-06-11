// lib/data/models/participant_model.dart

import 'package:mone/utils/currency_formatter.dart';

class ParticipantModel {
  final String userId;
  final String name;
  final String? profilePictureUrl;
  final double splitAmount;
  final String? note;
  final String? paymentImageUrl;
  final bool isSettled;

  ParticipantModel({
    required this.userId,
    required this.name,
    this.profilePictureUrl,
    required this.splitAmount,
    this.note,
    this.paymentImageUrl,
    required this.isSettled,
  });

  // Convert ParticipantModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'splitAmount': splitAmount,
      'note': note,
      'paymentImageUrl': paymentImageUrl,
      'isSettled': isSettled,
    };
  }

  // Create ParticipantModel from Firebase Map
  factory ParticipantModel.fromMap(Map<String, dynamic> map) {
    return ParticipantModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
      splitAmount: (map['splitAmount'] ?? 0.0).toDouble(),
      note: map['note'],
      paymentImageUrl: map['paymentImageUrl'],
      isSettled: map['isSettled'] ?? false,
    );
  }

  // Create a copy with modified fields
  ParticipantModel copyWith({
    String? userId,
    String? name,
    String? profilePictureUrl,
    double? splitAmount,
    String? note,
    String? paymentImageUrl,
    bool? isSettled,
  }) {
    return ParticipantModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      splitAmount: splitAmount ?? this.splitAmount,
      note: note ?? this.note,
      paymentImageUrl: paymentImageUrl ?? this.paymentImageUrl,
      isSettled: isSettled ?? this.isSettled,
    );
  }

  // Mark participant as settled
  ParticipantModel settle() {
    return copyWith(isSettled: true);
  }

  // Mark participant as unsettled
  ParticipantModel unsettle() {
    return copyWith(isSettled: false);
  }

  @override
  String toString() {
    return 'ParticipantModel(userId: $userId, name: $name, profilePictureUrl: $profilePictureUrl, splitAmount: $splitAmount, note: $note, paymentImageUrl: $paymentImageUrl, isSettled: $isSettled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParticipantModel &&
        other.userId == userId &&
        other.name == name &&
        other.profilePictureUrl == profilePictureUrl &&
        other.splitAmount == splitAmount &&
        other.note == note &&
        other.paymentImageUrl == paymentImageUrl &&
        other.isSettled == isSettled;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        name.hashCode ^
        profilePictureUrl.hashCode ^
        splitAmount.hashCode ^
        note.hashCode ^
        paymentImageUrl.hashCode ^
        isSettled.hashCode;
  }

  String get formattedSplitAmount {
    return CurrencyFormatter.formatToRupiahWithDecimal(splitAmount);
  }
}
