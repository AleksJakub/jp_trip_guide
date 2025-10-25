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
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Planner'),
                      Tab(text: 'Tips'),
                      Tab(text: 'Emergency'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _OverviewTab(),
                        _PlannerTab(),
                        _TipsTab(),
                        _EmergencyTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<Widget> body;
  const _Card({required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...body,
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(
          icon: Icons.credit_card,
          color: Colors.teal,
          title: 'IC Cards (Suica / PASMO / ICOCA)',
          body: const [
            Text('Tap-to-pay transit card used across most cities.'),
            SizedBox(height: 8),
            Text('Where to buy/top up: machines, kiosks, convenience stores.'),
            SizedBox(height: 8),
            Text('How to use: tap at gate on entry and exit.'),
          ],
        ),
        _Card(
          icon: Icons.train,
          color: Colors.indigo,
          title: 'JR Pass',
          body: const [
            Text('Eligibility: tourists only. Use on most JR lines nationwide.'),
            SizedBox(height: 4),
            Text('Not valid on Nozomi/Mizuho Shinkansen services.'),
            SizedBox(height: 8),
            SelectableText('Official site: https://japanrailpass.net/'),
            SizedBox(height: 8),
            Text('Coverage: JR network nationwide (see JR map).'),
          ],
        ),
        _Card(
          icon: Icons.nightlight_round,
          color: Colors.orange,
          title: 'Last Train Times',
          body: const [
            Text('Most last trains run around 00:00. Don\'t get stranded!'),
            SizedBox(height: 8),
            Text('Common lines: Yamanote (Tokyo), Osaka Loop (Osaka).'),
          ],
        ),
      ],
    );
  }
}

class _PlannerTab extends StatefulWidget {
  @override
  State<_PlannerTab> createState() => _PlannerTabState();
}

class _PlannerTabState extends State<_PlannerTab> {
  final TextEditingController _from = TextEditingController();
  final TextEditingController _to = TextEditingController();
  final TextEditingController _stations = TextEditingController();

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _stations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(
          icon: Icons.directions_transit,
          color: Colors.blue,
          title: 'Live / Local Timetable',
          body: [
            TextField(controller: _from, decoration: const InputDecoration(labelText: 'From (station or address)')),
            const SizedBox(height: 8),
            TextField(controller: _to, decoration: const InputDecoration(labelText: 'To (station or address)')),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final String url = 'https://www.google.com/maps/dir/?api=1&origin='
                    '${Uri.encodeComponent(_from.text)}&destination=${Uri.encodeComponent(_to.text)}&travelmode=transit';
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open in browser: $url')));
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Transit Directions'),
            ),
          ],
        ),
        _Card(
          icon: Icons.map,
          color: Colors.green,
          title: 'Maps',
          body: const [
            SelectableText('Tokyo Metro map: https://www.tokyometro.jp/en/subwaymap/pdf/routemap_en.pdf'),
            SizedBox(height: 8),
            SelectableText('JR Shinkansen routes: https://global.jr-central.co.jp/en/info/route-map/'),
          ],
        ),
        _Card(
          icon: Icons.payments,
          color: Colors.purple,
          title: 'Fare Estimator (rough)',
          body: [
            const Text('Enter approx number of stations to estimate local fare (very rough).'),
            const SizedBox(height: 8),
            TextField(controller: _stations, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stations (e.g., 5)')),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                int n = int.tryParse(_stations.text) ?? 0;
                int fare = n <= 1 ? 140 : 140 + (n - 1) * 30; // simple heuristic
                return Text('Estimated fare: ~¥$fare');
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _TipsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget section(String title, List<String> items, IconData icon) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(icon, color: Colors.blueGrey), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
              const SizedBox(height: 8),
              for (final s in items) Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [const Text('• '), Expanded(child: Text(s))])),
            ]),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        section('Trains', [
          'Line up in marked queues on platforms.',
          'Carriage # signs help you stand at the right spot.',
          'Priority seats — avoid unless needed.',
        ], Icons.train),
        section('Shinkansen', [
          'Seat reservations vs unreserved cars.',
          'Store luggage in overhead or designated areas.',
          'Buy ekiben (station lunch boxes).',
        ], Icons.directions_railway),
        section('Buses', [
          'Enter from the middle or rear in many cities.',
          'Pay when exiting; exact change or IC card.',
        ], Icons.directions_bus),
        section('Taxis', [
          'Doors open automatically (don’t pull the handle).',
          'Expensive, but reliable for late nights when trains stop.',
        ], Icons.local_taxi),
      ],
    );
  }
}

class _EmergencyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _Card(
          icon: Icons.hotel,
          color: Colors.brown,
          title: 'Missed the Last Train',
          body: [
            Text('Consider capsule hotels, late buses, or taxis.'),
          ],
        ),
        _Card(
          icon: Icons.support_agent,
          color: Colors.red,
          title: 'Lost IC Card',
          body: [
            Text('Go to the nearest station service counter for assistance.'),
          ],
        ),
        _Card(
          icon: Icons.warning,
          color: Colors.amber,
          title: 'Delays / Typhoons',
          body: [
            Text('Trains may stop; check status and have backup routes.'),
          ],
        ),
      ],
    );
  }
}


