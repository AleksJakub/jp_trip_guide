import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../itinerary/state/trips_provider.dart';
import '../../data/models/stop.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = DateTime.now();
    final List<_Event> items = List.generate(12, (i) {
      return _Event(
        id: 'evt_$i',
        name: 'Tokyo Event #$i',
        start: now.add(Duration(days: i)),
        end: now.add(Duration(days: i, hours: 2)),
        lat: 35.68 + (i * 0.001),
        lng: 139.76 + (i * 0.001),
        address: 'Chiyoda, Tokyo',
      );
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Events in Tokyo')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final e = items[index];
          return ListTile(
            title: Text(e.name),
            subtitle: Text('${e.start.toLocal()} — ${e.address}'),
            trailing: TextButton(
              child: const Text('Add to day'),
              onPressed: () async {
                final trips = ref.read(tripsProvider);
                if (trips.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create a trip first')));
                  return;
                }
                final day = trips.first.days.isNotEmpty ? trips.first.days.first : null;
                if (day == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a day to your trip')));
                  return;
                }
                final StopItem stop = StopItem(
                  id: e.id,
                  placeId: e.id,
                  name: e.name,
                  lat: e.lat,
                  lng: e.lng,
                  category: 'event',
                  startTs: e.start,
                  endTs: e.end,
                );
                await ref.read(tripsProvider.notifier).addStop(day.id, stop);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to itinerary')));
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _Event {
  final String id;
  final String name;
  final DateTime start;
  final DateTime end;
  final double lat;
  final double lng;
  final String address;
  _Event({required this.id, required this.name, required this.start, required this.end, required this.lat, required this.lng, required this.address});
}


