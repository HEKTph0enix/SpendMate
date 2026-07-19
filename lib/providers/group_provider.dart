// Group provider managing group state, members, expenses, balances, and settlements.

import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_group.dart';
import '../models/group_member.dart';
import '../models/group_split.dart';
import '../models/settlement.dart';
import '../repositories/group_repository.dart';
import '../repositories/settlement_repository.dart';
import '../repositories/user_repository.dart';
import '../utils/settlement_algorithm.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class GroupProvider extends ChangeNotifier {
  final GroupRepository _groupRepo = GroupRepository();
  final SettlementRepository _settlementRepo = SettlementRepository();
  final UserRepository _userRepo = UserRepository();

  List<ExpenseGroup> _groups = [];
  bool _isLoading = false;

  // Active group details
  ExpenseGroup? _activeGroup;
  List<GroupMember> _activeGroupMembers = [];
  List<User> _activeGroupUsers = [];
  List<Expense> _activeGroupExpenses = [];
  List<Settlement> _activeGroupSettlements = [];
  Map<String, double> _activeGroupBalances = {};
  List<SettlementSuggestion> _settlementSuggestions = [];

  List<ExpenseGroup> get groups => _groups;
  bool get isLoading => _isLoading;

  ExpenseGroup? get activeGroup => _activeGroup;
  List<User> get activeGroupUsers => _activeGroupUsers;
  List<Expense> get activeGroupExpenses => _activeGroupExpenses;
  List<Settlement> get activeGroupSettlements => _activeGroupSettlements;
  Map<String, double> get activeGroupBalances => _activeGroupBalances;
  List<SettlementSuggestion> get settlementSuggestions => _settlementSuggestions;

  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      _groups = await _groupRepo.getAllGroups();
    } catch (e) {
      _groups = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGroup(ExpenseGroup group, List<User> members) async {
    await _groupRepo.insertGroup(group);

    // Add members
    for (final user in members) {
      // Ensure user exists in db
      final existingUser = await _userRepo.getUserById(user.id);
      if (existingUser == null) {
        await _userRepo.insertUser(user);
      }

      await _groupRepo.addMember(GroupMember(
        id: DateTime.now().millisecondsSinceEpoch.toString() + user.id, // Basic ID
        groupId: group.id,
        userId: user.id,
      ));
    }

    await loadGroups();
  }

  Future<void> updateGroup(ExpenseGroup group, List<User> members) async {
    await _groupRepo.updateGroup(group);
    
    // Update members (simple approach: remove all, re-add)
    final existingMembers = await _groupRepo.getGroupMembers(group.id);
    for (final member in existingMembers) {
      await _groupRepo.removeMember(member.id);
    }
    
    for (final user in members) {
      // Ensure user exists
      final existingUser = await _userRepo.getUserById(user.id);
      if (existingUser == null) {
        await _userRepo.insertUser(user);
      }

      await _groupRepo.addMember(GroupMember(
        id: DateTime.now().millisecondsSinceEpoch.toString() + user.id,
        groupId: group.id,
        userId: user.id,
      ));
    }
    
    await loadGroups();
    if (_activeGroup?.id == group.id) {
      await loadActiveGroupDetails(group.id);
    }
  }

  Future<void> deleteGroup(String id) async {
    await _groupRepo.deleteGroup(id);
    if (_activeGroup?.id == id) {
      _activeGroup = null;
    }
    await loadGroups();
  }

  // ─── Active Group Details ──────────────────────────────────────────

  Future<void> loadActiveGroupDetails(String groupId) async {
    _isLoading = true;
    notifyListeners();

    _activeGroup = await _groupRepo.getGroupById(groupId);
    if (_activeGroup != null) {
      _activeGroupMembers = await _groupRepo.getGroupMembers(groupId);
      
      // Load user details for members
      _activeGroupUsers = [];
      for (final member in _activeGroupMembers) {
        final user = await _userRepo.getUserById(member.userId);
        if (user != null) {
          _activeGroupUsers.add(user);
        }
      }

      _activeGroupExpenses = await _groupRepo.getGroupExpenses(groupId);
      _activeGroupSettlements = await _settlementRepo.getGroupSettlements(groupId);
      
      _activeGroupBalances = await _groupRepo.calculateGroupBalances(groupId);
      _settlementSuggestions = SettlementAlgorithm.calculateMinimumSettlements(_activeGroupBalances);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Group Expenses ────────────────────────────────────────────────

  Future<void> addGroupExpense(Expense expense, List<GroupSplit> splits) async {
    await _groupRepo.addGroupExpenseWithSplits(expense, splits);
    if (_activeGroup?.id == expense.groupId) {
      await loadActiveGroupDetails(expense.groupId!);
    }
  }
  
  Future<void> updateGroupExpense(Expense expense, List<GroupSplit> splits) async {
    await _groupRepo.updateGroupExpenseWithSplits(expense, splits);
    if (_activeGroup?.id == expense.groupId) {
      await loadActiveGroupDetails(expense.groupId!);
    }
  }

  Future<void> deleteGroupExpense(String id, String groupId) async {
    // Delete handled by expense repo normally, but splits need cascade or manual deletion
    final DatabaseHelper db = DatabaseHelper();
    await db.runTransaction((txn) async {
      await txn.delete('group_splits', where: 'expense_id = ?', whereArgs: [id]);
      await txn.delete('expenses', where: 'id = ?', whereArgs: [id]);
    });
    
    if (_activeGroup?.id == groupId) {
      await loadActiveGroupDetails(groupId);
    }
  }

  // ─── Settlements ───────────────────────────────────────────────────

  Future<void> addSettlement(Settlement settlement) async {
    await _settlementRepo.insertSettlement(settlement);
    if (_activeGroup?.id == settlement.groupId) {
      await loadActiveGroupDetails(settlement.groupId);
    }
  }

  Future<void> deleteSettlement(String id, String groupId) async {
    await _settlementRepo.deleteSettlement(id);
    if (_activeGroup?.id == groupId) {
      await loadActiveGroupDetails(groupId);
    }
  }
}
