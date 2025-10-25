class StopItem {
  final String id;
  final String placeId;
  final String name;
  final double lat;
  final double lng;
  final String? category;
  final DateTime? startTs;
  final DateTime? endTs;
  final String transportMode;
  final String notes;
  final int sortIndex;
  final double? cost;

  const StopItem({
    required this.id,
    required this.placeId,
    required this.name,
    required this.lat,
    required this.lng,
    this.category,
    this.startTs,
    this.endTs,
    this.transportMode = 'transit',
    this.notes = '',
    this.sortIndex = 0,
    this.cost,
  });

  StopItem copyWith({
    String? id,
    String? placeId,
    String? name,
    double? lat,
    double? lng,
    String? category,
    DateTime? startTs,
    DateTime? endTs,
    String? transportMode,
    String? notes,
    int? sortIndex,
    double? cost,
  }) {
    return StopItem(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      category: category ?? this.category,
      startTs: startTs ?? this.startTs,
      endTs: endTs ?? this.endTs,
      transportMode: transportMode ?? this.transportMode,
      notes: notes ?? this.notes,
      sortIndex: sortIndex ?? this.sortIndex,
      cost: cost ?? this.cost,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'placeId': placeId,
        'name': name,
        'lat': lat,
        'lng': lng,
        'category': category,
        'startTs': startTs?.toIso8601String(),
        'endTs': endTs?.toIso8601String(),
        'transportMode': transportMode,
        'notes': notes,
        'sortIndex': sortIndex,
        'cost': cost,
      };

  static StopItem fromMap(Map<String, dynamic> map) => StopItem(
        id: map['id'] as String,
        placeId: map['placeId'] as String,
        name: map['name'] as String,
        lat: (map['lat'] as num).toDouble(),
        lng: (map['lng'] as num).toDouble(),
        category: map['category'] as String?,
        startTs: map['startTs'] != null ? DateTime.parse(map['startTs'] as String) : null,
        endTs: map['endTs'] != null ? DateTime.parse(map['endTs'] as String) : null,
        transportMode: map['transportMode'] as String? ?? 'transit',
        notes: map['notes'] as String? ?? '',
        sortIndex: map['sortIndex'] as int? ?? 0,
        cost: map['cost'] as double?,
      );
}


