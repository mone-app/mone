import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? profileImage;
  final String? displayName;
  final Function() onTap;
  final double radius;

  const ProfileImagePicker({
    super.key,
    required this.profileImage,
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
          CircleAvatar(
            radius: radius,
            backgroundImage:
                profileImage != null
                    ? FileImage(profileImage!) as ImageProvider
                    : null,
            child:
                profileImage == null
                    ? Text(
                      displayName != null && displayName!.isNotEmpty
                          ? displayName![0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2),
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
  final String? displayName;
  final Function(File?) onImageSelected;

  const ProfileImagePickerSection({
    super.key,
    required this.profileImage,
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
        displayName: displayName,
        onTap: _pickImage,
      ),
    );
  }
}
