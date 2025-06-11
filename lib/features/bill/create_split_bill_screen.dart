// lib/features/bill/create_split_bill_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/user_entity.dart';
import 'package:mone/data/models/category_model.dart';
import 'package:mone/data/models/participant_model.dart';
import 'package:mone/data/providers/bill_provider.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/features/bill/widgets/bill_form.dart';
import 'package:mone/features/bill/widgets/participant_selection.dart';
import 'package:mone/features/bill/widgets/split_method.dart';
import 'package:mone/data/controllers/bill_controller.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Form Section
            BillForm(
              formKey: _formKey,
              titleController: _titleController,
              descriptionController: _descriptionController,
              amountController: _amountController,
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              onAmountChanged: _recalculateSplit,
            ),
            const SizedBox(height: 24),

            // Participant Selection Section
            ParticipantSelection(
              selectedFriends: _selectedFriends,
              participants: _participants,
              isEvenSplit: _isEvenSplit,
              onSelectedFriendsChanged: (friends) {
                setState(() {
                  _selectedFriends = friends;
                });
                _recalculateSplit();
              },
              onParticipantAmountChanged: _updateParticipantAmount,
            ),

            // Split Method and Summary Section
            if (_selectedFriends.isNotEmpty) ...[
              const SizedBox(height: 16),
              SplitMethod(
                isEvenSplit: _isEvenSplit,
                onSplitMethodChanged: (isEven) {
                  setState(() {
                    _isEvenSplit = isEven;
                    if (isEven) {
                      _recalculateSplit();
                    }
                  });
                },
                totalAmount: _getTotalAmount(),
                splitTotal: _getSplitTotal(),
                participantCount: _participants.length,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateParticipantAmount(String userId, String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0.0;
    setState(() {
      final index = _participants.indexWhere((p) => p.userId == userId);
      if (index != -1) {
        _participants[index] = _participants[index].copyWith(splitAmount: amount);
      } else {
        // Handle case where current user isn't in participants yet
        final currentUser = ref.read(userProvider);
        if (currentUser != null && userId == currentUser.id) {
          _participants.insert(
            0,
            ParticipantModel(
              userId: currentUser.id,
              name: currentUser.name,
              profilePictureUrl: currentUser.profilePicture,
              splitAmount: amount,
              isSettled: true, // Payer is always "settled"
            ),
          );
        }
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
      if ((splitTotal - totalAmount).abs() > 0.01) {
        return false; // Allow small rounding differences
      }
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
