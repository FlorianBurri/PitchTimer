// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pitch_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PitchDataAdapter extends TypeAdapter<PitchData> {
  @override
  final int typeId = 2;

  @override
  PitchData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PitchData(
      name: fields[0] as String,
      id: fields[2] as String,
      chapters: (fields[1] as List).cast<PitchChapter>(),
    );
  }

  @override
  void write(BinaryWriter writer, PitchData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.chapters)
      ..writeByte(2)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PitchDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
