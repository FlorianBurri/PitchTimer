import 'package:hive_flutter/adapters.dart';

part 'pitch_chapter.g.dart';

@HiveType(typeId: 1)
class PitchChapter {
  /// Name of chapter
  @HiveField(0)
  final String name;

  /// Chapter notes
  @HiveField(1)
  final String notes;

  /// Duration of chapter
  @HiveField(2)
  final int durationSeconds;

  PitchChapter({
    required this.name,
    required this.durationSeconds,
    this.notes = "",
  });

  Duration get duration => Duration(seconds: durationSeconds);
}
