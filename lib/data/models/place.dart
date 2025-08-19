import 'lat_lng.dart';

class Place {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String? category;
  final String? address;
  final double? rating;
  final int? priceLevel;
  final Map<String, dynamic>? openingHours;
  final List<String>? photos;
  final String provider;

  const Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.category,
    this.address,
    this.rating,
    this.priceLevel,
    this.openingHours,
    this.photos,
    this.provider = 'google',
  });

  LatLng get location => LatLng(lat, lng);
}


