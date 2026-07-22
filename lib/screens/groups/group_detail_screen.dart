import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/group_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/neobrutal/neobrutal_card.dart';
import '../../widgets/neobrutal/neobrutal_button.dart';
import '../../widgets/neobrutal/neobrutal_icon_button.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/category_icon.dart';
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

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GroupProvider>(context, listen: false)
          .loadActiveGroupDetails(widget.groupId);
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
      content:
          'Are you sure you want to delete this group? All group expenses and settlements will be permanently deleted.',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Consumer2<GroupProvider, SettingsProvider>(
      builder: (context, groupProvider, settingsProvider, child) {
        if (groupProvider.isLoading || groupProvider.activeGroup == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
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
              NeoBrutalIconButton(
                icon: Icons.edit,
                size: 18,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateGroupScreen(groupToEdit: group),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              NeoBrutalIconButton(
                icon: Icons.delete,
                size: 18,
                iconColor: AppColors.error,
                onPressed: _deleteGroup,
              ),
              const SizedBox(width: 8),
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
              NeoBrutalCard(
                borderRadius: 0,
                borderWidth: 0,
                backgroundColor: isSettled
                    ? AppColors.getCardAccentColors(isDark)[4]
                    : (isOwed
                        ? AppColors.getCardAccentColors(isDark)[4]
                        : AppColors.getCardAccentColors(isDark)[5]),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      isSettled
                          ? 'You are all settled up in this group'
                          : (isOwed ? 'You are owed' : 'You owe'),
                      style: AppTextStyles.cardTitle(isDark),
                    ),
                    if (!isSettled) ...[
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(balanceAmount),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color:
                              isOwed ? AppColors.accentGreen : AppColors.error,
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
                    _buildExpensesTab(groupProvider, isDark),
                    _buildBalancesTab(groupProvider, settingsProvider, isDark),
                    _buildSettlementsTab(groupProvider, isDark),
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
                    child: NeoBrutalButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SettleUpScreen(groupId: group.id),
                          ),
                        );
                      },
                      backgroundColor: AppColors.getSurface(isDark),
                      child: Text('Settle Up',
                          style: AppTextStyles.buttonText(
                              color: AppColors.getTextPrimary(isDark))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NeoBrutalButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddGroupExpenseScreen(groupId: group.id),
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

  Widget _buildExpensesTab(GroupProvider provider, bool isDark) {
    if (provider.activeGroupExpenses.isEmpty) {
      return Center(
          child: Text('No expenses yet.', style: AppTextStyles.body(isDark)));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: provider.activeGroupExpenses.length,
      itemBuilder: (context, index) {
        final expense = provider.activeGroupExpenses[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: NeoBrutalCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ExpenseDetailScreen(expenseId: expense.id),
                ),
              ).then((_) {
                if (mounted) {
                  provider.loadActiveGroupDetails(widget.groupId);
                }
              });
            },
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CategoryIcon(category: expense.category, size: 20, padding: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.note?.isNotEmpty == true
                            ? expense.note!
                            : expense.category,
                        style: AppTextStyles.cardTitle(isDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormatter.formatExpenseDate(expense.dateTime),
                        style: AppTextStyles.bodySmall(isDark),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(expense.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalancesTab(
      GroupProvider provider, SettingsProvider settings, bool isDark) {
    final users = provider.activeGroupUsers;
    final balances = provider.activeGroupBalances;
    final suggestions = provider.settlementSuggestions;
    final currentUserId = settings.currentUserId;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Member Balances', style: AppTextStyles.sectionHeading(isDark)),
        const SizedBox(height: 16),
        ...users.map((user) {
          final balance = balances[user.id] ?? 0.0;
          final isSettled = balance.abs() < 0.01;

          Color color = AppColors.getTextSecondary(isDark);
          String subText = 'Settled up';

          if (!isSettled) {
            if (balance > 0) {
              color = AppColors.accentGreen;
              subText = 'gets back ${CurrencyFormatter.format(balance.abs())}';
            } else {
              color = AppColors.error;
              subText = 'owes ${CurrencyFormatter.format(balance.abs())}';
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.getBorder(isDark), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.id == currentUserId ? 'You' : user.name,
                          style: AppTextStyles.cardTitle(isDark),
                        ),
                        Text(subText,
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(height: 2, color: AppColors.getBorder(isDark)),
          const SizedBox(height: 16),
          Text('Suggested Settlements',
              style: AppTextStyles.sectionHeading(isDark)),
          const SizedBox(height: 16),
          ...suggestions.map((suggestion) {
            final fromUser = users.firstWhere(
                (u) => u.id == suggestion.fromUserId,
                orElse: () => users.first);
            final toUser = users.firstWhere((u) => u.id == suggestion.toUserId,
                orElse: () => users.first);

            final fromName =
                fromUser.id == currentUserId ? 'You' : fromUser.name;
            final toName = toUser.id == currentUserId ? 'You' : toUser.name;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NeoBrutalCard(
                backgroundColor: AppColors.getCardAccentColors(isDark)[2],
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.compare_arrows, color: AppColors.primary),
                  title: Text('$fromName pays $toName',
                      style: AppTextStyles.cardTitle(isDark)),
                  trailing: Text(
                    CurrencyFormatter.format(suggestion.amount),
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ),
            );
          }),
        ]
      ],
    );
  }

  Widget _buildSettlementsTab(GroupProvider provider, bool isDark) {
    if (provider.activeGroupSettlements.isEmpty) {
      return Center(
          child:
              Text('No settlements yet.', style: AppTextStyles.body(isDark)));
    }

    final users = provider.activeGroupUsers;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: provider.activeGroupSettlements.length,
      itemBuilder: (context, index) {
        final settlement = provider.activeGroupSettlements[index];
        final fromUser = users.firstWhere(
            (u) => u.id == settlement.paidByUserId,
            orElse: () => users.first);
        final toUser = users.firstWhere((u) => u.id == settlement.paidToUserId,
            orElse: () => users.first);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.getBorder(isDark), width: 1.5),
                  ),
                  child: Icon(Icons.handshake,
                      color: AppColors.accentGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${fromUser.name} paid ${toUser.name}',
                          style: AppTextStyles.cardTitle(isDark)),
                      const SizedBox(height: 2),
                      Text(DateFormatter.formatFull(settlement.dateTime),
                          style: AppTextStyles.bodySmall(isDark)),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(settlement.amount),
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.getTextPrimary(isDark)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
