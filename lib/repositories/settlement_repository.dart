// Repository for settlement CRUD operations.

import '../database/database_helper.dart';
import '../models/settlement.dart';

class SettlementRepository {
  final DatabaseHelper _db = DatabaseHelper();
  static const _table = 'settlements';

  Future<void> insertSettlement(Settlement settlement) async {
    await _db.insert(_table, settlement.toMap());
  }

  Future<void> updateSettlement(Settlement settlement) async {
    await _db.update(
      _table,
      settlement.toMap(),
      where: 'id = ?',
      whereArgs: [settlement.id],
    );
  }

  Future<void> deleteSettlement(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<Settlement?> getSettlementById(String id) async {
    final results = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Settlement.fromMap(results.first);
  }

  Future<List<Settlement>> getGroupSettlements(String groupId) async {
    final results = await _db.query(
      _table,
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'date_time DESC',
    );
    return results.map((m) => Settlement.fromMap(m)).toList();
  }

  Future<List<Settlement>> getAllSettlements() async {
    final results = await _db.query(_table, orderBy: 'date_time DESC');
    return results.map((m) => Settlement.fromMap(m)).toList();
  }
}
