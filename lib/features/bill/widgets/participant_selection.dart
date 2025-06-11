// lib/features/bill/widgets/participant_selection_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/models/participant_model.dart';
import 'package:mone/data/providers/user_provider.dart';

class ParticipantSelection extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userProvider);
    final allUsersAsync = ref.watch(allUsersStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Participants Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Participants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed:
                  () => _showAddParticipantsDialog(context, allUsersAsync, currentUser),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Friends'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Current User (Payer)
        _buildPayerCard(currentUser),

        // Selected Friends
        ...selectedFriends.map((friend) => _buildParticipantCard(friend)),
      ],
    );
  }

  Widget _buildPayerCard(UserEntity? currentUser) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
            style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(currentUser?.name ?? 'You'),
        subtitle: const Text('Bill Creator (You)'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isEvenSplit && participants.isNotEmpty)
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: participants.first.splitAmount.toString(),
                  decoration: const InputDecoration(prefixText: '\$', isDense: true),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  onChanged:
                      (value) => onParticipantAmountChanged(currentUser?.id ?? '', value),
                ),
              )
            else
              Text(
                participants.isNotEmpty
                    ? participants.first.formattedSplitAmount
                    : 'Rp0,00',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Payer',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantCard(UserEntity friend) {
    final participant = participants.firstWhere(
      (p) => p.userId == friend.id,
      orElse:
          () => ParticipantModel(
            userId: friend.id,
            name: friend.name,
            splitAmount: 0.0,
            isSettled: false,
          ),
    );

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(friend.name.substring(0, 1).toUpperCase())),
        title: Text(friend.name),
        subtitle: Text('@${friend.username}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isEvenSplit)
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: participant.splitAmount.toString(),
                  decoration: const InputDecoration(prefixText: '\$', isDense: true),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  onChanged: (value) => onParticipantAmountChanged(friend.id, value),
                ),
              )
            else
              Text(
                participant.formattedSplitAmount,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            IconButton(
              onPressed: () => _removeParticipant(friend),
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _removeParticipant(UserEntity friend) {
    final updatedFriends = List<UserEntity>.from(selectedFriends);
    updatedFriends.removeWhere((f) => f.id == friend.id);
    onSelectedFriendsChanged(updatedFriends);
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
                      !selectedFriends.any((selected) => selected.id == user.id),
                )
                .toList();

        // Create a local copy to manage checkbox states within the dialog
        List<UserEntity> tempSelectedFriends = List.from(selectedFriends);

        showDialog(
          context: context,
          builder:
              (context) => StatefulBuilder(
                builder:
                    (context, setDialogState) => AlertDialog(
                      title: const Text('Add Friends'),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 300,
                        child:
                            friends.isEmpty
                                ? const Center(
                                  child: Text(
                                    'No more friends available.\nAll your friends are already added or add more friends first.',
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: friends.length,
                                  itemBuilder: (context, index) {
                                    final friend = friends[index];
                                    final isSelected = tempSelectedFriends.any(
                                      (f) => f.id == friend.id,
                                    );

                                    return CheckboxListTile(
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
                                      title: Text(friend.name),
                                      subtitle: Text('@${friend.username}'),
                                      secondary: CircleAvatar(
                                        child: Text(
                                          friend.name.substring(0, 1).toUpperCase(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            onSelectedFriendsChanged(tempSelectedFriends);
                            Navigator.pop(context);
                          },
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
                (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Loading friends...'),
                    ],
                  ),
                ),
          ),
      error:
          (error, _) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error loading friends: $error'))),
    );
  }
}
