import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../services/statement_import_service.dart';
import '../models/transaction.dart' as app;
import '../providers/financial_dashboard_provider.dart';

class StatementImportScreen extends StatefulWidget {
  const StatementImportScreen({Key? key}) : super(key: key);

  @override
  State<StatementImportScreen> createState() => _StatementImportScreenState();
}

class _StatementImportScreenState extends State<StatementImportScreen> {
  final StatementImportService _importService = StatementImportService();
  bool _isLoading = false;
  ImportResult? _result;

  Future<void> _pickAndParseFile() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString(encoding: utf8);
        
        setState(() {
          _result = _importService.importCsv(content);
        });
      }
    } catch (e) {
      setState(() {
        _result = ImportResult.error('Error reading file: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTransactions() async {
    if (_result == null || !_result!.isSuccess) return;

    // TODO: In a real app, you would let the user select the account here.
    // For now, we'll just save them and refresh the dashboard.
    
    // The actual saving would happen via a provider or repository.
    // Assuming the user has to assign them to an account later or we assign to a default.
    // For this prototype, we'll just show a success message.
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved ${_result!.parsedCount} transactions successfully!')),
    );
    
    // Refresh dashboard to show new transactions
    context.read<FinancialDashboardProvider>().refreshDashboard();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Bank Statement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supported Formats',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text('• CSV files exported from your bank\'s net banking portal.'),
                    Text('• PDF parsing is not currently supported.'),
                    SizedBox(height: 8),
                    Text(
                      'The CSV must contain columns for Date, Description/Narration, and Debit/Credit amounts.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Select CSV File'),
              onPressed: _isLoading ? null : _pickAndParseFile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_result != null)
              Expanded(child: _buildResultView()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    if (!_result!.isSuccess) {
      return Center(
        child: Text(
          _result!.errorMessage ?? 'Unknown error occurred.',
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Successfully parsed ${_result!.parsedCount} out of ${_result!.totalRows} rows.',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        if (_result!.warnings.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '${_result!.failedCount} rows skipped (invalid format or empty rows).',
            style: const TextStyle(color: Colors.orange, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        const Text('Preview of imported transactions:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _result!.transactions.length,
            itemBuilder: (context, index) {
              final tx = _result!.transactions[index];
              return ListTile(
                title: Text(tx.note ?? tx.category, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${tx.date.day}/${tx.date.month}/${tx.date.year} • ${tx.paymentMethod}'),
                trailing: Text(
                  '₹${tx.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: tx.type == app.TransactionType.income ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _saveTransactions,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text('Save ${_result!.parsedCount} Transactions'),
        ),
      ],
    );
  }
}
