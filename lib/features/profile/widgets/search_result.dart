// lib/features/profile/widgets/friend_search_results.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/widgets/profile_avatar.dart';

class SearchResults extends ConsumerWidget {
  final bool isSearching;
  final String searchQuery;
  final AsyncValue<List<UserEntity>> allUsersAsync;
  final Function(UserEntity) onAddFriend;
  final Function(UserEntity) onRemoveFriend;

  const SearchResults({
    super.key,
    required this.isSearching,
    required this.searchQuery,
    required this.allUsersAsync,
    required this.onAddFriend,
    required this.onRemoveFriend,
  });

  bool _isFriend(String userId, WidgetRef ref) {
    final currentUserData = ref.watch(userProvider);
    if (currentUserData == null) return false;
    return currentUserData.friend.contains(userId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return allUsersAsync.when(
      data: (users) {
        final currentUserData = ref.watch(userProvider);
        if (currentUserData == null) return const SizedBox();

        List<UserEntity> displayUsers;

        if (!isSearching || searchQuery.isEmpty) {
          // Show friends list when not searching
          displayUsers =
              users
                  .where((user) => currentUserData.friend.contains(user.id))
                  .toList();

          if (displayUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No friends yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start typing to search for new friends',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }
        } else {
          // Filter users based on search query
          final filteredUsers =
              users.where((user) {
                // Exclude current user
                if (user.id == currentUserData.id) return false;

                // Check if name or username matches search query
                final nameMatch = user.name.toLowerCase().contains(searchQuery);
                final usernameMatch = user.username.toLowerCase().contains(
                  searchQuery,
                );

                return nameMatch || usernameMatch;
              }).toList();

          if (filteredUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          // Sort filtered users: friends first, then non-friends
          displayUsers = _sortUsersByFriendStatus(
            filteredUsers,
            currentUserData,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: displayUsers.length,
          itemBuilder: (context, index) {
            final user = displayUsers[index];
            return _buildUserCard(context, user, ref);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) => Center(
            child: Text(
              'Error loading users: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
    );
  }

  List<UserEntity> _sortUsersByFriendStatus(
    List<UserEntity> users,
    UserEntity currentUser,
  ) {
    final friends = <UserEntity>[];
    final nonFriends = <UserEntity>[];

    for (final user in users) {
      if (currentUser.friend.contains(user.id)) {
        friends.add(user);
      } else {
        nonFriends.add(user);
      }
    }

    // Sort friends and non-friends alphabetically by name
    friends.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    nonFriends.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    // Return friends first, then non-friends
    return [...friends, ...nonFriends];
  }

  Widget _buildUserCard(BuildContext context, UserEntity user, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFriend = _isFriend(user.id, ref);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ProfileAvatar(
          avatarPath: user.profilePicture,
          displayName: user.name,
          size: 56,
        ),
        title: Text(
          user.username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: TextStyle(color: theme.colorScheme.primary, fontSize: 14),
            ),
            if (isFriend)
              Text(
                'Friend',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            if (isFriend) {
              onRemoveFriend(user);
            } else {
              onAddFriend(user);
            }
          },
          icon: Icon(
            isFriend ? Icons.person_remove_rounded : Icons.person_add_rounded,
            color:
                isFriend
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.primary,
            size: 24,
          ),
          style: IconButton.styleFrom(
            backgroundColor:
                isFriend
                    ? theme.colorScheme.tertiary.withOpacity(0.1)
                    : theme.colorScheme.primary.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
