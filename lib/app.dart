import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Legacy providers
import 'providers/expense_provider.dart';
import 'providers/group_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';

// New providers
import 'providers/financial_dashboard_provider.dart';
import 'providers/cash_wallet_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/savings_provider.dart';

import 'core/theme/app_theme.dart';
import 'constants/app_constants.dart';
import 'widgets/neumorphic/neumorphic_bottom_navigation.dart';
import 'screens/expenses/add_expense_screen.dart';
// Legacy screens
import 'screens/groups/groups_screen.dart';
import 'screens/settings/settings_screen.dart';

// New screens
import 'screens/dashboard_screen.dart';
import 'screens/enhanced_statistics_screen.dart';
import 'screens/savings_screen.dart';

class SpendMateApp extends StatelessWidget {
  const SpendMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Legacy providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()..loadExpenses()),
        ChangeNotifierProvider(create: (_) => GroupProvider()..loadGroups()),
        ChangeNotifierProxyProvider<SettingsProvider, BudgetProvider>(
          create: (context) => BudgetProvider(Provider.of<SettingsProvider>(context, listen: false)),
          update: (context, settings, previous) => previous ?? BudgetProvider(settings),
        ),
        ChangeNotifierProxyProvider<SettingsProvider, StatisticsProvider>(
          create: (context) => StatisticsProvider(Provider.of<SettingsProvider>(context, listen: false)),
          update: (context, settings, previous) => previous ?? StatisticsProvider(settings),
        ),
        
        // New providers
        ChangeNotifierProvider(create: (_) => FinancialDashboardProvider()),
        ChangeNotifierProvider(create: (_) => CashWalletProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const EnhancedStatisticsScreen(),
    const SavingsScreen(),
    const GroupsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NeumorphicBottomNavigation(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onAddPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
      ),
    );
  }
}
