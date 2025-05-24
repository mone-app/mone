import 'package:flutter/material.dart';
import 'package:mone/widgets/screen_header.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenHeader(
      title: 'Mone',
      subtitle: 'Share, settle, and stay connected.',
    );
  }
}

class PasswordResetHeader extends StatelessWidget {
  const PasswordResetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenHeader(
      title: 'Forgot your password?',
      subtitle:
          'Enter your email address and we\'ll send you instructions to reset your password.',
    );
  }
}
