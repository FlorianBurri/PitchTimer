
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pitch_timer/models/pitch_chapter.dart';

part 'pitch_data.g.dart';

@HiveType(typeId: 2)
class PitchData {
  /// Name of the pitch
  @HiveField(0)
  String name;

  /// List of chapters
  @HiveField(1)
  final List<PitchChapter> chapters;

  /// Identifier
  @HiveField(2)
  final String id;

  PitchData({
    required this.name,
    required this.id,
    required this.chapters,
  });

  factory PitchData.empty(String name) => PitchData(
        name: name,
        id: UniqueKey().toString(),
        chapters: [],
      );

  /// Returns the total duration of the pitch
  Duration get totalDuration => chapters.fold(
        Duration.zero,
        (Duration duration, PitchChapter chapter) => duration + chapter.duration,
      );

  Duration get shortestChapterDuration {
    var shortestDuration = const Duration(hours: 1);
    for (var chapter in chapters) {
      if (chapter.duration < shortestDuration) {
        shortestDuration = chapter.duration;
      }
    }
    return shortestDuration;
  }
}
