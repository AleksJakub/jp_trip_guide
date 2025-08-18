import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, Clipboard, ClipboardData;
import 'package:flutter_tts/flutter_tts.dart';
 

class PhrasebookScreen extends StatefulWidget {
  const PhrasebookScreen({super.key});

  @override
  State<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends State<PhrasebookScreen> {
  final FlutterTts _tts = FlutterTts();
  List<Map<String, dynamic>> _phrases = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadPhrases();
  }

  Future<void> _loadPhrases() async {
    final String raw = await rootBundle.loadString('assets/phrases/phrases_en_jp.json');
    final List<dynamic> jsonList = json.decode(raw) as List<dynamic>;
    setState(() {
      _phrases = jsonList.cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filtered = _phrases.where((p) {
      if (_query.isEmpty) return true;
      final String hay = '${p['en']} ${p['romaji']} ${p['jp']}'.toLowerCase();
      return hay.contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Phrasebook')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search'),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> item = filtered[index];
                return ListTile(
                  title: Text(item['jp'] as String),
                  subtitle: Text('${item['romaji']} — ${item['en']}'),
                  trailing: Wrap(spacing: 8, children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () => _tts.speak(item['jp'] as String),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () async {
                        final String text = '${item['jp']}\n${item['romaji']}\n${item['en']}';
                        await Clipboard.setData(ClipboardData(text: text));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
                        }
                      },
                    ),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


