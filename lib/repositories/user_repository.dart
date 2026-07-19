// Repository for user CRUD operations and current user management.

import '../database/database_helper.dart';
import '../models/user.dart';
import 'package:uuid/uuid.dart';

class UserRepository {
  final DatabaseHelper _db = DatabaseHelper();
  static const _table = 'users';
  final _uuid = const Uuid();

  Future<User> ensureCurrentUser({String name = 'You'}) async {
    final existing = await getCurrentUser();
    if (existing != null) return existing;

    final user = User(
      id: _uuid.v4(),
      name: name,
      isCurrentUser: true,
    );
    await _db.insert(_table, user.toMap());
    return user;
  }

  Future<User?> getCurrentUser() async {
    final results = await _db.query(
      _table,
      where: 'is_current_user = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  Future<User> createUser(String name, {String? phone, String? email}) async {
    final user = User(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      email: email,
      isCurrentUser: false,
    );
    await _db.insert(_table, user.toMap());
    return user;
  }

  Future<User?> getUserById(String id) async {
    final results = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  Future<List<User>> getAllUsers() async {
    final results = await _db.query(_table, orderBy: 'is_current_user DESC, name ASC');
    return results.map((m) => User.fromMap(m)).toList();
  }

  Future<void> updateUser(User user) async {
    await _db.update(
      _table,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> updateCurrentUserName(String name) async {
    final user = await getCurrentUser();
    if (user != null) {
      await _db.update(
        _table,
        {'name': name},
        where: 'id = ?',
        whereArgs: [user.id],
      );
    }
  }

  Future<void> deleteUser(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<User?> findUserByName(String name) async {
    final results = await _db.query(
      _table,
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  Future<void> insertUser(User user) async {
    await _db.insert(_table, user.toMap());
  }
}
