import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Japan Guide')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Search places and events'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(onPressed: () => context.go('/itinerary'), icon: const Icon(Icons.event_note), label: const Text('New Trip')),
              ElevatedButton.icon(onPressed: () => context.go('/map'), icon: const Icon(Icons.place), label: const Text('Nearby')),
              ElevatedButton.icon(onPressed: () => context.go('/phrasebook'), icon: const Icon(Icons.translate), label: const Text('Phrasebook')),
              ElevatedButton.icon(onPressed: () => context.go('/more'), icon: const Icon(Icons.sos), label: const Text('Emergency')),
            ],
          ),
        ],
      ),
    );
  }
}


