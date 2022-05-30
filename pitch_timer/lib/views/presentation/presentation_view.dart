import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pitch_timer/models/pitch_chapter.dart';
import 'package:pitch_timer/models/pitch_data.dart';

class PresentationView extends StatelessWidget {
  final PitchData pitch;

  const PresentationView({required this.pitch, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final start = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text(pitch.name),
      ),
      body: StreamBuilder(
          stream: Stream.periodic(
              const Duration(milliseconds: 200), (int _) => DateTime.now().difference(start)),
          initialData: Duration.zero,
          builder: (context, AsyncSnapshot<Duration> snapshot) {
            final chapter =
                pitch.chapters[getChapterIndexForTime(snapshot.data!, pitch.chapters) ?? 0];
            return Center(
                child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    LinearProgressIndicator(
                      minHeight: 20,
                      color: Theme.of(context).colorScheme.secondary,
                      value: snapshot.data!.inMilliseconds / pitch.totalDuration.inMilliseconds,
                    ),
                    Text(
                      "${snapshot.data!.inSeconds} sec.",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.red),
                    ),
                  ],
                ),
                ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 20),
                    Text(chapter.name, style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 20),
                    Text(chapter.notes, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(
                      height: 40,
                    ),
                    Text("Chapter duration: ${chapter.duration.inSeconds.toString()} seconds",
                        style: Theme.of(context).textTheme.labelLarge),
                  ],
                )
              ],
            ));
          }),
    );
  }

  int? getChapterIndexForTime(Duration elapsed, List<PitchChapter> chapters) {
    for (int index = 0; index != chapters.length; ++index) {
      final currentChapter = chapters[index];
      if (elapsed < currentChapter.duration) {
        return index;
      }
      elapsed -= currentChapter.duration;
    }
    return null;
  }
}
