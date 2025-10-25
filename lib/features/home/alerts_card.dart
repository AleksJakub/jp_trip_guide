import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AlertsCard extends StatefulWidget {
  const AlertsCard({super.key});

  @override
  State<AlertsCard> createState() => _AlertsCardState();
}

class _AlertsCardState extends State<AlertsCard> {
  bool _loading = true;
  String? _error;
  List<_AlertItem> _alerts = const [];

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = Dio();
      // JMA JSON feeds (example endpoints). You can swap to a proxy or cached service if needed.
      // Here we use an example endpoint that might return latest earthquake info in JSON.
      // Fallback to empty if network fails.
      final responses = await Future.wait<List<_AlertItem>>([
        _fetchJmaEarthquakes(dio),
        _fetchJmaTsunami(dio),
      ]);
      final merged = <_AlertItem>[]..addAll(responses[0])..addAll(responses[1]);
      merged.sort((a, b) => b.time.compareTo(a.time));
      setState(() {
        _alerts = merged;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load alerts';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                const Text('Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: () => context.go('/alerts'), child: const Text('See more')),
                IconButton(onPressed: _fetchAlerts, tooltip: 'Refresh', icon: const Icon(Icons.refresh)),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            else if (_alerts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(child: Text('All clear. No earthquake/tsunami alerts right now.')),
                  ],
                ),
              )
            else
              Column(
                children: _alerts.take(2).map((a) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(a.type == 'tsunami' ? Icons.waves : Icons.public, color: a.type == 'tsunami' ? Colors.blue : Colors.orange),
                      title: Text(a.title),
                      subtitle: Text('${_formatLocation(a)} • ${_formatTimestamp(a.time)}'),
                    )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final local = time.toLocal();
    return DateFormat('d MMM, HH:mm').format(local);
  }

  String _formatLocation(_AlertItem a) {
    final List<String> parts = [];
    final String city = (a.city ?? '').trim();
    final String region = a.region.trim();
    if (city.isNotEmpty) parts.add(city);
    if (region.isNotEmpty && (parts.isEmpty || parts.last != region)) parts.add(region);
    return parts.isEmpty ? 'Japan' : parts.join(', ');
  }

  Future<List<_AlertItem>> _fetchJmaEarthquakes(Dio dio) async {
    try {
      // Example public feed (replace with a reliable JSON source as needed)
      final res = await dio.get('https://www.jma.go.jp/bosai/quake/data/list.json');
      final List list = res.data is String ? json.decode(res.data as String) as List : (res.data as List);
      return list.take(3).map<_AlertItem>((e) {
        final m = e as Map;
        return _AlertItem(
          type: 'earthquake',
          title: 'Earthquake M${m['mag'] ?? '?'}',
          region: (m['name'] ?? 'Japan').toString(),
          city: (m['place'] ?? m['region'] ?? '').toString().isEmpty ? null : (m['place'] ?? m['region']).toString(),
          time: DateTime.tryParse((m['at'] ?? '').toString()) ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<_AlertItem>> _fetchJmaTsunami(Dio dio) async {
    try {
      // Example tsunami info feed (structure may differ). Return empty on failure.
      final res = await dio.get('https://www.jma.go.jp/bosai/tsunami/data/list.json');
      final List list = res.data is String ? json.decode(res.data as String) as List : (res.data as List);
      return list.take(3).map<_AlertItem>((e) {
        final m = e as Map;
        return _AlertItem(
          type: 'tsunami',
          title: (m['headline'] ?? 'Tsunami Information').toString(),
          region: (m['area'] ?? 'Coast').toString(),
          city: (m['city'] ?? '').toString().isEmpty ? null : (m['city'] ?? '').toString(),
          time: DateTime.tryParse((m['time'] ?? '').toString()) ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }
}

class _AlertItem {
  final String type; // 'earthquake' | 'tsunami'
  final String title;
  final String region;
  final DateTime time;
  final String? city;
  const _AlertItem({required this.type, required this.title, required this.region, required this.time, this.city});
}


