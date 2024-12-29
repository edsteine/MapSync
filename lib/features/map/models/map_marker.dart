// lib/features/map/models/map_marker.dart
// lib/features/map/models/map_marker.dart
import 'package:hive/hive.dart';

part 'map_marker.g.dart';

@HiveType(typeId: 0)
class MapMarker {
  MapMarker({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.description,
  });
  factory MapMarker._validateAndCreateMapMarker(Map<String, dynamic> json) {
    final String? id = json['id'];
    final String? title = json['title'];
    final dynamic latitude = json['latitude'];
    final dynamic longitude = json['longitude'];
    final String? description = json['description'];

    if (id == null || id.isEmpty) {
      throw ArgumentError('MapMarker id cannot be null or empty.');
    }
    if (title == null || title.isEmpty) {
      throw ArgumentError('MapMarker title cannot be null or empty.');
    }
    if (latitude == null) {
      throw ArgumentError('MapMarker latitude cannot be null.');
    }
    if (longitude == null) {
      throw ArgumentError('MapMarker longitude cannot be null.');
    }
    if (description == null) {
      throw ArgumentError('MapMarker description cannot be null.');
    }

    if (latitude is! num) {
      throw ArgumentError('MapMarker latitude must be a number.');
    }

    if (longitude is! num) {
      throw ArgumentError('MapMarker longitude must be a number.');
    }
    return MapMarker(
      id: id,
      title: title,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      description: description,
    );
  }
  factory MapMarker.fromJson(Map<String, dynamic> json) =>
      MapMarker._validateAndCreateMapMarker(json);

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final String description;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
      };
}
