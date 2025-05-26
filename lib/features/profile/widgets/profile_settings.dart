// lib/features/profile/widgets/profile_settings.dart
import 'package:flutter/material.dart';
import 'package:mone/features/profile/widgets/profile_section_header.dart';
import 'package:mone/widgets/confirmation_dialog.dart';

class ProfileSettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const ProfileSettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeader(
          icon: Icons.settings_outlined,
          title: "Settings",
        ),

        const SizedBox(height: 16),

        // Settings options
        ProfileSettingItem(
          icon: Icons.dark_mode_outlined,
          title: "Theme",
          value: "Dark",
          onTap:
              () => _showSettingDialog(
                context,
                "Theme Settings",
                "Choose your preferred theme for the app.",
                Icons.dark_mode_outlined,
              ),
        ),

        ProfileSettingItem(
          icon: Icons.notifications_outlined,
          title: "Notifications",
          value: "Enabled",
          onTap:
              () => _showSettingDialog(
                context,
                "Notification Settings",
                "Manage how you receive notifications from the app.",
                Icons.notifications_outlined,
              ),
        ),

        ProfileSettingItem(
          icon: Icons.lock_outline,
          title: "Privacy",
          value: "Manage settings",
          onTap:
              () => _showSettingDialog(
                context,
                "Privacy Settings",
                "Control who can see your profile and projects.",
                Icons.lock_outline,
              ),
        ),

        ProfileSettingItem(
          icon: Icons.help_outline,
          title: "Help & Support",
          value: "Contact us",
          onTap:
              () => _showSettingDialog(
                context,
                "Help & Support",
                "Get assistance with using the app or report issues.",
                Icons.help_outline,
              ),
        ),
      ],
    );
  }

  void _showSettingDialog(
    BuildContext context,
    String title,
    String message,
    IconData icon,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => ConfirmationDialog(
            title: title,
            description: message,
            confirmButtonText: "OK",
            cancelButtonText: "Cancel",
            icon: icon,
            onConfirm: () {
              // This would contain actual functionality in a real implementation
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text("$title selected"),
              //     behavior: SnackBarBehavior.floating,
              //   ),
              // );
            },
          ),
    );
  }
}
