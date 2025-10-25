import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';

import 'features/home/home_screen.dart';
import 'features/map_search/map_screen.dart';
import 'features/itinerary/itinerary_screen.dart';
import 'features/language/phrasebook_screen.dart';
import 'features/settings/more_screen.dart';
import 'features/language/login_screen.dart';
import 'features/language/register_screen.dart';
import 'features/emergency/emergency_screen.dart';
import 'features/settings/profile_screen.dart';
import 'features/settings/transport_help_screen.dart';
import 'features/settings/cultural_tips_screen.dart';
import 'features/settings/live_events_screen.dart';
import 'features/settings/travel_wallet_screen.dart';
import 'services/auth/auth_service.dart';
import 'features/settings/transport_city_screen.dart';
import 'features/itinerary/day_view_screen.dart';
import 'features/itinerary/add_place_screen.dart';
import 'features/language/phrasebook_main_screen.dart';
import 'features/language/saved_phrases_screen.dart';
import 'features/language/flashcards_screen.dart';
import 'features/home/alerts_list_screen.dart';

class AppRouter {
  static GoRouter createRouter() {
    final AuthService auth = const AuthService();
    return GoRouter(
      initialLocation: '/home',
      // Temporarily commented out login functionality for development
      // redirect: (context, state) {
      //   final bool signedIn = auth.isSignedIn;
      //   final String loc = state.matchedLocation;
      //   final bool goingToAuth = loc == '/login' || loc == '/register';
      //   if (!signedIn && !goingToAuth) return '/login';
      //   if (signedIn && goingToAuth) return '/home';
      //   return null;
      // },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) => const NoTransitionPage(child: LoginScreen()),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          pageBuilder: (context, state) => const NoTransitionPage(child: RegisterScreen()),
        ),
        ShellRoute(
          builder: (context, state, child) {
            final String location = state.matchedLocation;
            final int currentIndex = _indexForLocation(location);
            return Scaffold(
              body: child,
              bottomNavigationBar: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: NavigationBar(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    selectedIndex: currentIndex,
                    onDestinationSelected: (index) {
                      switch (index) {
                        case 0:
                          _navigateToTab(context, '/home');
                          break;
                        case 1:
                          _navigateToTab(context, '/map');
                          break;
                        case 2:
                          _navigateToTab(context, '/itinerary');
                          break;
                        case 3:
                          _navigateToTab(context, '/phrasebook');
                          break;
                        case 4:
                          _navigateToTab(context, '/more');
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
                ),
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
              path: '/trip/:tripId',
              name: 'trip-day-view',
              pageBuilder: (context, state) {
                final tripId = state.pathParameters['tripId'] ?? '';
                return NoTransitionPage(child: DayViewScreen(tripId: tripId));
              },
            ),
            GoRoute(
              path: '/add-place/:dayId',
              name: 'add-place',
              pageBuilder: (context, state) {
                final dayId = state.pathParameters['dayId'] ?? '';
                return NoTransitionPage(child: AddPlaceScreen(dayId: dayId));
              },
            ),
            GoRoute(
              path: '/phrasebook',
              name: 'phrasebook',
              pageBuilder: (context, state) => const NoTransitionPage(child: PhrasebookMainScreen()),
            ),
            // Add sub-routes for phrasebook pages
            GoRoute(
              path: '/phrasebook/all',
              name: 'phrasebook-all',
              pageBuilder: (context, state) => const NoTransitionPage(child: PhrasebookScreen()),
            ),
            GoRoute(
              path: '/phrasebook/saved',
              name: 'phrasebook-saved',
              pageBuilder: (context, state) => const NoTransitionPage(child: SavedPhrasesScreen()),
            ),
            GoRoute(
              path: '/phrasebook/flashcards',
              name: 'phrasebook-flashcards',
              pageBuilder: (context, state) => const NoTransitionPage(child: FlashcardsScreen()),
            ),
            GoRoute(
              path: '/more',
              name: 'more',
              pageBuilder: (context, state) => const NoTransitionPage(child: MoreScreen()),
            ),
            // Add sub-routes for more screen pages
            GoRoute(
              path: '/emergency',
              name: 'emergency',
              pageBuilder: (context, state) => const NoTransitionPage(child: EmergencyScreen()),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
            ),
            GoRoute(
              path: '/transport-help',
              name: 'transport-help',
              pageBuilder: (context, state) => const NoTransitionPage(child: TransportHelpScreen()),
            ),
            GoRoute(
              path: '/transport-help/:city',
              name: 'transport-city',
              pageBuilder: (context, state) {
                final city = state.pathParameters['city'] ?? 'Unknown';
                return NoTransitionPage(child: TransportCityScreen(city: city));
              },
            ),
            GoRoute(
              path: '/cultural-tips',
              name: 'cultural-tips',
              pageBuilder: (context, state) => const NoTransitionPage(child: CulturalTipsScreen()),
            ),
            GoRoute(
              path: '/live-events',
              name: 'live-events',
              pageBuilder: (context, state) => const NoTransitionPage(child: LiveEventsScreen()),
            ),
            GoRoute(
              path: '/travel-wallet',
              name: 'travel-wallet',
              pageBuilder: (context, state) => const NoTransitionPage(child: TravelWalletScreen()),
            ),
            GoRoute(
              path: '/alerts',
              name: 'alerts',
              pageBuilder: (context, state) => const NoTransitionPage(child: AlertsListScreen()),
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

  static void _navigateToTab(BuildContext context, String path) {
    // Always pop back to the main tab structure when switching tabs
    if (context.mounted) {
      final navigator = Navigator.of(context);
      // Pop all routes until we're back at the root (main tab structure)
      while (navigator.canPop()) {
        navigator.pop();
      }
    }
    // Add a small delay to ensure popping is complete, then navigate
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        context.go(path);
      }
    });
  }
}


