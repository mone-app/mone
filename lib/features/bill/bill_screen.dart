// lib/features/bill/bill_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mone/data/entities/bill_entity.dart';
import 'package:mone/data/enums/bill_status_enum.dart';
import 'package:mone/data/providers/bill_provider.dart';
import 'package:mone/data/providers/user_provider.dart';
import 'package:mone/features/bill/create_split_bill_screen.dart';
import 'package:mone/features/bill/bill_detail_screen.dart';
import 'package:mone/utils/currency_formatter.dart';

class BillScreen extends ConsumerStatefulWidget {
  const BillScreen({super.key});

  @override
  ConsumerState<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends ConsumerState<BillScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final billsAsync = ref.watch(billStreamProvider(currentUser.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bills'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Bills'),
            Tab(text: 'I Owe'),
            Tab(text: 'Owed to Me'),
          ],
        ),
      ),
      body: billsAsync.when(
        data: (bills) {
          // Update local state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(billProvider.notifier).setBills(bills);
          });

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllBillsTab(bills, currentUser.id),
              _buildIOweTab(bills, currentUser.id),
              _buildOwedToMeTab(bills, currentUser.id),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading bills: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(billStreamProvider(currentUser.id)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateSplitBillScreen()),
            ),
        icon: const Icon(Icons.add),
        label: const Text('Split Bill'),
      ),
    );
  }

  Widget _buildAllBillsTab(List<BillEntity> bills, String currentUserId) {
    if (bills.isEmpty) {
      return _buildEmptyState('No bills yet', 'Create your first split bill!');
    }

    // Sort bills by date (newest first)
    final sortedBills = List<BillEntity>.from(bills)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedBills.length,
      itemBuilder: (context, index) {
        final bill = sortedBills[index];
        return _buildBillCard(bill, currentUserId);
      },
    );
  }

  Widget _buildIOweTab(List<BillEntity> bills, String currentUserId) {
    // Bills where current user is a participant (not payer) and hasn't settled
    final oweBills =
        bills.where((bill) {
          if (bill.payerId == currentUserId) return false;
          final participant =
              bill.participants.where((p) => p.userId == currentUserId).firstOrNull;
          return participant != null;
        }).toList();

    if (oweBills.isEmpty) {
      return _buildEmptyState('All caught up!', 'You don\'t owe anyone money.');
    }

    oweBills.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: oweBills.length,
      itemBuilder: (context, index) {
        final bill = oweBills[index];
        return _buildBillCard(bill, currentUserId, showOwedAmount: true);
      },
    );
  }

  Widget _buildOwedToMeTab(List<BillEntity> bills, String currentUserId) {
    // Bills where current user is the payer and has unsettled participants
    final owedBills =
        bills.where((bill) {
          if (bill.payerId != currentUserId) return false;
          return bill.participants.any((p) => p.userId != currentUserId);
        }).toList();

    if (owedBills.isEmpty) {
      return _buildEmptyState('All settled!', 'Everyone has paid you back.');
    }

    owedBills.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: owedBills.length,
      itemBuilder: (context, index) {
        final bill = owedBills[index];
        return _buildBillCard(bill, currentUserId, showOwedToMeAmount: true);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(
    BillEntity bill,
    String currentUserId, {
    bool showOwedAmount = false,
    bool showOwedToMeAmount = false,
  }) {
    final isCreator = bill.payerId == currentUserId;
    final participant =
        bill.participants.where((p) => p.userId == currentUserId).firstOrNull;
    final isSettled = bill.status == BillStatusEnum.settled;

    // Calculate amounts
    double owedAmount = 0.0;
    double owedToMeAmount = 0.0;

    if (showOwedAmount && participant != null && !participant.isSettled) {
      owedAmount = participant.splitAmount;
    }

    if (showOwedToMeAmount && isCreator) {
      owedToMeAmount = bill.participants
          .where((p) => !p.isSettled && p.userId != currentUserId)
          .fold(0.0, (sum, p) => sum + p.splitAmount);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BillDetailScreen(bill: bill)),
            ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(bill.category.icon, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${_formatDate(bill.date)} • ${bill.category.name}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSettled ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isSettled ? 'Settled' : 'Active',
                      style: TextStyle(
                        color: isSettled ? Colors.green[800] : Colors.orange[800],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Amount Information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: ${bill.formattedAmount}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${bill.participantCount} participants',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  if (showOwedAmount)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'You owe',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          CurrencyFormatter.formatToRupiahWithDecimal(owedAmount),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  else if (showOwedToMeAmount)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Owed to you',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          CurrencyFormatter.formatToRupiahWithDecimal(owedToMeAmount),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isCreator ? 'You paid' : 'Your share',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          (participant?.formattedSplitAmount ?? 'Rp0,00'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Progress indicator for unsettled bills
              if (!isSettled) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: bill.totalSettledAmount / bill.amount,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${bill.settledParticipants.length}/${bill.participantCount}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
