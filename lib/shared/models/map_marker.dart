// lib/features/map/models/map_marker.dart
import 'package:hive/hive.dart';
part 'map_marker.g.dart';

@HiveType(typeId: 0)
class MapMarker {
  MapMarker({
    required this.id,
    required this.title,
    required this.description,
    required this.geometry,
  });
  factory MapMarker._validateAndCreateMapMarker(Map<String, dynamic> json) {
    final String? id = json['id'];
    final String? title = json['title'];
    final String? description = json['description'];
    final dynamic geometry = json['geometry'];
    if (id == null || id.isEmpty) {
      throw ArgumentError('MapMarker id cannot be null or empty.');
    }
    if (title == null || title.isEmpty) {
      throw ArgumentError('MapMarker title cannot be null or empty.');
    }
    if (description == null) {
      throw ArgumentError('MapMarker description cannot be null.');
    }
    if (geometry == null) {
      throw ArgumentError('MapMarker geometry cannot be null.');
    }
    return MapMarker(
      id: id,
      title: title,
      description: description,
      geometry: Geometry.fromJson(geometry),
    );
  }
  factory MapMarker.fromJson(Map<String, dynamic> json) =>
      MapMarker._validateAndCreateMapMarker(json);

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final Geometry geometry;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'geometry': geometry.toJson(),
      };
}

@HiveType(typeId: 2)
enum GeometryType {
  @HiveField(0)
  point,
  @HiveField(1)
  lineString,
  @HiveField(2)
  polygon
}

@HiveType(typeId: 1)
class Geometry {
  Geometry({
    required this.type,
    required this.coordinates,
  });
  factory Geometry.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    final coordinates = json['coordinates'];
    if (type == null || type is! String) {
      throw ArgumentError('Invalid geometry type: $type');
    }
    if (coordinates == null || coordinates is! List) {
      throw ArgumentError('Invalid geometry coordinates: $coordinates');
    }
    return Geometry(
      type: _parseType(type),
      coordinates: coordinates,
    );
  }
  Map<String, dynamic> toJson() => {
        'type': type.name,
        'coordinates': coordinates,
      };
  static GeometryType _parseType(String type) {
    switch (type) {
      case 'Point':
        return GeometryType.point;
      case 'LineString':
        return GeometryType.lineString;
      case 'Polygon':
        return GeometryType.polygon;
      default:
        throw ArgumentError('Invalid geometry type: $type');
    }
  }

  @HiveField(0)
  late final GeometryType type;
  @HiveField(1)
  late final List<dynamic> coordinates;
}
