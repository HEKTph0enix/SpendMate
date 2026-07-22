import '../database/database_helper.dart';
import '../models/detected_transaction.dart';

class DetectedTransactionRepository {
  final DatabaseHelper _db = DatabaseHelper();
  static const _table = 'detected_transactions';

  Future<void> insertTransaction(DetectedTransaction tx) async {
    await _db.insert(_table, tx.toMap());
  }

  Future<void> updateStatus(String id, DetectionStatus status) async {
    await _db.update(
      _table,
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DetectedTransaction>> getPendingTransactions() async {
    final results = await _db.query(
      _table,
      where: 'status = ?',
      whereArgs: [DetectionStatus.pending.name],
      orderBy: 'timestamp DESC',
    );
    return results.map((m) => DetectedTransaction.fromMap(m)).toList();
  }

  Future<void> clearAll() async {
    await _db.delete(_table);
  }

  /// Checks if a very similar notification was already processed recently (within 5 minutes).
  /// Uses fingerprint which is: packageName + notificationId + amount + normalizedText
  Future<bool> isDuplicate(String fingerprint, DateTime timestamp) async {
    // 5 minutes ago
    final fiveMinsAgo = timestamp.subtract(const Duration(minutes: 5));
    
    final results = await _db.query(
      _table,
      where: 'fingerprint = ? AND timestamp >= ?',
      whereArgs: [fingerprint, fiveMinsAgo.toIso8601String()],
      limit: 1,
    );
    
    return results.isNotEmpty;
  }
}
