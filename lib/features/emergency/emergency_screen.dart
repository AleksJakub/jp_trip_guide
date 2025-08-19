import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<Map<String, dynamic>> _embs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String raw = await rootBundle.loadString('assets/emergency/embassies.json');
    final Map<String, dynamic> jsonMap = json.decode(raw) as Map<String, dynamic>;
    final Iterable<dynamic> iter = jsonMap.values.expand((v) => (v as List<dynamic>));
    setState(() {
      _embs = iter.cast<Map<String, dynamic>>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse('tel:110')),
                    icon: const Icon(Icons.local_police),
                    label: const Text('Call 110 Police'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse('tel:119')),
                    icon: const Icon(Icons.local_hospital),
                    label: const Text('Call 119 Ambulance'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Nearest hospitals/police and what to say (JP) coming soon.'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _embs.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> e = _embs[index];
                return ListTile(
                  title: Text('${e['city']} — ${e['address']}'),
                  subtitle: Text(e['phone'] as String),
                  onTap: () => launchUrl(Uri.parse('tel:${(e['phone'] as String).replaceAll(' ', '')}')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


