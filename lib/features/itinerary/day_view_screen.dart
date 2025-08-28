import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/trip.dart';
import '../../data/models/stop.dart';
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
      appBar: AppBar(
        title: Text(trip.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 60),
                for (final day in trip.days)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      title: Text(_formatDayTitle(day)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit day',
                            icon: const Icon(Icons.edit_calendar),
                            onPressed: () async {
                              final _EditDayResult? res = await showDialog(
                                context: context,
                                builder: (_) => _EditDayDialog(initialDate: day.date, initialNickname: day.nickname),
                              );
                              if (res != null) {
                                await ref.read(tripsProvider.notifier).updateDay(day.id, date: res.date, nickname: res.nickname);
                              }
                            },
                          ),
                          IconButton(
                            tooltip: 'Delete day',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete day'),
                                  content: const Text('Are you sure you want to delete this day?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                    ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await ref.read(tripsProvider.notifier).deleteDay(day.id);
                              }
                            },
                          ),
                        ],
                      ),
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
                            return ListTile(
                              key: ValueKey(s.id),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueGrey.shade100,
                                child: Icon(_iconForCategory(s.category), color: Colors.blueGrey.shade700),
                              ),
                              title: Text(s.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${s.category ?? ''} ${s.startTs != null ? ' • ${DateFormat.Hm().format(s.startTs!)}' : ''}'),
                                  if (s.endTs != null) Text('Ends: ${DateFormat.Hm().format(s.endTs!)}'),
                                  if (s.cost != null) Text('Cost: ¥${s.cost!.toStringAsFixed(0)}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      final StopItem? edited = await showDialog(
                                        context: context,
                                        builder: (_) => _EditStopDialog(initial: s),
                                      );
                                      if (edited != null) {
                                        await ref.read(tripsProvider.notifier).updateStop(day.id, edited);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete stop'),
                                          content: const Text('Are you sure you want to delete this stop?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await ref.read(tripsProvider.notifier).deleteStop(day.id, s.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  final StopItem? custom = await showDialog(
                                    context: context,
                                    builder: (_) => _EditStopDialog(
                                      initial: StopItem(
                                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                                        placeId: 'custom',
                                        name: 'Custom Stop',
                                        lat: 35.6762,
                                        lng: 139.6503,
                                        category: 'custom',
                                        startTs: DateTime.now(),
                                      ),
                                    ),
                                  );
                                  if (custom != null) {
                                    await ref.read(tripsProvider.notifier).addStop(day.id, custom);
                                  }
                                },
                                icon: const Icon(Icons.add_location_alt),
                                label: const Text('Add custom stop'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.go('/add-place/${Uri.encodeComponent(day.id)}');
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add from list'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => _AddDayDialog(
              onAdd: (date, nickname) async {
                await ref.read(tripsProvider.notifier).addDay(trip.id, date, nickname: nickname);
              },
            ),
          );
        },
        icon: const Icon(Icons.today),
        label: const Text('Add day'),
      ),
    );
  }

  String _formatDayTitle(TripDay day) {
    final DateFormat formatter = DateFormat('EEE, MMM d');
    final dateStr = formatter.format(day.date);
    return day.nickname != null ? '$dateStr - ${day.nickname}' : dateStr;
  }
}

class _AddDayDialog extends StatefulWidget {
  final Future<void> Function(DateTime date, String? nickname) onAdd;
  const _AddDayDialog({required this.onAdd});

  @override
  State<_AddDayDialog> createState() => _AddDayDialogState();
}

class _AddDayDialogState extends State<_AddDayDialog> {
  DateTime _date = DateTime.now();
  final TextEditingController _nickname = TextEditingController();

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Day'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Date'),
            subtitle: Text(_date.toLocal().toIso8601String().split('T').first),
            onTap: () async {
              final DateTime? d = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (d != null) setState(() => _date = d);
            },
          ),
          TextField(
            controller: _nickname,
            decoration: const InputDecoration(
              labelText: 'Nickname (optional)',
              hintText: 'e.g., Shopping Day, Temple Day',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await widget.onAdd(_date, _nickname.text.trim().isEmpty ? null : _nickname.text.trim());
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _EditStopDialog extends StatefulWidget {
  final StopItem initial;
  const _EditStopDialog({required this.initial});

  @override
  State<_EditStopDialog> createState() => _EditStopDialogState();
}

class _EditStopDialogState extends State<_EditStopDialog> {
  late TextEditingController _name;
  late TextEditingController _cost;
  DateTime? _startTime;
  DateTime? _endTime;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial.name);
    _cost = TextEditingController(text: widget.initial.cost?.toString() ?? '');
    _startTime = widget.initial.startTs;
    _endTime = widget.initial.endTs;
    _selectedCategory = widget.initial.category;
  }

  @override
  void dispose() {
    _name.dispose();
    _cost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Stop'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cost,
            decoration: const InputDecoration(
              labelText: 'Cost (optional)',
              hintText: 'e.g., 1000',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Start Time (optional)'),
            subtitle: Text(_startTime != null ? DateFormat.Hm().format(_startTime!) : 'Not set'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: _startTime != null ? TimeOfDay.fromDateTime(_startTime!) : TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _startTime = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                  child: const Text('Pick'),
                ),
                if (_startTime != null)
                  TextButton(
                    onPressed: () => setState(() => _startTime = null),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          ListTile(
            title: const Text('End Time (optional)'),
            subtitle: Text(_endTime != null ? DateFormat.Hm().format(_endTime!) : 'Not set'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: _endTime != null ? TimeOfDay.fromDateTime(_endTime!) : TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _endTime = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                  child: const Text('Pick'),
                ),
                if (_endTime != null)
                  TextButton(
                    onPressed: () => setState(() => _endTime = null),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _IconSelector(
            initialCategory: _selectedCategory,
            onChanged: (c) => setState(() => _selectedCategory = c),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updated = widget.initial.copyWith(
              name: _name.text.trim(),
              cost: _cost.text.trim().isEmpty ? null : double.tryParse(_cost.text.trim()),
              startTs: _startTime,
              endTs: _endTime,
              category: _selectedCategory ?? widget.initial.category,
            );
            Navigator.of(context).pop(updated);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
IconData _iconForCategory(String? category) {
  switch ((category ?? '').toLowerCase()) {
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

class _IconSelector extends StatefulWidget {
  final String? initialCategory;
  final ValueChanged<String?> onChanged;
  const _IconSelector({required this.initialCategory, required this.onChanged});

  @override
  State<_IconSelector> createState() => _IconSelectorState();
}

class _IconSelectorState extends State<_IconSelector> {
  bool _expanded = false;

  List<String> get _categories => const [
        'temple', 'shrine', 'food', 'nature', 'culture', 'castle', 'observation', 'landmark'
      ];

  @override
  Widget build(BuildContext context) {
    final String? selected = widget.initialCategory;
    final IconData currentIcon = _iconForCategory(selected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blueGrey.shade100,
                child: Icon(currentIcon, size: 18, color: Colors.blueGrey.shade700),
              ),
              const SizedBox(width: 8),
              Text(selected == null || selected.isEmpty ? 'Default icon' : selected),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String?>(
                  value: selected?.isEmpty == true ? null : selected,
                  isExpanded: true,
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Default'),
                    ),
                    ..._categories.map((c) => DropdownMenuItem<String?>(
                          value: c,
                          child: Row(
                            children: [Icon(_iconForCategory(c)), const SizedBox(width: 8), Text(c)],
                          ),
                        )),
                  ],
                  onChanged: (val) {
                    widget.onChanged(val);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}





class _EditDayResult {
  final DateTime date;
  final String? nickname;
  const _EditDayResult(this.date, this.nickname);
}

class _EditDayDialog extends StatefulWidget {
  final DateTime initialDate;
  final String? initialNickname;
  const _EditDayDialog({required this.initialDate, this.initialNickname});

  @override
  State<_EditDayDialog> createState() => _EditDayDialogState();
}

class _EditDayDialogState extends State<_EditDayDialog> {
  late DateTime _date;
  late TextEditingController _nickname;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    _nickname = TextEditingController(text: widget.initialNickname ?? '');
  }

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Day'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Date'),
            subtitle: Text(_date.toLocal().toIso8601String().split('T').first),
            onTap: () async {
              final DateTime? d = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (d != null) setState(() => _date = d);
            },
          ),
          TextField(
            controller: _nickname,
            decoration: const InputDecoration(
              labelText: 'Nickname (optional)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_EditDayResult(_date, _nickname.text.trim().isEmpty ? null : _nickname.text.trim())),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

