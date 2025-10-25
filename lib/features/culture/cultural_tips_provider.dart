import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CulturalTip {
  final String id;
  final String category;
  final String tip;

  const CulturalTip({
    required this.id,
    required this.category,
    required this.tip,
  });

  factory CulturalTip.fromJson(Map<String, dynamic> json) {
    return CulturalTip(
      id: json['id'] as String,
      category: json['category'] as String,
      tip: json['tip'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'tip': tip,
      };
}

class CulturalTipsNotifier extends StateNotifier<List<CulturalTip>> {
  CulturalTipsNotifier() : super([]) {
    _loadTips();
  }

  Future<void> _loadTips() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/culture/cultural_tips.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final List<CulturalTip> tips = jsonList
          .map((json) => CulturalTip.fromJson(json as Map<String, dynamic>))
          .toList();
      state = tips;
    } catch (e) {
      // Handle error - could set a default state or log error
      state = [];
    }
  }

  CulturalTip getRandomTip() {
    if (state.isEmpty) {
      return const CulturalTip(
        id: 'default',
        category: 'general',
        tip: 'Welcome to Japan! Remember to be respectful and observe local customs.',
      );
    }
    final random = Random();
    return state[random.nextInt(state.length)];
  }

  List<CulturalTip> getTipsByCategory(String category) {
    return state.where((tip) => tip.category == category).toList();
  }

  List<String> getCategories() {
    return state.map((tip) => tip.category).toSet().toList();
  }
}

final culturalTipsProvider = StateNotifierProvider<CulturalTipsNotifier, List<CulturalTip>>(
  (ref) => CulturalTipsNotifier(),
);

final randomTipProvider = Provider<CulturalTip>((ref) {
  final tips = ref.watch(culturalTipsProvider);
  if (tips.isEmpty) {
    return const CulturalTip(
      id: 'default',
      category: 'general',
      tip: 'Welcome to Japan! Remember to be respectful and observe local customs.',
    );
  }
  final random = Random();
  return tips[random.nextInt(tips.length)];
});
