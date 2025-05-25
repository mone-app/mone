// lib/features/profile/screens/search_friend_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/providers/api_provider.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/features/profile/widgets/search_bar.dart';
import 'package:mone/features/profile/widgets/search_result.dart';

class SearchFriendScreen extends ConsumerStatefulWidget {
  final UserEntity currentUser;

  const SearchFriendScreen({super.key, required this.currentUser});

  @override
  ConsumerState<SearchFriendScreen> createState() => _SearchFriendScreenState();
}

class _SearchFriendScreenState extends ConsumerState<SearchFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Future<void> _addFriend(UserEntity userToAdd) async {
    try {
      final currentUserData = ref.read(userProvider);
      if (currentUserData == null) return;

      final updatedUser = currentUserData.copyWith(
        friend: [...currentUserData.friend, userToAdd.id],
        updatedAt: DateTime.now(),
      );

      await ref.read(userProvider.notifier).upsertUser(updatedUser);
      final notification = ref.watch(notificationApiProvider);
      await notification.sendAddFriendNotification(
        targetUserId: userToAdd.id,
        fromUserId: currentUserData.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${userToAdd.name} as friend!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding friend: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeFriend(UserEntity userToRemove) async {
    try {
      final currentUserData = ref.read(userProvider);
      if (currentUserData == null) return;

      final updatedFriendList =
          currentUserData.friend
              .where((friendId) => friendId != userToRemove.id)
              .toList();

      final updatedUser = currentUserData.copyWith(
        friend: updatedFriendList,
        updatedAt: DateTime.now(),
      );

      await ref.read(userProvider.notifier).upsertUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${userToRemove.name} from friends'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing friend: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allUsersAsync = ref.watch(allUsersStreamProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: CustomSearchBar(
          controller: _searchController,
          isSearching: _isSearching,
          onToggleSearch: _toggleSearch,
          onSearchChanged: _onSearchChanged,
          colorScheme: colorScheme,
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SearchResults(
        isSearching: _isSearching,
        searchQuery: _searchQuery,
        allUsersAsync: allUsersAsync,
        onAddFriend: _addFriend,
        onRemoveFriend: _removeFriend,
      ),
    );
  }
}
