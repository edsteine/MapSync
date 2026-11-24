///
/// File: lib/shared/models/map_marker.dart
/// Author: Adil AJDAA
/// Email: a.ajdaa@outlook.com
/// Purpose: Defines the data models for map markers and their geometry, used for handling and storing geospatial data.
/// Updates: Initial setup with MapMarker, Geometry, and GeometryType models for managing geospatial data, added json parsing functionality.
/// Used Libraries: hive/hive.dart
///
library;
import 'package:hive/hive.dart';
part 'map_marker.g.dart';

/// Represents a map marker with an ID, title, description, and geometry.
@HiveType(typeId: 0)
class MapMarker {
   /// Constructor for the MapMarker class, requires `id`, `title`, `description` and `geometry`
  MapMarker({
    required this.id,
    required this.title,
    required this.description,
    required this.geometry,
  });
  /// Validates the JSON data and creates the MapMarker model.
  factory MapMarker._validateAndCreateMapMarker(Map<String, dynamic> json) {
    final String? id = json['id'];
    final String? title = json['title'];
    final String? description = json['description'];
    final dynamic geometry = json['geometry'];
    // Throws errors if the id or title is null or empty.
    if (id == null || id.isEmpty) {
      throw ArgumentError('MapMarker id cannot be null or empty.');
    }
    if (title == null || title.isEmpty) {
      throw ArgumentError('MapMarker title cannot be null or empty.');
    }
      // Throws an error if the description or the geometry is null
    if (description == null) {
      throw ArgumentError('MapMarker description cannot be null.');
    }
    if (geometry == null) {
      throw ArgumentError('MapMarker geometry cannot be null.');
    }
       // Creates and return the new `MapMarker`.
    return MapMarker(
      id: id,
      title: title,
      description: description,
      geometry: Geometry.fromJson(geometry),
    );
  }
   /// Creates a `MapMarker` instance from a JSON object, validates the data and calls the `_validateAndCreateMapMarker` function.
  factory MapMarker.fromJson(Map<String, dynamic> json) =>
      MapMarker._validateAndCreateMapMarker(json);

  /// Unique identifier for the map marker
  @HiveField(0)
  final String id;

  ///  Title of the map marker
  @HiveField(1)
  final String title;

  /// Description of the map marker
  @HiveField(2)
  final String description;

  /// Geometry of the map marker.
  @HiveField(3)
  final Geometry geometry;

   /// Converts MapMarker object to a JSON object
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'geometry': geometry.toJson(),
      };
}

/// Enum representing the type of geometry (point, linestring, polygon).
@HiveType(typeId: 2)
enum GeometryType {
  /// Point geometry type.
  @HiveField(0)
  point,
  /// LineString geometry type.
  @HiveField(1)
  lineString,
  /// Polygon geometry type.
  @HiveField(2)
  polygon
}

/// Represents the geometry of a map marker, can be of type point, linestring or polygon
@HiveType(typeId: 1)
class Geometry {
  /// Constructor for the geometry class, takes the `type` and `coordinates` as a parameter.
  Geometry({
    required this.type,
    required this.coordinates,
  });
  /// Creates a `Geometry` object from JSON data, includes validation for geometry type and coordinates
  factory Geometry.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    final coordinates = json['coordinates'];
       // Checks if type is null or not string.
    if (type == null || type is! String) {
      throw ArgumentError('Invalid geometry type: $type');
    }
    // Checks if the coordinates is null or not a List.
    if (coordinates == null || coordinates is! List) {
      throw ArgumentError('Invalid geometry coordinates: $coordinates');
    }
        // Parses the coordinates to a GeometryType
    return Geometry(
      type: _parseType(type),
      coordinates: coordinates,
    );
  }
    /// Creates a JSON object from a `Geometry` model
  Map<String, dynamic> toJson() => {
        'type': type.name,
        'coordinates': coordinates,
      };
  /// Parses a geometry type from a string, throws exception when not a valid type.
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

  /// Type of the geometry, it can be `Point`, `LineString` or `Polygon`.
  @HiveField(0)
  late final GeometryType type;
   /// Coordinates of the geometry, it's a list of dynamic values.
  @HiveField(1)
  late final List<dynamic> coordinates;
}