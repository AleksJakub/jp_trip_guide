import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/trips_provider.dart';
import 'day_view_screen.dart';

class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final t = trips[index];
          return ListTile(
            title: Text(t.title),
            subtitle: Text('${t.startDate.toLocal().toIso8601String().split('T').first} → ${t.endDate.toLocal().toIso8601String().split('T').first}'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DayViewScreen(tripId: t.id))),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => ref.read(tripsProvider.notifier).deleteTrip(t.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => _CreateTripDialog(onCreate: (title, start, end) async {
              await ref.read(tripsProvider.notifier).createTrip(title, start, end);
            }),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CreateTripDialog extends StatefulWidget {
  final Future<void> Function(String title, DateTime start, DateTime end) onCreate;
  const _CreateTripDialog({required this.onCreate});

  @override
  State<_CreateTripDialog> createState() => _CreateTripDialogState();
}

class _CreateTripDialogState extends State<_CreateTripDialog> {
  final TextEditingController _title = TextEditingController(text: 'Japan Trip');
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Trip'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('Start: ${_start.toLocal().toIso8601String().split('T').first}')),
            TextButton(
                onPressed: () async {
                  final DateTime? d = await showDatePicker(context: context, initialDate: _start, firstDate: DateTime(2020), lastDate: DateTime(2035));
                  if (d != null) setState(() => _start = d);
                },
                child: const Text('Pick')),
          ]),
          Row(children: [
            Expanded(child: Text('End: ${_end.toLocal().toIso8601String().split('T').first}')),
            TextButton(
                onPressed: () async {
                  final DateTime? d = await showDatePicker(context: context, initialDate: _end, firstDate: _start, lastDate: DateTime(2035));
                  if (d != null) setState(() => _end = d);
                },
                child: const Text('Pick')),
          ]),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            await widget.onCreate(_title.text.trim().isEmpty ? 'Japan Trip' : _title.text.trim(), _start, _end);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}


