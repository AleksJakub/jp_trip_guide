import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../culture/cultural_tips_provider.dart';

class QuickTipCard extends ConsumerStatefulWidget {
  const QuickTipCard({super.key});

  @override
  ConsumerState<QuickTipCard> createState() => _QuickTipCardState();
}

class _QuickTipCardState extends ConsumerState<QuickTipCard> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      final tips = ref.read(culturalTipsProvider);
      if (tips.isEmpty || tips.length == 1) return;
      final int next = (_currentIndex + 1) % tips.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _currentIndex = next;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tips = ref.watch(culturalTipsProvider);
    final List<CulturalTip> items = tips.isEmpty
        ? const [CulturalTip(id: 'default', category: 'general', tip: 'Welcome to Japan! Remember to be respectful and observe local customs.')]
        : tips;

    // Ensure current index stays in range if tips length changes
    if (_currentIndex >= items.length) {
      _currentIndex = 0;
    }

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
                  onPressed: () => context.go('/cultural-tips'),
                  child: const Text('See more tips'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => _currentIndex = i,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final tip = items[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.tip,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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
                  );
                },
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
