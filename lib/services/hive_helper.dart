import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {
  static const String usersBoxName = 'users_box';
  static const String wishlistBoxName = 'wishlist_box';
  static const String settingsBoxName = 'settings_box';
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    await Hive.openBox<Map>(usersBoxName);
    await Hive.openBox<Map>(wishlistBoxName);
    await Hive.openBox(settingsBoxName);
    _initialized = true;
  }

  static Box<Map> get usersBox => Hive.box<Map>(usersBoxName);
  static Box<Map> get wishlistBox => Hive.box<Map>(wishlistBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
}
