import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const String trips = 'trips_box';
  static const String places = 'places_box';
  static const String phrases = 'phrases_box';
  static const String auth = 'auth_box';
  static const String users = 'users_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(trips),
      Hive.openBox(places),
      Hive.openBox(phrases),
      Hive.openBox(auth),
      Hive.openBox(users),
    ]);
  }
}


