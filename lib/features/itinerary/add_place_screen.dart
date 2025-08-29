import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/stop.dart';
import 'state/trips_provider.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  final String dayId;
  const AddPlaceScreen({super.key, required this.dayId});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  String _query = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String raw = await rootBundle.loadString('assets/places/things_to_do.json');
    final List<dynamic> jsonList = json.decode(raw) as List<dynamic>;
    setState(() {
      _items = jsonList.cast<Map<String, dynamic>>();
      _filteredItems = List.from(_items);
    });
  }

  void _filterItems() {
    setState(() {
      if (_query.isEmpty && _selectedCategory == 'All') {
        _filteredItems = List.from(_items);
      } else {
        _filteredItems = _items.where((item) {
          final matchesQuery = _query.isEmpty || 
              item['name'].toString().toLowerCase().contains(_query.toLowerCase()) ||
              item['city'].toString().toLowerCase().contains(_query.toLowerCase());
          final matchesCategory = _selectedCategory == 'All' || 
              item['category'] == _selectedCategory;
          return matchesQuery && matchesCategory;
        }).toList();
      }
    });
  }

  List<String> get _categories {
    final categories = _items.map((item) => item['category'] as String).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Place'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/itinerary'),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Search bar
                      TextField(
                        onChanged: (value) {
                          _query = value;
                          _filterItems();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search places...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Category filter
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = category == _selectedCategory;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                  _filterItems();
                                },
                                backgroundColor: Colors.white.withOpacity(0.3),
                                selectedColor: Colors.blue.withOpacity(0.7),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Places list
                Expanded(
                  child: _filteredItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No places found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _promptTimeAndAdd(item),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: _getCategoryColor(item['category']),
                                        child: Icon(
                                          _getCategoryIcon(item['category']),
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'],
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(item['city']),
                                            Text(
                                              item['description'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  item['openingHours'],
                                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                                ),
                                                const SizedBox(width: 16),
                                                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  item['price'],
                                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'temple':
        return Colors.orange;
      case 'shrine':
        return Colors.red;
      case 'food':
        return Colors.green;
      case 'nature':
        return Colors.teal;
      case 'culture':
        return Colors.purple;
      case 'castle':
        return Colors.brown;
      case 'observation':
        return Colors.blue;
      case 'landmark':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'temple':
        return Icons.temple_buddhist;
      case 'shrine':
        return Icons.church;
      case 'food':
        return Icons.restaurant;
      case 'nature':
        return Icons.nature;
      case 'culture':
        return Icons.theater_comedy;
      case 'castle':
        return Icons.castle;
      case 'observation':
        return Icons.visibility;
      case 'landmark':
        return Icons.place;
      default:
        return Icons.location_on;
    }
  }

  Future<void> _promptTimeAndAdd(Map<String, dynamic> place) async {
    TimeOfDay? start;
    TimeOfDay? end;
    await showDialog(
      context: context,
      builder: (_) => _SelectTimesDialog(
        onSave: (s, e) {
          start = s;
          end = e;
        },
      ),
    );

    final trips = ref.read(tripsProvider);
    String? tripId;
    for (final t in trips) {
      if (t.days.any((d) => d.id == widget.dayId)) {
        tripId = t.id;
        break;
      }
    }

    final stop = StopItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      placeId: place['id'] as String,
      name: place['name'] as String,
      lat: (place['lat'] as num).toDouble(),
      lng: (place['lng'] as num).toDouble(),
      category: place['category'] as String?,
      startTs: start == null ? null : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, start!.hour, start!.minute),
      endTs: end == null ? null : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, end!.hour, end!.minute),
    );

    await ref.read(tripsProvider.notifier).addStop(widget.dayId, stop);

    if (!mounted) return;
    // Mark this day to be expanded when we land on the trip view
    ref.read(expandedDayIdProvider.notifier).state = widget.dayId;
    if (tripId != null) {
      context.go('/trip/${Uri.encodeComponent(tripId)}');
    } else {
      context.go('/itinerary');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${place['name']} to itinerary'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _SelectTimesDialog extends StatefulWidget {
  final void Function(TimeOfDay? start, TimeOfDay? end) onSave;
  const _SelectTimesDialog({required this.onSave});

  @override
  State<_SelectTimesDialog> createState() => _SelectTimesDialogState();
}

class _SelectTimesDialogState extends State<_SelectTimesDialog> {
  TimeOfDay? _start;
  TimeOfDay? _end;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Times (optional)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(_start != null ? _start!.format(context) : 'Not set'),
            onTap: () async {
              final TimeOfDay? t = await showTimePicker(context: context, initialTime: _start ?? TimeOfDay.now());
              if (t != null) setState(() => _start = t);
            },
            trailing: _start != null
                ? TextButton(onPressed: () => setState(() => _start = null), child: const Text('Clear'))
                : null,
          ),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(_end != null ? _end!.format(context) : 'Not set'),
            onTap: () async {
              final TimeOfDay? t = await showTimePicker(context: context, initialTime: _end ?? (_start ?? TimeOfDay.now()));
              if (t != null) setState(() => _end = t);
            },
            trailing: _end != null
                ? TextButton(onPressed: () => setState(() => _end = null), child: const Text('Clear'))
                : null,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_start, _end);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}


