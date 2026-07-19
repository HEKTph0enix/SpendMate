import 'package:flutter/material.dart';
import '../models/savings_suggestion.dart';
import '../services/savings_suggestion_service.dart';

class SavingsProvider extends ChangeNotifier {
  final SavingsSuggestionService _savingsService = SavingsSuggestionService();

  bool _isLoading = false;
  List<SavingsSuggestion> _suggestions = [];
  double _totalPotentialSavings = 0.0;

  bool get isLoading => _isLoading;
  List<SavingsSuggestion> get suggestions => _suggestions;
  double get totalPotentialSavings => _totalPotentialSavings;

  SavingsProvider() {
    loadSuggestions();
  }

  Future<void> loadSuggestions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _suggestions = await _savingsService.generateSuggestions();
      _totalPotentialSavings = _savingsService.totalPotentialSavings(_suggestions);
    } catch (e) {
      debugPrint('Error loading savings suggestions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAsRevisited(String suggestionId) {
    // Note: Since suggestions are generated dynamically based on rules, 
    // a "dismiss" action would ideally require persisting the dismissed state.
    // For this implementation, we just remove it from the list temporarily.
    _suggestions.removeWhere((s) => s.id == suggestionId);
    _totalPotentialSavings = _savingsService.totalPotentialSavings(_suggestions);
    notifyListeners();
  }
}
