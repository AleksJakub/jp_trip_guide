import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransportHelpScreen extends StatelessWidget {
  const TransportHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Help'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/more'),
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Popular Cities',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ...['Japan', 'Tokyo', 'Osaka', 'Kyoto'].map((c) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(c),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/transport-help/${Uri.encodeComponent(c)}'),
                  ),
                )),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Other Cities',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ...['Nara', 'Kobe', 'Fukuoka', 'Hokkaido', 'Sapporo', 'Hiroshima', 'Yokohama', 'Kanazawa', 'Takayama'].map((c) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(c),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/transport-help/${Uri.encodeComponent(c)}'),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


