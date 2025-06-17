// lib/features/bill/widgets/participant_selection.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/core/theme/app_color.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/models/participant_model.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/widgets/custom_input_field.dart';
import 'package:mone/widgets/profile_avatar.dart';

class ParticipantSelection extends ConsumerStatefulWidget {
  final List<UserEntity> selectedFriends;
  final List<ParticipantModel> participants;
  final bool isEvenSplit;
  final Function(List<UserEntity>) onSelectedFriendsChanged;
  final Function(String, String) onParticipantAmountChanged;

  const ParticipantSelection({
    super.key,
    required this.selectedFriends,
    required this.participants,
    required this.isEvenSplit,
    required this.onSelectedFriendsChanged,
    required this.onParticipantAmountChanged,
  });

  @override
  ConsumerState<ParticipantSelection> createState() =>
      _ParticipantSelectionState();
}

class _ParticipantSelectionState extends ConsumerState<ParticipantSelection> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String userId, double amount) {
    if (!_controllers.containsKey(userId)) {
      _controllers[userId] = TextEditingController(text: amount.toString());
    }

    // Update controller only if we're in even split mode (to show calculated amounts)
    if (widget.isEvenSplit) {
      final participant =
          widget.participants.where((p) => p.userId == userId).firstOrNull;
      if (participant != null) {
        _controllers[userId]!.text = participant.splitAmount.toString();
      }
    }

    return _controllers[userId]!;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);
    final allUsersAsync = ref.watch(allUsersStreamProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.group,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Participants',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Who should split this bill?',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAddButton(context, allUsersAsync, currentUser),
              ],
            ),
            const SizedBox(height: 20),

            // Current User (Payer)
            _buildPayerCard(currentUser, colorScheme),

            // Selected Friends
            if (widget.selectedFriends.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...widget.selectedFriends.map(
                (friend) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildParticipantCard(friend, colorScheme),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    AsyncValue<List<UserEntity>> allUsersAsync,
    UserEntity? currentUser,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              () => _showAddParticipantsDialog(
                context,
                allUsersAsync,
                currentUser,
              ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add, color: colorScheme.onPrimary, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPayerCard(UserEntity? currentUser, ColorScheme colorScheme) {
    final participant =
        widget.participants.isNotEmpty ? widget.participants.first : null;

    return Row(
      children: [
        Expanded(
          child: CustomInputField(
            controller: _getController(
              currentUser?.id ?? '',
              participant?.splitAmount ?? 0.0,
            ),
            labelText: "@${currentUser?.username} (Payer)",
            hintText: 'Enter amount',
            prefixIcon: Icons.attach_money,
            prefixText: "Rp ",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            isEnabled: !widget.isEvenSplit,
            onChanged:
                widget.isEvenSplit
                    ? null
                    : (value) => widget.onParticipantAmountChanged(
                      currentUser?.id ?? '',
                      value,
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantCard(UserEntity friend, ColorScheme colorScheme) {
    final participant = widget.participants.firstWhere(
      (p) => p.userId == friend.id,
      orElse:
          () => ParticipantModel(
            userId: friend.id,
            name: friend.name,
            splitAmount: 0.0,
            isSettled: false,
          ),
    );

    return Row(
      children: [
        Expanded(
          flex: 7,
          child: CustomInputField(
            controller: _getController(friend.id, participant.splitAmount),
            labelText: "@${friend.username}",
            hintText: 'Enter amount',
            prefixIcon: Icons.attach_money,
            prefixText: "Rp ",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            isEnabled: !widget.isEvenSplit,
            onChanged:
                widget.isEvenSplit
                    ? null
                    : (value) =>
                        widget.onParticipantAmountChanged(friend.id, value),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _removeParticipant(friend),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.close,
                    color: Colors.red.shade600,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _removeParticipant(UserEntity friend) {
    // Remove the controller when participant is removed
    _controllers.remove(friend.id);

    final updatedFriends = List<UserEntity>.from(widget.selectedFriends);
    updatedFriends.removeWhere((f) => f.id == friend.id);
    widget.onSelectedFriendsChanged(updatedFriends);
  }

  void _showAddParticipantsDialog(
    BuildContext context,
    AsyncValue<List<UserEntity>> allUsersAsync,
    UserEntity? currentUser,
  ) {
    allUsersAsync.when(
      data: (allUsers) {
        if (currentUser == null) return;

        // Filter to only show friends who are not already selected
        final friends =
            allUsers
                .where(
                  (user) =>
                      user.id != currentUser.id &&
                      currentUser.friend.contains(user.id) &&
                      !widget.selectedFriends.any(
                        (selected) => selected.id == user.id,
                      ),
                )
                .toList();

        // Create a local copy to manage checkbox states within the dialog
        List<UserEntity> tempSelectedFriends = List.from(
          widget.selectedFriends,
        );

        showDialog(
          context: context,
          builder:
              (context) => StatefulBuilder(
                builder:
                    (context, setDialogState) => AlertDialog(
                      backgroundColor: AppColors.containerSurface(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person_add,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Add Friends'),
                        ],
                      ),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 300,
                        child:
                            friends.isEmpty
                                ? _buildEmptyFriendsState(context)
                                : ListView.builder(
                                  itemCount: friends.length,
                                  itemBuilder: (context, index) {
                                    final friend = friends[index];
                                    final isSelected = tempSelectedFriends.any(
                                      (f) => f.id == friend.id,
                                    );

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.1)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest
                                                    .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.3)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .outline
                                                      .withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: CheckboxListTile(
                                        value: isSelected,
                                        onChanged: (value) {
                                          setDialogState(() {
                                            if (value == true) {
                                              if (!tempSelectedFriends.any(
                                                (f) => f.id == friend.id,
                                              )) {
                                                tempSelectedFriends.add(friend);
                                              }
                                            } else {
                                              tempSelectedFriends.removeWhere(
                                                (f) => f.id == friend.id,
                                              );
                                            }
                                          });
                                        },
                                        title: Text(
                                          friend.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '@${friend.username}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        secondary: ProfileAvatar(
                                          avatarPath: friend.profilePicture,
                                          displayName: friend.name,
                                          size: 32,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            widget.onSelectedFriendsChanged(
                              tempSelectedFriends,
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Add Selected'),
                        ),
                      ],
                    ),
              ),
        );
      },
      loading:
          () => showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: AppColors.containerSurface(context),
                  content: const Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Loading friends...'),
                    ],
                  ),
                ),
          ),
      error:
          (error, _) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading friends: $error')),
          ),
    );
  }

  Widget _buildEmptyFriendsState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_off,
              size: 32,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No friends available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All your friends are already added\nor add more friends first.',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
