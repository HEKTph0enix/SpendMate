// Sample data generator for testing and demo purposes.

import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/expense.dart';
import '../models/expense_group.dart';
import '../models/group_member.dart';
import '../models/group_split.dart';
import '../models/settlement.dart';
import '../models/budget.dart';
import '../repositories/user_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/group_repository.dart';
import '../repositories/settlement_repository.dart';
import '../repositories/budget_repository.dart';
import '../constants/app_constants.dart';

class SampleData {
  static const _uuid = Uuid();

  /// Generate sample data: personal expenses, 1 group, 4 members, shared expenses, settlements.
  static Future<void> generate() async {
    final userRepo = UserRepository();
    final expenseRepo = ExpenseRepository();
    final groupRepo = GroupRepository();
    final settlementRepo = SettlementRepository();
    final budgetRepo = BudgetRepository();

    // 1. Ensure current user
    final currentUser = await userRepo.ensureCurrentUser(name: 'You');

    // 2. Create other users
    final arun = User(id: _uuid.v4(), name: 'Arun');
    final bala = User(id: _uuid.v4(), name: 'Bala');
    final charan = User(id: _uuid.v4(), name: 'Charan');

    await userRepo.insertUser(arun);
    await userRepo.insertUser(bala);
    await userRepo.insertUser(charan);

    final now = DateTime.now();

    // 3. Personal expenses
    final personalExpenses = [
      Expense(
        id: _uuid.v4(),
        amount: 250,
        dateTime: now.subtract(const Duration(hours: 2)),
        category: 'Food',
        paymentMethod: 'UPI',
        note: 'Lunch at Saravana Bhavan',
      ),
      Expense(
        id: _uuid.v4(),
        amount: 1500,
        dateTime: now.subtract(const Duration(days: 1)),
        category: 'Shopping',
        paymentMethod: 'Card',
        note: 'Amazon order',
      ),
      Expense(
        id: _uuid.v4(),
        amount: 450,
        dateTime: now.subtract(const Duration(days: 1, hours: 5)),
        category: 'Travel',
        paymentMethod: 'UPI',
        note: 'Uber to office',
      ),
      Expense(
        id: _uuid.v4(),
        amount: 12000,
        dateTime: now.subtract(const Duration(days: 3)),
        category: 'Rent',
        paymentMethod: 'UPI',
        note: 'Room rent',
      ),
      Expense(
        id: _uuid.v4(),
        amount: 800,
        dateTime: now.subtract(const Duration(days: 2)),
        category: 'Bills',
        paymentMethod: 'UPI',
        note: 'Electricity bill',
      ),
      Expense(
        id: _uuid.v4(),
        amount: 350,
        dateTime: now.subtract(const Duration(days: 4)),
        category: 'Entertainment',
        paymentMethod: 'UPI',
        note: 'Movie tickets',
      ),
      Expense(
        id: _uuid.v4(),
        amount: 2500,
        dateTime: now.subtract(const Duration(days: 5)),
        category: 'Groceries',
        paymentMethod: 'Cash',
        note: 'Monthly groceries',
      ),
      Expense(
        id: _uuid.v4(),
        amount: 150,
        dateTime: now,
        category: 'Food',
        paymentMethod: 'Cash',
        note: 'Tea & snacks',
      ),
    ];

    for (final e in personalExpenses) {
      await expenseRepo.insertExpense(e);
    }

    // 4. Create a group
    final group = ExpenseGroup(
      id: _uuid.v4(),
      name: 'Goa Trip',
      description: 'Weekend trip to Goa with friends',
    );
    await groupRepo.insertGroup(group);

    // 5. Add members
    final members = [currentUser, arun, bala, charan];
    for (final member in members) {
      await groupRepo.addMember(GroupMember(
        id: _uuid.v4(),
        groupId: group.id,
        userId: member.id,
      ));
    }

    // 6. Group expenses
    // Expense 1: Hotel - paid by current user
    final hotelExpenseId = _uuid.v4();
    final hotelExpense = Expense(
      id: hotelExpenseId,
      amount: 4800,
      dateTime: now.subtract(const Duration(days: 7)),
      category: 'Travel',
      paymentMethod: 'Card',
      note: 'Hotel booking',
      isGroupExpense: true,
      groupId: group.id,
      payerUserId: currentUser.id,
    );

    final hotelSplits = members
        .map((m) => GroupSplit(
              id: _uuid.v4(),
              expenseId: hotelExpenseId,
              userId: m.id,
              shareAmount: 1200,
              sharePercentage: 25,
              splitType: AppConstants.splitEqual,
            ))
        .toList();

    await groupRepo.addGroupExpenseWithSplits(hotelExpense, hotelSplits);

    // Expense 2: Dinner - paid by Arun
    final dinnerExpenseId = _uuid.v4();
    final dinnerExpense = Expense(
      id: dinnerExpenseId,
      amount: 3200,
      dateTime: now.subtract(const Duration(days: 6)),
      category: 'Food',
      paymentMethod: 'UPI',
      note: 'Dinner at beachside restaurant',
      isGroupExpense: true,
      groupId: group.id,
      payerUserId: arun.id,
    );

    final dinnerSplits = members
        .map((m) => GroupSplit(
              id: _uuid.v4(),
              expenseId: dinnerExpenseId,
              userId: m.id,
              shareAmount: 800,
              sharePercentage: 25,
              splitType: AppConstants.splitEqual,
            ))
        .toList();

    await groupRepo.addGroupExpenseWithSplits(dinnerExpense, dinnerSplits);

    // 7. Settlement: Bala pays current user ₹600
    await settlementRepo.insertSettlement(Settlement(
      id: _uuid.v4(),
      groupId: group.id,
      paidByUserId: bala.id,
      paidToUserId: currentUser.id,
      amount: 600,
      dateTime: now.subtract(const Duration(days: 5)),
      note: 'Partial settlement for hotel',
    ));

    // 8. Set monthly budget
    await budgetRepo.setOrUpdateBudget(now.month, now.year, 25000);
  }
}
