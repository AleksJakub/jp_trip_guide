import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/stop.dart';
import '../../../data/models/trip.dart';
import '../../../data/repos/trips_repository.dart';

final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  return LocalTripsRepository();
});

final tripsProvider = NotifierProvider<TripsNotifier, List<Trip>>(() => TripsNotifier());

class TripsNotifier extends Notifier<List<Trip>> {
  @override
  List<Trip> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final repo = ref.read(tripsRepositoryProvider);
    final trips = await repo.listTrips();
    state = trips;
  }

  Future<void> createTrip(String title, DateTime start, DateTime end, {String tz = 'Asia/Tokyo', int partySize = 1}) async {
    final repo = ref.read(tripsRepositoryProvider);
    final Trip t = await repo.createTrip(title, start, end, tz: tz, partySize: partySize);
    state = [...state, t];
  }

  Future<void> deleteTrip(String id) async {
    final repo = ref.read(tripsRepositoryProvider);
    await repo.deleteTrip(id);
    state = [...state]..removeWhere((t) => t.id == id);
  }

  Future<void> addDay(String tripId, DateTime date) async {
    final repo = ref.read(tripsRepositoryProvider);
    final Trip updated = await repo.addDay(tripId, date);
    state = [for (final t in state) if (t.id == updated.id) updated else t];
  }

  Future<void> addStop(String dayId, StopItem stop) async {
    final repo = ref.read(tripsRepositoryProvider);
    final Trip updated = await repo.addStop(dayId, stop);
    state = [for (final t in state) if (t.id == updated.id) updated else t];
  }

  Future<void> reorderStops(String dayId, List<StopItem> stops) async {
    final repo = ref.read(tripsRepositoryProvider);
    final Trip updated = await repo.reorderStops(dayId, stops);
    state = [for (final t in state) if (t.id == updated.id) updated else t];
  }
}

final currentTripIdProvider = StateProvider<String?>((ref) => null);


