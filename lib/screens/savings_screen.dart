import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/savings_provider.dart';
import '../widgets/suggestion_card.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({Key? key}) : super(key: key);

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsProvider>().loadSuggestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Assistant'),
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.suggestions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Your spending looks great!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No new savings suggestions at the moment.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Potential Monthly Savings',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${provider.totalPotentialSavings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...provider.suggestions.map((suggestion) => SuggestionCard(
                suggestion: suggestion,
                onDismiss: () => provider.markAsRevisited(suggestion.id),
              )),
            ],
          );
        },
      ),
    );
  }
}
