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
      latitude: fields[2] as double,
      longitude: fields[3] as double,
      description: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MapMarker obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.description);
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
