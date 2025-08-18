import '../../data/models/lat_lng.dart';

class EventItem {
  final String id;
  final String name;
  final DateTime? startTs;
  final DateTime? endTs;
  final double? lat;
  final double? lng;
  final String? address;
  final String? url;
  final List<String> tags;

  const EventItem({
    required this.id,
    required this.name,
    this.startTs,
    this.endTs,
    this.lat,
    this.lng,
    this.address,
    this.url,
    this.tags = const [],
  });
}

abstract class EventsService {
  Future<List<EventItem>> list({LatLng? center, int radiusM = 5000, DateTime? from, DateTime? to, List<String>? tags});
}


