// lib/features/profile/widgets/profile_avatar.dart
import 'package:flutter/material.dart';
import 'dart:io';

class ProfileAvatar extends StatelessWidget {
  final String? avatarPath;
  final File? profileImage;
  final String? displayName;
  final double size;
  final bool showBorder;
  final bool showShadow;

  const ProfileAvatar({
    super.key,
    this.avatarPath,
    this.profileImage,
    this.displayName,
    this.size = 80,
    this.showBorder = false,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;

    // Determine the background image
    ImageProvider? backgroundImage;
    if (profileImage != null) {
      backgroundImage = FileImage(profileImage!);
    } else if (avatarPath != null && avatarPath!.isNotEmpty) {
      backgroundImage = NetworkImage(avatarPath!);
    }

    // Generate letter for fallback
    String fallbackLetter = '?';
    if (displayName != null && displayName!.isNotEmpty) {
      fallbackLetter = displayName![0].toUpperCase();
    }

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundImage: backgroundImage,
      child:
          backgroundImage == null
              ? Text(
                fallbackLetter,
                style: TextStyle(
                  fontSize: size * 0.4, // Scale font size with avatar size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
              : null,
    );

    // Add container with border and shadow if needed
    if (showBorder || showShadow) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              showBorder
                  ? Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 3,
                  )
                  : null,
          boxShadow:
              showShadow
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                  : null,
        ),
        child: avatar,
      );
    }

    return avatar;
  }
}
