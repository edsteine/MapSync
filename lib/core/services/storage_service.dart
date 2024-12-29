// lib/core/services/storage_service.dart
import 'package:flutter/foundation.dart'; // Import kDebugMode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/core/utils/app_constants.dart';
import 'package:mobile/features/map/models/map_marker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  late Box<MapMarker> _markerBox;
  late SharedPreferences _prefs;
  static Future<Storage> init() async {
    final storage = Storage();
    await Hive.initFlutter();
    Hive.registerAdapter(MapMarkerAdapter());
    storage
      .._markerBox = await Hive.openBox<MapMarker>(AppConstants.markersKey)
      .._prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print('Storage Initialized');
    }
    return storage;
  }

  // Marker operations
  Future<void> saveMarkers(List<MapMarker> markers) async {
    await _markerBox.clear();
    await _markerBox.putAll(
      Map.fromIterables(
        markers.map((e) => e.id),
        markers,
      ),
    );
  }

  List<MapMarker> getMarkers() => _markerBox.values.toList();

  // Preferences operations
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) => _prefs.getString(key);

  Future<void> saveBool(String key, {required bool value}) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> clearAll() async {
    if (kDebugMode) {
      print('Clearing All Storage');
    }
    await _markerBox.clear();
    await _prefs.clear();
    if (kDebugMode) {
      print('All storage cleared');
    }
  }
}

final storageProvider2 = FutureProvider<Storage>((ref) async {
  final storage = await Storage.init();
  return storage;
});
