import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const String trips = 'trips_box';
  static const String places = 'places_box';
  static const String phrases = 'phrases_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(trips),
      Hive.openBox(places),
      Hive.openBox(phrases),
    ]);
  }
}


