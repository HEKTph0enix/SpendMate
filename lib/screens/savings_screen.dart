import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/savings_provider.dart';
import '../widgets/neumorphic/neumorphic_container.dart';
import '../widgets/suggestion_card.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<SavingsProvider>().loadSuggestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Assistant'),
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.suggestions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your spending looks great!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'No new savings suggestions at the moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              NeumorphicContainer(
                isInset: true,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Potential Monthly Savings',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${provider.totalPotentialSavings.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Actionable Suggestions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...provider.suggestions.map(
                    (suggestion) => SuggestionCard(
                  suggestion: suggestion,
                  onDismiss: () {
                    provider.markAsRevisited(suggestion.id);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}