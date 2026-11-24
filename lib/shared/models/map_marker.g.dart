// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_marker.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MapMarkerAdapter extends TypeAdapter<MapMarker> {
  @override
  final int typeId = 0;

  @override
  MapMarker read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MapMarker(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      geometry: fields[3] as Geometry,
    );
  }

  @override
  void write(BinaryWriter writer, MapMarker obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.geometry);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapMarkerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GeometryAdapter extends TypeAdapter<Geometry> {
  @override
  final int typeId = 1;

  @override
  Geometry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Geometry(
      type: fields[0] as GeometryType,
      coordinates: (fields[1] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Geometry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.coordinates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeometryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GeometryTypeAdapter extends TypeAdapter<GeometryType> {
  @override
  final int typeId = 2;

  @override
  GeometryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GeometryType.point;
      case 1:
        return GeometryType.lineString;
      case 2:
        return GeometryType.polygon;
      default:
        return GeometryType.point;
    }
  }

  @override
  void write(BinaryWriter writer, GeometryType obj) {
    switch (obj) {
      case GeometryType.point:
        writer.writeByte(0);
        break;
      case GeometryType.lineString:
        writer.writeByte(1);
        break;
      case GeometryType.polygon:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeometryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
