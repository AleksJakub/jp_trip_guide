import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../itinerary/state/trips_provider.dart';
import 'quick_tip_card.dart';
import 'weather_card.dart';
import 'upcoming_events_card.dart';
import 'alerts_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WelcomeCard(),
                  const SizedBox(height: 16),
                  const TodayItineraryCard(),
                  const SizedBox(height: 16),
                  const WeatherCard(),
                  const SizedBox(height: 16),
                  const AlertsCard(),
                  const SizedBox(height: 16),
                  const QuickTipCard(),
                  const SizedBox(height: 16),
                  const UpcomingEventsCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'images/image2.png',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Welcome to NipponGo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your smart companion for traveling Japan.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodayItineraryCard extends ConsumerWidget {
  const TodayItineraryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List trips = ref.watch(tripsProvider);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    // Gather all days matching today across trips
    final List<Map<String, dynamic>> candidateDays = [];
    for (final dynamic t in trips) {
      final dynamic trip = t;
      for (final dynamic d in trip.days) {
        final DateTime dDate = DateTime(d.date.year, d.date.month, d.date.day);
        if (dDate == today) {
          candidateDays.add({'trip': trip, 'day': d});
        }
      }
    }

    if (candidateDays.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.event_note, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "You don't have an itinerary for today yet. Create one to see your schedule here!",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/itinerary'),
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      );
    }

    // Choose one of today's itineraries (first is fine per requirement)
    final dynamic chosen = candidateDays.first;
    final dynamic day = chosen['day'];
    final dynamic trip = chosen['trip'];

    // Find upcoming stop by start time after now; otherwise last stop
    final DateTime nowTs = DateTime.now();
    final List stops = [...day.stops]..sort((a, b) => (a.startTs ?? DateTime(0)).compareTo(b.startTs ?? DateTime(0)));
    dynamic upcoming = stops.firstWhere(
      (s) => (s.startTs ?? nowTs).isAfter(nowTs),
      orElse: () => stops.isNotEmpty ? stops.last : null,
    );

    final DateFormat hm = DateFormat.Hm();
    final String title = trip.title as String;
    final String subtitle;
    if (upcoming == null) {
      subtitle = 'No plans scheduled for the rest of today';
    } else {
      final String whenStr = upcoming.startTs != null ? hm.format(upcoming.startTs as DateTime) : 'Anytime';
      subtitle = 'Next: ${upcoming.name} • $whenStr';
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.today),
        title: Text('Today in "$title"'),
        subtitle: Text(subtitle),
        onTap: () => context.go('/itinerary'),
      ),
    );
  }
}

