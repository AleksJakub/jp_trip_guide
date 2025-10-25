import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'saved_phrases_provider.dart';

class PhrasebookScreen extends ConsumerStatefulWidget {
  const PhrasebookScreen({super.key});

  @override
  ConsumerState<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends ConsumerState<PhrasebookScreen> {
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, dynamic>> phrases = [];
  List<Map<String, dynamic>> filteredPhrases = [];
  final TextEditingController _searchController = TextEditingController();

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
        phrases = jsonList.cast<Map<String, dynamic>>();
        filteredPhrases = List.from(phrases);
      });
    } catch (e) {
      // Handle error
    }
  }

  void _toggleSaved(String phraseId) {
    ref.read(savedPhrasesProvider.notifier).toggleSaved(phraseId);
  }

  void _filterPhrases(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPhrases = List.from(phrases);
      } else {
        filteredPhrases = phrases.where((phrase) {
          final english = phrase['en']?.toString().toLowerCase() ?? '';
          final japanese = phrase['jp']?.toString().toLowerCase() ?? '';
          final romaji = phrase['romaji']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          return english.contains(searchQuery) || 
                 japanese.contains(searchQuery) || 
                 romaji.contains(searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Phrases'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/phrasebook'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPhrases,
          ),
        ],
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
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterPhrases,
                    decoration: InputDecoration(
                      hintText: 'Search phrases...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                // Phrases list
                Expanded(
                  child: filteredPhrases.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No phrases found',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search terms',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            final Map<String, List<Map<String, dynamic>>> grouped = {};
                            for (final p in filteredPhrases) {
                              final String cat = (p['category'] ?? 'Other').toString();
                              (grouped[cat] ??= []).add(p);
                            }
                            final List<String> categories = grouped.keys.toList()..sort();

                            return ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              children: [
                                for (final cat in categories) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                                    child: Text(
                                      cat[0].toUpperCase() + cat.substring(1),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                  for (final phrase in grouped[cat]!)
                                    Builder(
                                      builder: (context) {
                                        final isSaved = ref.watch(savedPhrasesProvider).contains(phrase['id']);
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        phrase['en'] ?? '',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        phrase['jp'] ?? '',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        phrase['romaji'] ?? '',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.volume_up),
                                                      onPressed: () => _speak(phrase['jp'] ?? ''),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                                                        color: isSaved ? Colors.green : Colors.grey,
                                                      ),
                                                      onPressed: () => _toggleSaved(phrase['id'] ?? ''),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}


