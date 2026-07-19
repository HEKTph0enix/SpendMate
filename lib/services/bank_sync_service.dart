// Bank sync service — orchestrates bank data synchronization via BankDataProvider.
// Handles consent flow and updates financial account balances.

import '../models/financial_account.dart';
import '../repositories/financial_account_repository.dart';
import '../repositories/transaction_repository.dart';
import 'bank_data_provider.dart';

class BankSyncService {
  final FinancialAccountRepository _accountRepo;
  final TransactionRepository _transactionRepo;
  BankDataProvider _activeProvider;

  BankSyncService({
    FinancialAccountRepository? accountRepo,
    TransactionRepository? transactionRepo,
    BankDataProvider? provider,
  })  : _accountRepo = accountRepo ?? FinancialAccountRepository(),
        _transactionRepo = transactionRepo ?? TransactionRepository(),
        _activeProvider = provider ?? ManualBankDataProvider();

  BankDataProvider get activeProvider => _activeProvider;

  void setProvider(BankDataProvider provider) {
    _activeProvider = provider;
  }

  /// Sync balance for a specific account using the active provider.
  /// Returns true if sync was successful.
  Future<bool> syncAccountBalance(String accountId) async {
    try {
      if (!await _activeProvider.isConnected()) return false;

      final newBalance = await _activeProvider.fetchBalance(accountId);
      await _accountRepo.updateBalance(accountId, newBalance);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Sync transactions for a specific account.
  Future<int> syncTransactions(
    String accountId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      if (!await _activeProvider.isConnected()) return 0;

      final transactions = await _activeProvider.fetchTransactions(
        accountId,
        fromDate: fromDate,
        toDate: toDate,
      );

      if (transactions.isNotEmpty) {
        await _transactionRepo.importBulk(transactions);
      }
      return transactions.length;
    } catch (_) {
      return 0;
    }
  }

  /// Manually update an account's balance (used with ManualBankDataProvider).
  Future<void> manualBalanceUpdate(String accountId, double balance) async {
    await _accountRepo.updateBalance(accountId, balance);
  }

  /// Disconnect the active provider and deactivate the account.
  Future<void> disconnectAccount(String accountId) async {
    await _activeProvider.disconnect();
    await _accountRepo.deactivateAccount(accountId);
  }

  /// Get total balance across all active accounts.
  Future<double> getTotalBankBalance() async {
    return await _accountRepo.getTotalBankBalance();
  }

  /// Get all active financial accounts.
  Future<List<FinancialAccount>> getActiveAccounts() async {
    return await _accountRepo.getActiveAccounts();
  }
}
