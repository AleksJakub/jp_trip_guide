import 'package:hive_flutter/hive_flutter.dart';

import '../local/hive_boxes.dart';
import '../models/trip.dart';
import '../models/stop.dart';

abstract class TripsRepository {
  Future<List<Trip>> listTrips();
  Future<Trip> createTrip(String title, DateTime start, DateTime end, {String tz = 'Asia/Tokyo', int partySize = 1});
  Future<void> deleteTrip(String tripId);
  Future<Trip> addDay(String tripId, DateTime date, {String? nickname});
  Future<Trip> updateDay(String dayId, {DateTime? date, String? nickname});
  Future<Trip> deleteDay(String dayId);
  Future<Trip> addStop(String dayId, StopItem stop);
  Future<Trip> reorderStops(String dayId, List<StopItem> stops);
  Future<Trip> updateStop(String dayId, StopItem stop);
  Future<Trip> deleteStop(String dayId, String stopId);
  Future<Trip> updateTrip(String tripId, {String? title, DateTime? start, DateTime? end});
}

class LocalTripsRepository implements TripsRepository {
  Box get _box => Hive.box(HiveBoxes.trips);

  @override
  Future<List<Trip>> listTrips() async {
    final List<dynamic> raw = _box.get('trips', defaultValue: <dynamic>[]) as List<dynamic>;
    return raw.map((e) => Trip.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<Trip> createTrip(String title, DateTime start, DateTime end, {String tz = 'Asia/Tokyo', int partySize = 1}) async {
    final Trip trip = Trip(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      startDate: start,
      endDate: end,
      tz: tz,
      partySize: partySize,
    );
    final List<Trip> trips = await listTrips()..add(trip);
    await _box.put('trips', trips.map((t) => t.toMap()).toList());
    return trip;
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    final List<Trip> trips = await listTrips()..removeWhere((t) => t.id == tripId);
    await _box.put('trips', trips.map((t) => t.toMap()).toList());
  }

  @override
  Future<Trip> addDay(String tripId, DateTime date, {String? nickname}) async {
    final List<Trip> trips = await listTrips();
    final int index = trips.indexWhere((t) => t.id == tripId);
    if (index == -1) throw Exception('Trip not found');
    final Trip trip = trips[index];
    // prevent duplicate
    final bool exists = trip.days.any((d) => DateTime(d.date.year, d.date.month, d.date.day) == DateTime(date.year, date.month, date.day));
    if (exists) return trip;
    final TripDay day = TripDay(id: 'd_${date.millisecondsSinceEpoch}', date: date, nickname: nickname);
    final Trip updated = trip.copyWith(days: [...trip.days, day]);
    trips[index] = updated;
    await _box.put('trips', trips.map((t) => t.toMap()).toList());
    return updated;
  }

  @override
  Future<Trip> updateDay(String dayId, {DateTime? date, String? nickname}) async {
    final List<Trip> trips = await listTrips();
    for (int i = 0; i < trips.length; i++) {
      final Trip t = trips[i];
      final int dayIndex = t.days.indexWhere((d) => d.id == dayId);
      if (dayIndex != -1) {
        final TripDay day = t.days[dayIndex];
        final TripDay newDay = day.copyWith(
          date: date ?? day.date,
          nickname: nickname ?? day.nickname,
        );
        final Trip updated = t.copyWith(days: [...t.days]..[dayIndex] = newDay);
        trips[i] = updated;
        await _box.put('trips', trips.map((t) => t.toMap()).toList());
        return updated;
      }
    }
    throw Exception('Day not found');
  }

  @override
  Future<Trip> deleteDay(String dayId) async {
    final List<Trip> trips = await listTrips();
    for (int i = 0; i < trips.length; i++) {
      final Trip t = trips[i];
      final int dayIndex = t.days.indexWhere((d) => d.id == dayId);
      if (dayIndex != -1) {
        final List<TripDay> newDays = [
          for (int j = 0; j < t.days.length; j++) if (j != dayIndex) t.days[j]
        ];
        final Trip updated = t.copyWith(days: newDays);
        trips[i] = updated;
        await _box.put('trips', trips.map((t) => t.toMap()).toList());
        return updated;
      }
    }
    throw Exception('Day not found');
  }

  @override
  Future<Trip> addStop(String dayId, StopItem stop) async {
    final List<Trip> trips = await listTrips();
    for (int i = 0; i < trips.length; i++) {
      final Trip t = trips[i];
      final int dayIndex = t.days.indexWhere((d) => d.id == dayId);
      if (dayIndex != -1) {
        final TripDay day = t.days[dayIndex];
        final TripDay newDay = day.copyWith(stops: [...day.stops, stop]);
        final Trip updated = t.copyWith(days: [...t.days]..[dayIndex] = newDay);
        trips[i] = updated;
        await _box.put('trips', trips.map((t) => t.toMap()).toList());
        return updated;
      }
    }
    throw Exception('Day not found');
  }

  @override
  Future<Trip> reorderStops(String dayId, List<StopItem> stops) async {
    final List<Trip> trips = await listTrips();
    for (int i = 0; i < trips.length; i++) {
      final Trip t = trips[i];
      final int dayIndex = t.days.indexWhere((d) => d.id == dayId);
      if (dayIndex != -1) {
        final TripDay day = t.days[dayIndex];
        final TripDay newDay = day.copyWith(stops: stops);
        final Trip updated = t.copyWith(days: [...t.days]..[dayIndex] = newDay);
        trips[i] = updated;
        await _box.put('trips', trips.map((t) => t.toMap()).toList());
        return updated;
      }
    }
    throw Exception('Day not found');
  }

  @override
  Future<Trip> updateStop(String dayId, StopItem stop) async {
    final List<Trip> trips = await listTrips();
    for (int i = 0; i < trips.length; i++) {
      final Trip t = trips[i];
      final int dayIndex = t.days.indexWhere((d) => d.id == dayId);
      if (dayIndex != -1) {
        final TripDay day = t.days[dayIndex];
        final List<StopItem> updatedStops = [
          for (final s in day.stops) if (s.id == stop.id) stop else s
        ];
        final TripDay newDay = day.copyWith(stops: updatedStops);
        final Trip updated = t.copyWith(days: [...t.days]..[dayIndex] = newDay);
        trips[i] = updated;
        await _box.put('trips', trips.map((t) => t.toMap()).toList());
        return updated;
      }
    }
    throw Exception('Day not found');
  }

  @override
  Future<Trip> deleteStop(String dayId, String stopId) async {
    final List<Trip> trips = await listTrips();
    for (int i = 0; i < trips.length; i++) {
      final Trip t = trips[i];
      final int dayIndex = t.days.indexWhere((d) => d.id == dayId);
      if (dayIndex != -1) {
        final TripDay day = t.days[dayIndex];
        final List<StopItem> updatedStops = day.stops.where((s) => s.id != stopId).toList();
        final TripDay newDay = day.copyWith(stops: updatedStops);
        final Trip updated = t.copyWith(days: [...t.days]..[dayIndex] = newDay);
        trips[i] = updated;
        await _box.put('trips', trips.map((t) => t.toMap()).toList());
        return updated;
      }
    }
    throw Exception('Day not found');
  }

  @override
  Future<Trip> updateTrip(String tripId, {String? title, DateTime? start, DateTime? end}) async {
    final List<Trip> trips = await listTrips();
    final int index = trips.indexWhere((t) => t.id == tripId);
    if (index == -1) throw Exception('Trip not found');
    Trip t = trips[index];
    t = t.copyWith(title: title, startDate: start, endDate: end);
    trips[index] = t;
    await _box.put('trips', trips.map((t) => t.toMap()).toList());
    return t;
  }
}


