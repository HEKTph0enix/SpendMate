import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/income_detection_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/neobrutal/neobrutal_button.dart';

class NotificationAccessScreen extends StatefulWidget {
  const NotificationAccessScreen({super.key});

  @override
  State<NotificationAccessScreen> createState() => _NotificationAccessScreenState();
}

class _NotificationAccessScreenState extends State<NotificationAccessScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncomeDetectionProvider>().checkNotificationPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<IncomeDetectionProvider>().checkNotificationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<IncomeDetectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Access'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.notifications_active_outlined,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Automatic Income Detection',
              style: AppTextStyles.sectionHeading(isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'SpendMate can automatically detect when you receive money via Google Pay, PhonePe, Paytm, or BHIM.\n\nTo enable this feature, SpendMate needs permission to read notifications.',
              style: AppTextStyles.body(isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔒 Privacy & Security',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Your notifications never leave your device.\n'
                    '• SpendMate ignores OTPs and passwords.\n'
                    '• Only income-related notifications are parsed.',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (provider.isNotificationAccessEnabled)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Access Granted',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            else
              NeoBrutalButton(
                onPressed: () {
                  provider.openNotificationSettings();
                },
                child: const Text('OPEN SETTINGS'),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
