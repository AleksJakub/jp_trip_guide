import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/geo.dart';
import '../../data/models/stop.dart';
import '../../data/models/trip.dart';
import '../culture/culture_tip.dart';
import 'state/trips_provider.dart';

class DayViewScreen extends ConsumerStatefulWidget {
  final String tripId;
  const DayViewScreen({super.key, required this.tripId});

  @override
  ConsumerState<DayViewScreen> createState() => _DayViewScreenState();
}

class _DayViewScreenState extends ConsumerState<DayViewScreen> {
  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    final Trip? trip = trips.where((t) => t.id == widget.tripId).cast<Trip?>().firstOrNull;
    if (trip == null) return const Scaffold(body: Center(child: Text('Trip not found')));
    return Scaffold(
      appBar: AppBar(title: Text(trip.title)),
      body: ListView(
        children: [
          for (final day in trip.days)
            Card(
              margin: const EdgeInsets.all(12),
              child: ExpansionTile(
                title: Text('Day ${day.date.toLocal().toIso8601String().split('T').first}'),
                children: [
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: (oldIndex, newIndex) async {
                      final List<StopItem> updated = [...day.stops];
                      if (newIndex > oldIndex) newIndex -= 1;
                      final StopItem item = updated.removeAt(oldIndex);
                      updated.insert(newIndex, item);
                      for (int i = 0; i < updated.length; i++) {
                        updated[i] = updated[i].copyWith(sortIndex: i);
                      }
                      await ref.read(tripsProvider.notifier).reorderStops(day.id, updated);
                    },
                    itemCount: day.stops.length,
                    itemBuilder: (context, index) {
                      final s = day.stops[index];
                      final double distKm = index < day.stops.length - 1
                          ? haversineKm(s.lat, s.lng, day.stops[index + 1].lat, day.stops[index + 1].lng)
                          : 0;
                      final Duration eta = estimateDurationTransitKm(distKm, mode: s.transportMode);
                      final bool showWarning = index < day.stops.length - 1 && eta.inMinutes > 60;
                      return ListTile(
                        key: ValueKey(s.id),
                        title: Text(s.name),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${s.category ?? ''} ${s.startTs != null ? ' • ${s.startTs}' : ''}'),
                          if (showWarning) const Text('Warning: next stop may be > 60 min away', style: TextStyle(color: Colors.orange)),
                        ]),
                        trailing: index < day.stops.length - 1 ? Text('${eta.inMinutes} min') : null,
                      );
                    },
                  ),
                  CultureTipBanner(category: day.stops.isNotEmpty ? day.stops.first.category : null),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            final StopItem stop = StopItem(
                              id: DateTime.now().microsecondsSinceEpoch.toString(),
                              placeId: 'custom',
                              name: 'Custom Stop',
                              lat: 35.6762,
                              lng: 139.6503,
                              category: 'custom',
                              startTs: DateTime.now(),
                            );
                            await ref.read(tripsProvider.notifier).addStop(day.id, stop);
                          },
                          icon: const Icon(Icons.add_location_alt),
                          label: const Text('Add stop'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await ref.read(tripsProvider.notifier).addDay(trip.id, DateTime.now());
        },
        icon: const Icon(Icons.today),
        label: const Text('Add day'),
      ),
    );
  }
}

extension FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}


