// lib/features/profile/widgets/profile_info.dart
import 'package:flutter/material.dart';
import 'package:mone/core/theme/app_color.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/features/profile/widgets/profile_section_header.dart';

class ProfileInfoItem {
  final IconData icon;
  final String label;
  final String value;

  ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class ProfileInfoCard extends StatelessWidget {
  final List<ProfileInfoItem> items;

  const ProfileInfoCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children:
            items.map((item) => _buildInfoRow(item, colorScheme)).toList(),
      ),
    );
  }

  Widget _buildInfoRow(ProfileInfoItem item, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileInfoSection extends StatelessWidget {
  final UserEntity user;

  const ProfileInfoSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeader(
          icon: Icons.person_outline,
          title: "Personal Information",
        ),
        const SizedBox(height: 16),
        ProfileInfoCard(
          items: [
            ProfileInfoItem(
              icon: Icons.email_outlined,
              label: "Email",
              value: user.email,
            ),
            ProfileInfoItem(
              icon: Icons.badge_outlined,
              label: "User ID",
              value: user.id,
            ),
            ProfileInfoItem(
              icon: Icons.wallet,
              label: "Balance",
              value: user.formattedBalance,
            ),
          ],
        ),
      ],
    );
  }
}
