import '../../data/models/lat_lng.dart';
import '../../data/models/place.dart';

abstract class PlacesService {
  Future<List<Place>> searchNearby(LatLng center, {String? query, List<String>? types, int radiusM = 1500});
  Future<Place> getDetails(String providerPlaceId);
  Future<List<int>> getPhoto(String photoRef, {int? maxWidth});
}


