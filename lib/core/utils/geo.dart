import 'dart:math' as math;

double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const double r = 6371.0;
  final double dLat = _deg2rad(lat2 - lat1);
  final double dLon = _deg2rad(lon2 - lon1);
  final double a =
      math.sin(dLat / 2) * math.sin(dLat / 2) + math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return r * c;
}

Duration estimateDurationTransitKm(double distanceKm, {String mode = 'transit'}) {
  if (mode == 'walk') {
    final double hours = distanceKm / 5.0; // 5 km/h walking
    return Duration(minutes: (hours * 60).round());
  }
  final double hours = distanceKm / 30.0; // 30 km/h transit heuristic
  return Duration(minutes: (hours * 60).round());
}

double _deg2rad(double deg) => deg * (math.pi / 180.0);


