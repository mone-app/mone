import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mone/widgets/profile_avatar.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? profileImage;
  final String? avatarPath;
  final String? displayName;
  final Function() onTap;
  final double radius;

  const ProfileImagePicker({
    super.key,
    this.profileImage,
    this.avatarPath,
    required this.onTap,
    this.displayName,
    this.radius = 50,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ProfileAvatar(
            profileImage: profileImage,
            avatarPath: avatarPath,
            displayName: displayName,
            size: radius * 2, // ProfileAvatar uses diameter, not radius
            showBorder: false, // We'll handle our own styling
            showShadow: false,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileImagePickerSection extends StatelessWidget {
  final File? profileImage;
  final String? avatarPath;
  final String? displayName;
  final Function(File?) onImageSelected;

  const ProfileImagePickerSection({
    super.key,
    this.profileImage,
    this.avatarPath,
    required this.onImageSelected,
    this.displayName,
  });

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      onImageSelected(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ProfileImagePicker(
        profileImage: profileImage,
        avatarPath: avatarPath,
        displayName: displayName,
        onTap: _pickImage,
      ),
    );
  }
}
