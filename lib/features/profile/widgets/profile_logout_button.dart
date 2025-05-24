// lib/features/profile/widgets/profile_logout_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/widgets/custom_button.dart';
import 'package:mone/widgets/confirmation_dialog.dart';

class ProfileLogoutButton extends ConsumerStatefulWidget {
  const ProfileLogoutButton({super.key});

  @override
  ConsumerState<ProfileLogoutButton> createState() =>
      _ProfileLogoutButtonState();
}

class _ProfileLogoutButtonState extends ConsumerState<ProfileLogoutButton> {
  bool _isLoading = false;

  Future<void> _showLogoutDialog() async {
    showDialog(
      context: context,
      builder:
          (ctx) => ConfirmationDialog(
            title: "Logout",
            description: "Are you sure you want to logout from your account?",
            confirmButtonText: "Logout",
            cancelButtonText: "Cancel",
            icon: Icons.logout,
            iconColor: Colors.red,
            onConfirm: _performLogout,
          ),
    );
  }

  Future<void> _performLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(userProvider.notifier).logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Logout',
      onPressed: _showLogoutDialog,
      isLoading: _isLoading,
      icon: Icons.logout,
    );
  }
}
