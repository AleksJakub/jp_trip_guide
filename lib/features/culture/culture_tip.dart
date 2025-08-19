import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CultureTipBanner extends StatefulWidget {
  final String? category; // shrine, onsen, train
  const CultureTipBanner({super.key, this.category});

  @override
  State<CultureTipBanner> createState() => _CultureTipBannerState();
}

class _CultureTipBannerState extends State<CultureTipBanner> {
  Map<String, dynamic>? _tips;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String raw = await rootBundle.loadString('assets/culture/etiquette.json');
    setState(() {
      _tips = json.decode(raw) as Map<String, dynamic>;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? cat = widget.category;
    if (cat == null || _tips == null || !_tips!.containsKey(cat)) return const SizedBox.shrink();
    final Map<String, dynamic> item = _tips![cat] as Map<String, dynamic>;
    final List<dynamic> dos = item['do'] as List<dynamic>;
    final List<dynamic> donts = item['dont'] as List<dynamic>;
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Etiquette for ${cat[0].toUpperCase()}${cat.substring(1)}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Do:'),
            for (final d in dos.take(6)) Text('• $d'),
            const SizedBox(height: 8),
            Text("Don't:"),
            for (final d in donts.take(6)) Text('• $d'),
          ],
        ),
      ),
    );
  }
}


