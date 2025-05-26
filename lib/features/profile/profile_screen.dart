// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/features/profile/widgets/profile_header.dart';
import 'package:mone/features/profile/widgets/profile_info.dart';
import 'package:mone/features/profile/widgets/profile_logout_button.dart';
import 'package:mone/features/profile/widgets/profile_settings.dart';
import 'package:mone/features/profile/widgets/profile_stats.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final bool _isFriendsLoading = false;
  final bool _isBillsLoading = false;

  @override
  void initState() {
    super.initState();
    _handleUserFetch();
  }

  Future<void> _handleUserFetch() async {
    ref.read(userProvider.notifier).fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _buildProfileContent(context, user);
  }

  Widget _buildProfileContent(BuildContext context, UserEntity user) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Profile header with avatar, name, and username
          ProfileHeader(user: user),

          // Profile content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileStatsSection(
                    friendCount: user.friendCount,
                    billCount: user.billCount,
                    isFriendsLoading: _isFriendsLoading,
                    isBillsLoading: _isBillsLoading,
                  ),
                  const SizedBox(height: 24),
                  ProfileInfoSection(user: user),
                  const SizedBox(height: 24),
                  const ProfileSettingsSection(),
                  const SizedBox(height: 24),
                  const ProfileLogoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
