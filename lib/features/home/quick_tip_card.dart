import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../culture/cultural_tips_provider.dart';

class QuickTipCard extends ConsumerWidget {
  const QuickTipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tip = ref.watch(randomTipProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Quick Tip',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/live-events'),
                  child: const Text('Upcoming Events'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tip.tip,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _formatCategoryName(tip.category),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
