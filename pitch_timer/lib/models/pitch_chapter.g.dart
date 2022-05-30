// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pitch_chapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PitchChapterAdapter extends TypeAdapter<PitchChapter> {
  @override
  final int typeId = 1;

  @override
  PitchChapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PitchChapter(
      name: fields[0] as String,
      durationSeconds: fields[2] as int,
      notes: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PitchChapter obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.notes)
      ..writeByte(2)
      ..write(obj.durationSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PitchChapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
