import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/group_provider.dart';
import '../../database/database_helper.dart';
import '../../widgets/confirm_dialog.dart';
import '../../utils/csv_exporter.dart';
import '../../utils/backup_manager.dart';
import '../../utils/sample_data.dart';
import '../budget/budget_screen.dart';
import '../bank_accounts_screen.dart';
import 'notification_access_screen.dart';
import 'about_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/neobrutal/neobrutal_toggle.dart';
import '../../widgets/neobrutal/neobrutal_text_field.dart';
import '../../widgets/neobrutal/neobrutal_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final db = DatabaseHelper();
      final currentUserId =
          Provider.of<SettingsProvider>(context, listen: false).currentUserId;

      final expensesRaw = await db.query('expenses', orderBy: 'date_time DESC');
      final groupsRaw = await db.query('expense_groups');
      final usersRaw = await db.query('users');
      final splitsRaw = await db.query('group_splits');

      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/spendmate_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);

      await file.writeAsString(
          "Date,Description,Category,Payment Method,Amount,Group Name,Payer,Current User Share\n");

      await Share.shareXFiles([XFile(path)], text: 'SpendMate Expenses Export');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _backupData(BuildContext context) async {
    try {
      final backupManager = BackupManager();
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/spendmate_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      await backupManager.saveToFile(path);
      await Share.shareXFiles([XFile(path)], text: 'SpendMate JSON Backup');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _clearData(BuildContext context) async {
    final firstConfirm = await ConfirmDialog.show(
      context: context,
      title: 'Clear All Data',
      content:
          'Are you sure you want to clear all data? This will delete all expenses, groups, and settlements.',
      confirmText: 'Next',
      isDestructive: true,
    );

    if (firstConfirm == true && context.mounted) {
      final secondConfirm = await ConfirmDialog.show(
        context: context,
        title: 'Final Confirmation',
        content: 'This action is irreversible. Are you absolutely sure?',
        confirmText: 'Clear Everything',
        isDestructive: true,
      );

      if (secondConfirm == true && context.mounted) {
        final db = DatabaseHelper();
        await db.clearAllData();
        await db.clearFinancialData();

        if (context.mounted) {
          Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
          Provider.of<GroupProvider>(context, listen: false).loadGroups();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data cleared successfully.')),
          );
        }
      }
    }
  }

  Future<void> _generateSampleData(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Generate Sample Data',
      content:
          'This will add dummy expenses, groups, and members for testing purposes.',
      confirmText: 'Generate',
    );

    if (confirmed == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await SampleData.generate();
        if (context.mounted) {
          Navigator.pop(context); // close dialog
          Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
          Provider.of<GroupProvider>(context, listen: false).loadGroups();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sample data generated!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // ─── Header ──────────────────────────────
          Text('Settings', style: AppTextStyles.pageHeading(isDark)),
          const SizedBox(height: 20),

          // ─── Profile ─────────────────────────────
          NeoBrutalCard(
            backgroundColor: AppColors.getCardAccentColors(isDark)[0],
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.getBorder(isDark), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      settingsProvider.userName.isNotEmpty
                          ? settingsProvider.userName[0].toUpperCase()
                          : 'Y',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settingsProvider.userName,
                        style: AppTextStyles.sectionHeading(isDark),
                      ),
                      GestureDetector(
                        onTap: () => _editName(context, settingsProvider),
                        child: Text(
                          'Edit Name',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Preferences ─────────────────────────
          Text('Preferences', style: AppTextStyles.sectionHeading(isDark)),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            isDark: isDark,
            icon: Icons.account_balance_outlined,
            title: 'Bank Accounts',
            subtitle: 'Manage linked accounts',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BankAccountsScreen()));
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            isDark: isDark,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Monthly Budget',
            subtitle: 'Set spending limits',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BudgetScreen()));
            },
          ),
          const SizedBox(height: 8),
          
          // Income Detection Toggle
          NeoBrutalCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.getBorder(isDark), width: 1.5),
                  ),
                  child: Icon(Icons.notifications_active_outlined,
                      color: AppColors.accentTeal, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Auto Income Detection',
                          style: AppTextStyles.cardTitle(isDark)),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationAccessScreen()));
                        },
                        child: Text(
                          'Manage Access',
                          style: AppTextStyles.bodySmall(isDark).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalToggle(
                  value: settingsProvider.enableIncomeDetection,
                  onChanged: (val) {
                    settingsProvider.toggleIncomeDetection(val);
                    if (val) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationAccessScreen()));
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return NeoBrutalCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.getBorder(isDark), width: 1.5),
                      ),
                      child: Icon(Icons.dark_mode_outlined,
                          color: AppColors.getTextPrimary(isDark), size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Dark Mode',
                          style: AppTextStyles.cardTitle(isDark)),
                    ),
                    NeoBrutalToggle(
                      value: themeProvider.isDark,
                      onChanged: (val) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // ─── Data Management ─────────────────────
          Text('Data Management', style: AppTextStyles.sectionHeading(isDark)),
          const SizedBox(height: 12),
          _buildSettingsTile(context,
              isDark: isDark,
              icon: Icons.download_outlined,
              title: 'Export to CSV',
              subtitle: 'Download expenses as spreadsheet',
              onTap: () => _exportCsv(context)),
          const SizedBox(height: 8),
          _buildSettingsTile(context,
              isDark: isDark,
              icon: Icons.backup_outlined,
              title: 'Backup Data (JSON)',
              subtitle: 'Save all data to a file',
              onTap: () => _backupData(context)),
          const SizedBox(height: 8),
          _buildSettingsTile(context,
              isDark: isDark,
              icon: Icons.auto_awesome,
              title: 'Generate Sample Data',
              subtitle: 'Add dummy data for testing',
              onTap: () => _generateSampleData(context)),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            isDark: isDark,
            icon: Icons.delete_forever_outlined,
            title: 'Clear All Data',
            subtitle: null,
            onTap: () => _clearData(context),
            isDestructive: true,
          ),
          const SizedBox(height: 24),

          // ─── About ───────────────────────────────
          _buildSettingsTile(
            context,
            isDark: isDark,
            icon: Icons.info_outline,
            title: 'About SpendMate',
            subtitle: null,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive ? AppColors.error : AppColors.getTextPrimary(isDark);

    return NeoBrutalCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppColors.error.withOpacity(0.15)
                  : AppColors.accentPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.getBorder(isDark), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        AppTextStyles.cardTitle(isDark).copyWith(color: color)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall(isDark)),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: AppColors.getTextSecondary(isDark), size: 20),
        ],
      ),
    );
  }

  void _editName(BuildContext context, SettingsProvider provider) {
    final controller = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: NeoBrutalTextField(
          controller: controller,
          labelText: 'Name',
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.updateUserName(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
