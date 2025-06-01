// lib/features/bill/create_split_bill_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/controllers/bill_controller.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/models/category_model.dart';
import 'package:mone/data/models/participant_model.dart';
import 'package:mone/data/providers/bill_provider.dart';
import 'package:mone/data/providers/user_provider.dart';

class CreateSplitBillScreen extends ConsumerStatefulWidget {
  const CreateSplitBillScreen({super.key});

  @override
  ConsumerState<CreateSplitBillScreen> createState() => _CreateSplitBillScreenState();
}

class _CreateSplitBillScreenState extends ConsumerState<CreateSplitBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  CategoryModel? _selectedCategory;
  List<UserEntity> _selectedFriends = [];
  List<ParticipantModel> _participants = [];
  bool _isEvenSplit = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);
    final allUsersAsync = ref.watch(allUsersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Split Bill'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _canCreateBill() ? _createBill : null,
              child: const Text('Create'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bill Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Bill Title *',
                  hintText: 'e.g., Dinner at Restaurant',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a bill title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bill Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add more details about the bill',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Total Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Total Amount *',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the total amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onChanged: (_) => _recalculateSplit(),
              ),
              const SizedBox(height: 16),

              // Category Selection
              DropdownButtonFormField<CategoryModel>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items:
                    CategoryModel.getExpenseCategories().map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(category.icon, size: 20),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

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
                        () => _showAddParticipantsDialog(allUsersAsync, currentUser),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Friends'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Current User (always included)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(currentUser?.name.substring(0, 1).toUpperCase() ?? 'U'),
                  ),
                  title: Text(currentUser?.name ?? 'You'),
                  subtitle: const Text('Bill Creator (You)'),
                  trailing: Text(
                    _participants.isNotEmpty
                        ? '\$${_participants.first.splitAmount.toStringAsFixed(2)}'
                        : '\$0.00',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Selected Friends
              ..._selectedFriends.map((friend) {
                final participant = _participants.firstWhere(
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
                    leading: CircleAvatar(
                      child: Text(friend.name.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(friend.name),
                    subtitle: Text('@${friend.username}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isEvenSplit)
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              initialValue: participant.splitAmount.toString(),
                              decoration: const InputDecoration(
                                prefixText: '\$',
                                isDense: true,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              onChanged:
                                  (value) => _updateParticipantAmount(friend.id, value),
                            ),
                          )
                        else
                          Text(
                            '\$${participant.splitAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        IconButton(
                          onPressed: () => _removeParticipant(friend),
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              if (_selectedFriends.isNotEmpty) ...[
                const SizedBox(height: 16),

                // Split Type Toggle
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Split Method',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('Split Evenly'),
                                value: true,
                                groupValue: _isEvenSplit,
                                onChanged: (value) {
                                  setState(() {
                                    _isEvenSplit = value!;
                                    _recalculateSplit();
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('Custom Split'),
                                value: false,
                                groupValue: _isEvenSplit,
                                onChanged: (value) {
                                  setState(() {
                                    _isEvenSplit = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Split Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Split Summary',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Total Participants: ${_participants.length}'),
                        Text('Total Amount: \$${_getTotalAmount().toStringAsFixed(2)}'),
                        Text('Split Total: \$${_getSplitTotal().toStringAsFixed(2)}'),
                        if (_getSplitTotal() != _getTotalAmount())
                          Text(
                            'Remaining: \$${(_getTotalAmount() - _getSplitTotal()).toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAddParticipantsDialog(
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
                      !_selectedFriends.any(
                        (selected) => selected.id == user.id,
                      ), // Prevent duplicates
                )
                .toList();

        // Create a local copy to manage checkbox states within the dialog
        List<UserEntity> tempSelectedFriends = List.from(_selectedFriends);

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
                            setState(() {
                              _selectedFriends = tempSelectedFriends;
                            });
                            _recalculateSplit();
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

  void _removeParticipant(UserEntity friend) {
    setState(() {
      _selectedFriends.removeWhere((f) => f.id == friend.id);
      _participants.removeWhere((p) => p.userId == friend.id);
      _recalculateSplit();
    });
  }

  void _updateParticipantAmount(String userId, String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0.0;
    setState(() {
      final index = _participants.indexWhere((p) => p.userId == userId);
      if (index != -1) {
        _participants[index] = _participants[index].copyWith(splitAmount: amount);
      }
    });
  }

  void _recalculateSplit() {
    if (!mounted) return;

    final currentUser = ref.read(userProvider);
    if (currentUser == null) return;

    final totalAmount = _getTotalAmount();
    if (totalAmount <= 0) {
      setState(() {
        _participants.clear();
      });
      return;
    }

    // Create participants list including current user
    final allParticipants = [currentUser, ..._selectedFriends];

    if (_isEvenSplit) {
      // Calculate even split with no remainder
      final splitAmounts = BillController.calculateEvenSplit(
        totalAmount,
        allParticipants.length,
      );

      setState(() {
        _participants =
            allParticipants.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;

              return ParticipantModel(
                userId: user.id,
                name: user.name,
                profilePictureUrl: user.profilePicture,
                splitAmount: splitAmounts[index],
                isSettled:
                    user.id ==
                    currentUser.id, // Current user is already "settled" as payer
              );
            }).toList();
      });
    } else {
      // For custom split, maintain existing amounts or set to 0
      setState(() {
        _participants =
            allParticipants.map((user) {
              final existing =
                  _participants.where((p) => p.userId == user.id).firstOrNull;

              return ParticipantModel(
                userId: user.id,
                name: user.name,
                profilePictureUrl: user.profilePicture,
                splitAmount: existing?.splitAmount ?? 0.0,
                isSettled: user.id == currentUser.id,
              );
            }).toList();
      });
    }
  }

  double _getTotalAmount() {
    return double.tryParse(_amountController.text) ?? 0.0;
  }

  double _getSplitTotal() {
    return _participants.fold(0.0, (sum, p) => sum + p.splitAmount);
  }

  bool _canCreateBill() {
    if (_isLoading) return false;
    if (_titleController.text.trim().isEmpty) return false;
    if (_selectedCategory == null) return false;
    if (_getTotalAmount() <= 0) return false;
    if (_selectedFriends.isEmpty) return false;

    // For custom split, ensure total matches
    if (!_isEvenSplit) {
      final splitTotal = _getSplitTotal();
      final totalAmount = _getTotalAmount();
      if ((splitTotal - totalAmount).abs() > 0.01)
        return false; // Allow small rounding differences
    }

    return true;
  }

  Future<void> _createBill() async {
    if (!_formKey.currentState!.validate() || !_canCreateBill()) return;

    final currentUser = ref.read(userProvider);
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(billProvider.notifier)
          .createSplitBill(
            payerId: currentUser.id,
            title: _titleController.text.trim(),
            description:
                _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
            totalAmount: _getTotalAmount(),
            category: _selectedCategory!,
            participants: _participants,
            date: DateTime.now(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Split bill created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating bill: $e'), backgroundColor: Colors.red),
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
}
