import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/group_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/confirm_dialog.dart';
import 'add_group_expense_screen.dart';
import 'create_group_screen.dart';
import 'settle_up_screen.dart';
import '../expenses/expense_detail_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GroupProvider>(context, listen: false).loadActiveGroupDetails(widget.groupId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteGroup() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Group',
      content: 'Are you sure you want to delete this group? All group expenses and settlements will be permanently deleted.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<GroupProvider>(context, listen: false);
      await provider.deleteGroup(widget.groupId);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<GroupProvider, SettingsProvider>(
      builder: (context, groupProvider, settingsProvider, child) {
        if (groupProvider.isLoading || groupProvider.activeGroup == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final group = groupProvider.activeGroup!;
        final balances = groupProvider.activeGroupBalances;
        final currentUserId = settingsProvider.currentUserId;
        final currentUserBalance = balances[currentUserId] ?? 0.0;
        
        final isSettled = currentUserBalance.abs() < 0.01;
        final isOwed = currentUserBalance > 0.01;
        final balanceAmount = currentUserBalance.abs();

        return Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateGroupScreen(groupToEdit: group),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteGroup,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Expenses'),
                Tab(text: 'Balances'),
                Tab(text: 'Settlements'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Group Header Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      isSettled ? 'You are all settled up in this group' : (isOwed ? 'You are owed' : 'You owe'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (!isSettled) ...[
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(balanceAmount),
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOwed ? Colors.green.shade600 : Colors.red.shade600,
                        ),
                      ),
                    ]
                  ],
                ),
              ),

              // Tabs Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildExpensesTab(groupProvider),
                    _buildBalancesTab(groupProvider, settingsProvider),
                    _buildSettlementsTab(groupProvider),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettleUpScreen(groupId: group.id),
                          ),
                        );
                      },
                      child: const Text('Settle Up'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddGroupExpenseScreen(groupId: group.id),
                          ),
                        );
                      },
                      child: const Text('Add Expense'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpensesTab(GroupProvider provider) {
    if (provider.activeGroupExpenses.isEmpty) {
      return const Center(child: Text('No expenses yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: provider.activeGroupExpenses.length,
      itemBuilder: (context, index) {
        final expense = provider.activeGroupExpenses[index];
        return ExpenseCard(
          expense: expense,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExpenseDetailScreen(expenseId: expense.id),
              ),
            ).then((_) {
              if (mounted) {
                provider.loadActiveGroupDetails(widget.groupId);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildBalancesTab(GroupProvider provider, SettingsProvider settings) {
    final theme = Theme.of(context);
    final users = provider.activeGroupUsers;
    final balances = provider.activeGroupBalances;
    final suggestions = provider.settlementSuggestions;
    final currentUserId = settings.currentUserId;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Member Balances', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        ...users.map((user) {
          final balance = balances[user.id] ?? 0.0;
          final isSettled = balance.abs() < 0.01;
          
          Color color = theme.colorScheme.onSurfaceVariant;
          String subText = 'Settled up';
          
          if (!isSettled) {
            if (balance > 0) {
              color = Colors.green.shade600;
              subText = 'gets back ${CurrencyFormatter.format(balance.abs())}';
            } else {
              color = Colors.red.shade600;
              subText = 'owes ${CurrencyFormatter.format(balance.abs())}';
            }
          }
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(user.name[0].toUpperCase()),
            ),
            title: Text(user.id == currentUserId ? 'You' : user.name),
            subtitle: Text(
              subText,
              style: TextStyle(color: color, fontWeight: isSettled ? FontWeight.normal : FontWeight.bold),
            ),
          );
        }),
        
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text('Suggested Settlements', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          ...suggestions.map((suggestion) {
            final fromUser = users.firstWhere((u) => u.id == suggestion.fromUserId, orElse: () => users.first);
            final toUser = users.firstWhere((u) => u.id == suggestion.toUserId, orElse: () => users.first);
            
            final fromName = fromUser.id == currentUserId ? 'You' : fromUser.name;
            final toName = toUser.id == currentUserId ? 'You' : toUser.name;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.compare_arrows, color: theme.colorScheme.primary),
                title: Text('$fromName pays $toName'),
                trailing: Text(
                  CurrencyFormatter.format(suggestion.amount),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ]
      ],
    );
  }

  Widget _buildSettlementsTab(GroupProvider provider) {
    if (provider.activeGroupSettlements.isEmpty) {
      return const Center(child: Text('No settlements yet.'));
    }

    final users = provider.activeGroupUsers;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: provider.activeGroupSettlements.length,
      itemBuilder: (context, index) {
        final settlement = provider.activeGroupSettlements[index];
        final fromUser = users.firstWhere((u) => u.id == settlement.paidByUserId, orElse: () => users.first);
        final toUser = users.firstWhere((u) => u.id == settlement.paidToUserId, orElse: () => users.first);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.handshake),
            title: Text('${fromUser.name} paid ${toUser.name}'),
            subtitle: Text(DateFormatter.formatFull(settlement.dateTime)),
            trailing: Text(
              CurrencyFormatter.format(settlement.amount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
