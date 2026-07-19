// Settings provider managing user preferences.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final UserRepository _userRepo = UserRepository();

  User? _currentUser;
  String _userName = 'You';

  User? get currentUser => _currentUser;
  String get userName => _userName;
  String get currentUserId => _currentUser?.id ?? '';

  Future<void> initialize() async {
    _currentUser = await _userRepo.ensureCurrentUser();
    _userName = _currentUser?.name ?? 'You';

    // Load saved name
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    if (savedName != null && savedName.isNotEmpty) {
      _userName = savedName;
      if (_currentUser != null && _currentUser!.name != savedName) {
        await _userRepo.updateCurrentUserName(savedName);
        _currentUser = await _userRepo.getCurrentUser();
      }
    }

    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    _userName = name;
    await _userRepo.updateCurrentUserName(name);
    _currentUser = await _userRepo.getCurrentUser();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    notifyListeners();
  }
}
