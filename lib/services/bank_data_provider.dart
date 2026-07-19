// Abstract bank data provider interface.
// Designed as a plug-in point for future Account Aggregator or banking API integrations.
// The ManualBankDataProvider allows users to manually enter balances as a fallback.

import '../models/financial_account.dart';
import '../models/transaction.dart' as app;

/// Abstract interface for bank data synchronization.
/// Implement this for each data source (AA, bank API, etc.).
abstract class BankDataProvider {
  /// Unique identifier for this provider type.
  String get providerId;

  /// Human-readable name.
  String get providerName;

  /// Whether this provider is currently connected/authenticated.
  Future<bool> isConnected();

  /// Fetch the current balance for a specific account.
  Future<double> fetchBalance(String accountId);

  /// Fetch recent transactions for a specific account.
  Future<List<app.Transaction>> fetchTransactions(
    String accountId, {
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Disconnect/revoke access for this provider.
  Future<void> disconnect();
}

/// Manual bank data provider — user enters balances manually.
/// This is the default fallback when no API integration is available.
class ManualBankDataProvider implements BankDataProvider {
  @override
  String get providerId => 'manual';

  @override
  String get providerName => 'Manual Entry';

  @override
  Future<bool> isConnected() async => true; // Always available

  @override
  Future<double> fetchBalance(String accountId) async {
    // Manual provider doesn't fetch — balance is set by user input.
    throw UnsupportedError(
      'Manual provider does not fetch balances. Use direct balance update instead.',
    );
  }

  @override
  Future<List<app.Transaction>> fetchTransactions(
    String accountId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Manual provider doesn't fetch transactions.
    return [];
  }

  @override
  Future<void> disconnect() async {
    // Nothing to disconnect for manual entry.
  }
}

// ─── Placeholder for future Account Aggregator integration ──────────
//
// class AccountAggregatorProvider implements BankDataProvider {
//   // Implement using Setu AA or similar Indian AA framework.
//   // Requires: FI data consent flow, FIP registration, etc.
// }
