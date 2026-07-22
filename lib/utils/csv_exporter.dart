// CSV export utility for expenses with all required columns.

import 'package:csv/csv.dart';
import '../models/expense.dart';
import '../models/group_split.dart';
import '../models/expense_group.dart';
import '../models/user.dart';
import 'currency_formatter.dart';
import 'date_formatter.dart';

class CsvExporter {
  CsvExporter._();

  /// Export expenses to CSV string with columns:
  /// Date, Description, Category, Payment Method, Amount, Group Name, Payer, Current User Share
  static String exportExpenses({
    required List<Expense> expenses,
    required Map<String, ExpenseGroup> groups,
    required Map<String, User> users,
    required Map<String, List<GroupSplit>> splitsByExpense,
    required String currentUserId,
  }) {
    final rows = <List<dynamic>>[];

    // Header row
    rows.add([
      'Date',
      'Description',
      'Category',
      'Payment Method',
      'Amount',
      'Group Name',
      'Payer',
      'Current User Share',
    ]);

    for (final expense in expenses) {
      final groupName =
          expense.groupId != null ? (groups[expense.groupId]?.name ?? '') : '';

      final payerName = expense.payerUserId != null
          ? (users[expense.payerUserId]?.name ?? '')
          : '';

      double currentUserShare = expense.amount;
      if (expense.isGroupExpense && splitsByExpense.containsKey(expense.id)) {
        final splits = splitsByExpense[expense.id]!;
        final userSplit =
            splits.where((s) => s.userId == currentUserId).toList();
        if (userSplit.isNotEmpty) {
          currentUserShare = userSplit.first.shareAmount;
        } else {
          currentUserShare = 0;
        }
      }

      rows.add([
        DateFormatter.formatDateOnly(expense.dateTime),
        expense.note ?? '',
        expense.category,
        expense.paymentMethod,
        CurrencyFormatter.formatWithoutSymbol(expense.amount),
        groupName,
        payerName,
        CurrencyFormatter.formatWithoutSymbol(currentUserShare),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
