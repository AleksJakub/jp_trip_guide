import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPhrasesNotifier extends StateNotifier<Set<String>> {
  SavedPhrasesNotifier() : super({}) {
    _loadSavedPhrases();
  }

  Future<void> _loadSavedPhrases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIds = prefs.getStringList('saved_phrases') ?? [];
      state = Set<String>.from(savedIds);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleSaved(String phraseId) async {
    final newState = Set<String>.from(state);
    if (newState.contains(phraseId)) {
      newState.remove(phraseId);
    } else {
      newState.add(phraseId);
    }
    state = newState;
    await _saveSavedPhrases();
  }

  Future<void> _saveSavedPhrases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved_phrases', state.toList());
    } catch (e) {
      // Handle error
    }
  }

  bool isSaved(String phraseId) {
    return state.contains(phraseId);
  }

  Set<String> get savedPhraseIds => state;
}

final savedPhrasesProvider = StateNotifierProvider<SavedPhrasesNotifier, Set<String>>((ref) {
  return SavedPhrasesNotifier();
});
