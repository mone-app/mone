import 'package:flutter/material.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final double spacing;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) ...[icon!, SizedBox(height: spacing)],
        Image.asset(
          'assets/logo/logo-source.png',
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: spacing),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
