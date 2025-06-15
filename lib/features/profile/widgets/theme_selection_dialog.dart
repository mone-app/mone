// lib/features/profile/widgets/theme_dialog.dart
import 'package:flutter/material.dart';
import 'package:mone/core/theme/theme_service.dart';
import 'package:mone/core/theme/app_color.dart';

class ThemeSelectionDialog extends StatelessWidget {
  final ThemeService themeService;

  const ThemeSelectionDialog({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.palette_outlined,
                size: 30,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Choose Theme',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Select your preferred theme for the app',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Theme options
            _ThemeOption(
              title: 'Light Theme',
              subtitle: 'Always use light theme',
              icon: Icons.light_mode_outlined,
              themeMode: ThemeMode.light,
              isSelected: themeService.themeMode == ThemeMode.light,
              onTap: () {
                themeService.setTheme(ThemeMode.light);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 12),

            _ThemeOption(
              title: 'Dark Theme',
              subtitle: 'Always use dark theme',
              icon: Icons.dark_mode_outlined,
              themeMode: ThemeMode.dark,
              isSelected: themeService.themeMode == ThemeMode.dark,
              onTap: () {
                themeService.setTheme(ThemeMode.dark);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 12),

            _ThemeOption(
              title: 'System Default',
              subtitle: 'Follow system theme',
              icon: Icons.settings_system_daydream_outlined,
              themeMode: ThemeMode.system,
              isSelected: themeService.themeMode == ThemeMode.system,
              onTap: () {
                themeService.setTheme(ThemeMode.system);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode themeMode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeMode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerSurface(context),
        borderRadius: BorderRadius.circular(12),
        border:
            isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isSelected
                            ? colorScheme.primary
                            : Colors.grey.shade600)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color:
                        isSelected ? colorScheme.primary : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? colorScheme.primary : null,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
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
