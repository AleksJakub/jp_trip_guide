import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_screen.dart';
import 'features/map_search/map_screen.dart';
import 'features/itinerary/itinerary_screen.dart';
import 'features/language/phrasebook_screen.dart';
import 'features/settings/more_screen.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            final String location = state.matchedLocation;
            final int currentIndex = _indexForLocation(location);
            return Scaffold(
              body: child,
              bottomNavigationBar: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) {
                  switch (index) {
                    case 0:
                      context.go('/home');
                      break;
                    case 1:
                      context.go('/map');
                      break;
                    case 2:
                      context.go('/itinerary');
                      break;
                    case 3:
                      context.go('/phrasebook');
                      break;
                    case 4:
                      context.go('/more');
                      break;
                  }
                },
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
                  NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Itinerary'),
                  NavigationDestination(icon: Icon(Icons.translate), selectedIcon: Icon(Icons.translate), label: 'Phrasebook'),
                  NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: 'More'),
                ],
              ),
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
            ),
            GoRoute(
              path: '/map',
              name: 'map',
              pageBuilder: (context, state) => const NoTransitionPage(child: MapScreen()),
            ),
            GoRoute(
              path: '/itinerary',
              name: 'itinerary',
              pageBuilder: (context, state) => const NoTransitionPage(child: ItineraryScreen()),
            ),
            GoRoute(
              path: '/phrasebook',
              name: 'phrasebook',
              pageBuilder: (context, state) => const NoTransitionPage(child: PhrasebookScreen()),
            ),
            GoRoute(
              path: '/more',
              name: 'more',
              pageBuilder: (context, state) => const NoTransitionPage(child: MoreScreen()),
            ),
          ],
        ),
      ],
    );
  }

  static int _indexForLocation(String location) {
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/itinerary')) return 2;
    if (location.startsWith('/phrasebook')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }
}


