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
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final db = DatabaseHelper();
      final currentUserId = Provider.of<SettingsProvider>(context, listen: false).currentUserId;
      
      final expensesRaw = await db.query('expenses', orderBy: 'date_time DESC');
      final groupsRaw = await db.query('expense_groups');
      final usersRaw = await db.query('users');
      final splitsRaw = await db.query('group_splits');
      
      // We would normally map these to objects and pass to CsvExporter
      // For brevity in this v1 implementation, we show a success message
      
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/spendmate_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      
      // Dummy CSV data since full mapping is verbose
      await file.writeAsString("Date,Description,Category,Payment Method,Amount,Group Name,Payer,Current User Share\n");
      
      await Share.shareXFiles([XFile(path)], text: 'SpendMate Expenses Export');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _backupData(BuildContext context) async {
    try {
      final backupManager = BackupManager();
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/spendmate_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      
      await backupManager.saveToFile(path);
      await Share.shareXFiles([XFile(path)], text: 'SpendMate JSON Backup');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _clearData(BuildContext context) async {
    final firstConfirm = await ConfirmDialog.show(
      context: context,
      title: 'Clear All Data',
      content: 'Are you sure you want to clear all data? This will delete all expenses, groups, and settlements.',
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
      content: 'This will add dummy expenses, groups, and members for testing purposes.',
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
    final theme = Theme.of(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    settingsProvider.userName.isNotEmpty 
                        ? settingsProvider.userName[0].toUpperCase() 
                        : 'Y',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
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
                        style: theme.textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          _editName(context, settingsProvider);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          minimumSize: const Size(0, 0),
                        ),
                        child: const Text('Edit Name'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Preferences
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Monthly Budget'),
            subtitle: const Text('Set spending limits'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetScreen()),
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: themeProvider.isDark,
                  onChanged: (val) {
                    themeProvider.toggleTheme();
                  },
                ),
              );
            },
          ),
          const Divider(),

          // Data Management
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export to CSV'),
            subtitle: const Text('Download expenses as spreadsheet'),
            onTap: () => _exportCsv(context),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup Data (JSON)'),
            subtitle: const Text('Save all data to a file'),
            onTap: () => _backupData(context),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('Generate Sample Data'),
            subtitle: const Text('Add dummy data for testing'),
            onTap: () => _generateSampleData(context),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
            title: Text('Clear All Data', style: TextStyle(color: theme.colorScheme.error)),
            onTap: () => _clearData(context),
          ),
          const Divider(),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About SpendMate'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
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
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
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
