import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'state/trips_provider.dart';


class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Itineraries'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context, ref),
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
            child: trips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        Icon(
                          Icons.flight_takeoff,
                          size: 64,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No itineraries yet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first trip to get started',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Trip'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final t = trips[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(t.title),
                          subtitle: Text(_formatTripDates(t.startDate, t.endDate)),
                          onTap: () => context.go('/trip/${Uri.encodeComponent(t.id)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteTrip(context, t.id, ref),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
      floatingActionButton: trips.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Trip'),
            )
          : null,
    );
  }

  String _formatTripDates(DateTime start, DateTime end) {
    final DateFormat formatter = DateFormat('EEE, MMM d');
    final startStr = formatter.format(start);
    final endStr = formatter.format(end);
    return '$startStr - $endStr';
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => _CreateTripDialog(
        onCreate: (title, start, end) async {
          await ref.read(tripsProvider.notifier).createTrip(title, start, end);
        },
      ),
    );
  }

  void _deleteTrip(BuildContext context, String tripId, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: const Text('Are you sure you want to delete this trip? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(tripsProvider.notifier).deleteTrip(tripId);
    }
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
      title: const Center(child: Text('Create Trip')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final DateTime? d = await showDatePicker(context: context, initialDate: _start, firstDate: DateTime(2020), lastDate: DateTime(2035));
              if (d != null) {
                setState(() {
                  _start = d;
                  if (_end.isBefore(d)) {
                    _end = d;
                  }
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(child: Text('Start: ${DateFormat('EEE, MMM d, y').format(_start)}', textAlign: TextAlign.center)),
            ),
          ),
          InkWell(
            onTap: () async {
              final DateTime safeInitial = _end.isBefore(_start) ? _start : _end;
              try {
                final DateTime? d = await showDatePicker(context: context, initialDate: safeInitial, firstDate: _start, lastDate: DateTime(2035));
                if (d != null) {
                  setState(() => _end = d);
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('End date must be on or after the start date.')),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(child: Text('End: ${DateFormat('EEE, MMM d, y').format(_end)}', textAlign: TextAlign.center)),
            ),
          ),
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


