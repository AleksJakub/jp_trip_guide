import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'saved_phrases_provider.dart';

class SavedPhrasesScreen extends ConsumerStatefulWidget {
  const SavedPhrasesScreen({super.key});

  @override
  ConsumerState<SavedPhrasesScreen> createState() => _SavedPhrasesScreenState();
}

class _SavedPhrasesScreenState extends ConsumerState<SavedPhrasesScreen> {
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, dynamic>> allPhrases = [];

  @override
  void initState() {
    super.initState();
    _loadPhrases();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _loadPhrases() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context).loadString('assets/phrases/phrases_en_jp.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      setState(() {
        allPhrases = jsonList.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      // Handle error
    }
  }

  void _removeFromSaved(String phraseId) {
    ref.read(savedPhrasesProvider.notifier).toggleSaved(phraseId);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Phrases'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/phrasebook'),
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
            child: Column(
              children: [
                const SizedBox(height: 80),
                Consumer(
                  builder: (context, ref, child) {
                    final savedPhraseIds = ref.watch(savedPhrasesProvider);
                    final savedPhrases = allPhrases.where((p) => savedPhraseIds.contains(p['id'])).toList();
                    
                    if (savedPhrases.isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 64,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No saved phrases yet',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add phrases from the main phrasebook to get started',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => context.go('/phrasebook/all'),
                                icon: const Icon(Icons.add),
                                label: const Text('Browse Phrases'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade200,
                                  foregroundColor: Colors.grey.shade800,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    // Group by category
                    final Map<String, List<Map<String, dynamic>>> grouped = {};
                    for (final p in savedPhrases) {
                      final String cat = (p['category'] ?? 'Other').toString();
                      (grouped[cat] ??= []).add(p);
                    }
                    final List<String> categories = grouped.keys.toList()..sort();

                    return Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final cat in categories) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                cat[0].toUpperCase() + cat.substring(1),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            for (final phrase in grouped[cat]!)
                              Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(phrase['en'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Text(phrase['jp'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                            const SizedBox(height: 4),
                                            Text(phrase['romaji'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(icon: const Icon(Icons.volume_up), onPressed: () => _speak(phrase['jp'] ?? '')),
                                          IconButton(icon: const Icon(Icons.bookmark, color: Colors.green), onPressed: () => _removeFromSaved(phrase['id'] ?? '')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
