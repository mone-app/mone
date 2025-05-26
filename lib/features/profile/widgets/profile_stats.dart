// lib/features/profile/widgets/profile_stats.dart
import 'package:flutter/material.dart';

class ProfileStatItem extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const ProfileStatItem({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        isLoading
            ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
            : Text(
              count,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  static String formatCount(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }
}

class ProfileStatsSection extends StatelessWidget {
  final int friendCount;
  final int billCount;
  final bool isFriendsLoading;
  final bool isBillsLoading;

  const ProfileStatsSection({
    super.key,
    this.friendCount = 0,
    this.billCount = 0,
    this.isFriendsLoading = false,
    this.isBillsLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ProfileStatItem(
            count: ProfileStatItem.formatCount(friendCount),
            label: "Friends",
            icon: Icons.people_alt_outlined,
            color: colorScheme.primary,
            isLoading: isFriendsLoading,
          ),
          _buildDivider(),
          ProfileStatItem(
            count: ProfileStatItem.formatCount(billCount),
            label: "Bills",
            icon: Icons.receipt_long_outlined,
            color: colorScheme.secondary,
            isLoading: isBillsLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }
}
