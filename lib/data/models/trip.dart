import 'stop.dart';

class Trip {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int partySize;
  final String tz;
  final List<TripDay> days;

  const Trip({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.partySize = 1,
    this.tz = 'Asia/Tokyo',
    this.days = const [],
  });

  Trip copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? partySize,
    String? tz,
    List<TripDay>? days,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      partySize: partySize ?? this.partySize,
      tz: tz ?? this.tz,
      days: days ?? this.days,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'partySize': partySize,
        'tz': tz,
        'days': days.map((d) => d.toMap()).toList(),
      };

  static Trip fromMap(Map<String, dynamic> map) => Trip(
        id: map['id'] as String,
        title: map['title'] as String,
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: DateTime.parse(map['endDate'] as String),
        partySize: map['partySize'] as int? ?? 1,
        tz: map['tz'] as String? ?? 'Asia/Tokyo',
        days: (map['days'] as List<dynamic>? ?? const [])
            .map((e) => TripDay.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
}

class TripDay {
  final String id;
  final DateTime date;
  final String notes;
  final List<StopItem> stops;
  final String? nickname;
  final DateTime? endTime;

  const TripDay({
    required this.id,
    required this.date,
    this.notes = '',
    this.stops = const [],
    this.nickname,
    this.endTime,
  });

  TripDay copyWith({
    String? id,
    DateTime? date,
    String? notes,
    List<StopItem>? stops,
    String? nickname,
    DateTime? endTime,
  }) {
    return TripDay(
      id: id ?? this.id,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      stops: stops ?? this.stops,
      nickname: nickname ?? this.nickname,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'notes': notes,
        'stops': stops.map((s) => s.toMap()).toList(),
        'nickname': nickname,
        'endTime': endTime?.toIso8601String(),
      };

  static TripDay fromMap(Map<String, dynamic> map) => TripDay(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        notes: map['notes'] as String? ?? '',
        stops: (map['stops'] as List<dynamic>? ?? const [])
            .map((e) => StopItem.fromMap(e as Map<String, dynamic>))
            .toList(),
        nickname: map['nickname'] as String?,
        endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      );
}


