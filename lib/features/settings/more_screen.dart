import 'package:flutter/material.dart';
import '../emergency/emergency_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.sos),
            title: const Text('Emergency'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmergencyScreen())),
          ),
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings (coming soon)'),
          ),
        ],
      ),
    );
  }
}


