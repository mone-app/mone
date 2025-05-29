// lib/features/profile/widgets/profile_settings.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mone/core/themes/app_color.dart';
import 'package:mone/features/profile/widgets/profile_section_header.dart';
import 'package:mone/features/profile/widgets/theme_selection_dialog.dart';
import 'package:mone/widgets/confirmation_dialog.dart';
import 'package:mone/main.dart';

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
        color: AppColors.containerSurface(context),
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

class ProfileSettingsSection extends StatefulWidget {
  const ProfileSettingsSection({super.key});

  @override
  State<ProfileSettingsSection> createState() => _ProfileSettingsSectionState();
}

class _ProfileSettingsSectionState extends State<ProfileSettingsSection> {
  @override
  void initState() {
    super.initState();
    themeService.addListener(_onThemeChanged);
    notificationSettingsService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeService.removeListener(_onThemeChanged);
    notificationSettingsService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

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

        // Theme Settings - Now functional!
        ProfileSettingItem(
          icon: themeService.themeIcon,
          title: "Theme",
          value: themeService.themeName,
          onTap: () => _showThemeDialog(context),
        ),

        ProfileSettingItem(
          icon: Icons.notifications_outlined,
          title: "Notifications",
          value: notificationSettingsService.notificationStatus,
          onTap: () => _showNotificationSettings(context),
        ),

        ProfileSettingItem(
          icon: Icons.help_outline,
          title: "Help & Support",
          value: "Contact us",
          onTap: () => _showHelpSettings(context),
        ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ThemeSelectionDialog(themeService: themeService),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    _showSettingDialog(
      context,
      "Notification Permissions",
      "Give us access to notifications so we can notify you about important updates, transactions, and activities",
      Icons.notifications_outlined,
      () {
        notificationSettingsService.requestNotificationPermissions();
      },
    );
  }

  void _showHelpSettings(BuildContext context) {
    _showSettingDialog(
      context,
      "Help & Support",
      "For technical support, feature requests, or to report issues, please contact our support team at mone@support.com. We typically respond within 24 hours.",
      Icons.help_outline,
      () {},
    );
  }

  void _showSettingDialog(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    FutureOr<void> Function() onConfirm,
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
            onConfirm: onConfirm,
          ),
    );
  }
}
