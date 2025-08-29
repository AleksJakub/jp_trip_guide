import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../culture/cultural_tips_provider.dart';
import 'package:go_router/go_router.dart';

class CulturalTipsScreen extends ConsumerWidget {
  const CulturalTipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = ref.watch(culturalTipsProvider);
    final categories = ref.read(culturalTipsProvider.notifier).getCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cultural Tips'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/more'),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/image1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryTips = ref.watch(culturalTipsProvider.notifier).getTipsByCategory(category);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(
                      _formatCategoryName(category),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: categoryTips
                        .where((tip) => tip.id != 'gen_bow' && tip.id != 'gen_shoes_off')
                        .map((tip) => ListTile(
                              title: Text(tip.tip),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatCategoryName(String category) {
    switch (category) {
      case 'general':
        return 'General Etiquette';
      case 'shrines_temples':
        return 'Shrines & Temples';
      case 'onsen_baths':
        return 'Onsen & Baths';
      case 'dining':
        return 'Dining & Food';
      case 'transport':
        return 'Transportation';
      case 'shopping':
        return 'Shopping';
      default:
        return category.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
        ).join(' ');
    }
  }
}


