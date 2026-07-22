// Statement import service for CSV bank statements.
// PDF parsing is stubbed — full PDF support would require a heavy dependency.

import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart' as app;

class StatementImportService {
  static const _uuid = Uuid();

  /// Import transactions from a CSV file content string.
  /// Returns a list of parsed transactions for user review before saving.
  ///
  /// Supports common Indian bank CSV formats:
  /// - Date, Description, Debit, Credit, Balance
  /// - Date, Narration, Withdrawal, Deposit, Balance
  ImportResult importCsv(String csvContent) {
    try {
      final rows = const CsvToListConverter().convert(csvContent, eol: '\n');
      if (rows.isEmpty) {
        return ImportResult.error('CSV file is empty.');
      }

      // Detect header row
      final headerRow =
          rows.first.map((e) => e.toString().toLowerCase().trim()).toList();
      final mapping = _detectColumnMapping(headerRow);

      if (mapping == null) {
        return ImportResult.error(
          'Could not detect CSV format. Expected columns: Date, Description/Narration, '
          'Debit/Withdrawal, Credit/Deposit.',
        );
      }

      final List<app.Transaction> transactions = [];
      final List<String> errors = [];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        try {
          final tx = _parseRow(row, mapping, i);
          if (tx != null) transactions.add(tx);
        } catch (e) {
          errors.add('Row $i: $e');
        }
      }

      return ImportResult.success(
        transactions: transactions,
        warnings: errors,
        totalRows: rows.length - 1,
      );
    } catch (e) {
      return ImportResult.error('Failed to parse CSV: $e');
    }
  }

  /// Stub for PDF import — returns a helpful message.
  ImportResult importPdf(List<int> pdfBytes) {
    return ImportResult.error(
      'PDF statement import is not yet supported. '
      'Please export your bank statement as CSV and try again.',
    );
  }

  _ColumnMapping? _detectColumnMapping(List<String> headers) {
    int? dateCol;
    int? descCol;
    int? debitCol;
    int? creditCol;

    for (int i = 0; i < headers.length; i++) {
      final h = headers[i];
      if (_matchesAny(h, [
        'date',
        'txn date',
        'transaction date',
        'value date',
        'posting date'
      ])) {
        dateCol ??= i;
      } else if (_matchesAny(h,
          ['description', 'narration', 'particulars', 'remarks', 'details'])) {
        descCol ??= i;
      } else if (_matchesAny(
          h, ['debit', 'withdrawal', 'withdrawals', 'debit amount', 'dr'])) {
        debitCol ??= i;
      } else if (_matchesAny(
          h, ['credit', 'deposit', 'deposits', 'credit amount', 'cr'])) {
        creditCol ??= i;
      }
    }

    if (dateCol != null && (debitCol != null || creditCol != null)) {
      return _ColumnMapping(
        date: dateCol,
        description: descCol ?? -1,
        debit: debitCol ?? -1,
        credit: creditCol ?? -1,
      );
    }
    return null;
  }

  bool _matchesAny(String value, List<String> candidates) {
    return candidates.any((c) => value.contains(c));
  }

  app.Transaction? _parseRow(
      List<dynamic> row, _ColumnMapping mapping, int rowIndex) {
    if (row.length <= mapping.date) return null;

    // Parse date
    final dateStr = row[mapping.date].toString().trim();
    final date = _parseDate(dateStr);
    if (date == null) return null;

    // Parse amounts
    double debitAmount = 0;
    double creditAmount = 0;

    if (mapping.debit >= 0 && mapping.debit < row.length) {
      debitAmount = _parseAmount(row[mapping.debit].toString()) ?? 0;
    }
    if (mapping.credit >= 0 && mapping.credit < row.length) {
      creditAmount = _parseAmount(row[mapping.credit].toString()) ?? 0;
    }

    // Skip rows with no amount
    if (debitAmount == 0 && creditAmount == 0) return null;

    // Determine type and amount
    final isCredit = creditAmount > 0;
    final amount = isCredit ? creditAmount : debitAmount;

    // Parse description
    String description = '';
    if (mapping.description >= 0 && mapping.description < row.length) {
      description = row[mapping.description].toString().trim();
    }

    return app.Transaction(
      id: _uuid.v4(),
      amount: amount,
      type: isCredit ? app.TransactionType.income : app.TransactionType.expense,
      category: isCredit ? 'Other Income' : 'Other',
      paymentMethod: _detectPaymentMethod(description),
      source: app.TransactionSource.import_,
      date: date,
      note: description.isEmpty ? null : description,
    );
  }

  DateTime? _parseDate(String dateStr) {
    // Try common Indian date formats
    final formats = [
      // DD/MM/YYYY, DD-MM-YYYY
      RegExp(r'^(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})$'),
      // YYYY-MM-DD (ISO)
      RegExp(r'^(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})$'),
      // DD/MM/YY
      RegExp(r'^(\d{1,2})[/\-](\d{1,2})[/\-](\d{2})$'),
    ];

    // DD/MM/YYYY or DD-MM-YYYY
    final match1 = formats[0].firstMatch(dateStr);
    if (match1 != null) {
      return DateTime.tryParse(
        '${match1.group(3)}-${match1.group(2)!.padLeft(2, '0')}-${match1.group(1)!.padLeft(2, '0')}',
      );
    }

    // YYYY-MM-DD
    final match2 = formats[1].firstMatch(dateStr);
    if (match2 != null) {
      return DateTime.tryParse(dateStr);
    }

    // DD/MM/YY
    final match3 = formats[2].firstMatch(dateStr);
    if (match3 != null) {
      final year = int.parse(match3.group(3)!);
      final fullYear = year < 50 ? 2000 + year : 1900 + year;
      return DateTime.tryParse(
        '$fullYear-${match3.group(2)!.padLeft(2, '0')}-${match3.group(1)!.padLeft(2, '0')}',
      );
    }

    // Fallback: try dart's native parser
    return DateTime.tryParse(dateStr);
  }

  double? _parseAmount(String raw) {
    if (raw.isEmpty || raw == '-' || raw == '--') return null;
    try {
      return double.parse(raw.replaceAll(',', '').replaceAll('"', '').trim());
    } catch (_) {
      return null;
    }
  }

  String _detectPaymentMethod(String description) {
    final lower = description.toLowerCase();
    if (lower.contains('upi') ||
        lower.contains('gpay') ||
        lower.contains('phonepe') ||
        lower.contains('paytm')) {
      return 'UPI';
    }
    if (lower.contains('neft') ||
        lower.contains('rtgs') ||
        lower.contains('imps')) {
      return 'Net Banking';
    }
    if (lower.contains('atm') || lower.contains('cash')) {
      return 'Cash';
    }
    if (lower.contains('card') || lower.contains('pos')) {
      return 'Card';
    }
    return 'Bank Transfer';
  }
}

class _ColumnMapping {
  final int date;
  final int description;
  final int debit;
  final int credit;

  _ColumnMapping({
    required this.date,
    required this.description,
    required this.debit,
    required this.credit,
  });
}

class ImportResult {
  final bool isSuccess;
  final List<app.Transaction> transactions;
  final List<String> warnings;
  final String? errorMessage;
  final int totalRows;

  ImportResult._({
    required this.isSuccess,
    this.transactions = const [],
    this.warnings = const [],
    this.errorMessage,
    this.totalRows = 0,
  });

  factory ImportResult.success({
    required List<app.Transaction> transactions,
    List<String> warnings = const [],
    int totalRows = 0,
  }) {
    return ImportResult._(
      isSuccess: true,
      transactions: transactions,
      warnings: warnings,
      totalRows: totalRows,
    );
  }

  factory ImportResult.error(String message) {
    return ImportResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }

  int get parsedCount => transactions.length;
  int get failedCount => totalRows - parsedCount;
}
