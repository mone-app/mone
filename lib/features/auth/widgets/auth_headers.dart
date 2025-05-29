import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final double spacing;

  const AuthHeader({
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

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthHeader(
      title: 'Mone',
      subtitle: 'Share, settle, and stay connected.',
    );
  }
}

class PasswordResetHeader extends StatelessWidget {
  const PasswordResetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthHeader(
      title: 'Forgot your password?',
      subtitle:
          'Enter your email address and we\'ll send you instructions to reset your password.',
    );
  }
}
