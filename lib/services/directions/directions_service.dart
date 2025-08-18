import '../../data/models/lat_lng.dart';

class RouteSummary {
  final Duration duration;
  final List<String> steps;
  const RouteSummary({required this.duration, this.steps = const []});
}

abstract class DirectionsService {
  Future<RouteSummary> route(LatLng from, LatLng to, {String mode = 'transit', DateTime? departure});
}


