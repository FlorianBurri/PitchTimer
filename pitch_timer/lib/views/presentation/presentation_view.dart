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
        elevation: 5,
      ),
      body: StreamBuilder(
          stream: Stream.periodic(
              const Duration(milliseconds: 10), (int _) => DateTime.now().difference(start)),
          initialData: Duration.zero,
          builder: (context, AsyncSnapshot<Duration> snapshot) {
            int? chapterIndex = getChapterIndexForTime(snapshot.data!, pitch.chapters);

            final previousChapter =
                (chapterIndex ?? 0) > 0 ? pitch.chapters[chapterIndex! - 1] : null;
            final currentChapter = pitch.chapters[chapterIndex ?? 0];
            final nextChapter =
                (chapterIndex ?? pitch.chapters.length) < (pitch.chapters.length - 1)
                    ? pitch.chapters[chapterIndex! + 1]
                    : null;
            Duration pastChaptersTime = getPastChaptersTime(pitch.chapters, chapterIndex);
            return Center(
                child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade900,
                        spreadRadius: 0.2,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    shrinkWrap: true,
                    children: [
                      Text("previous", style: Theme.of(context).textTheme.labelMedium),
                      Text(previousChapter?.name ?? '',
                          style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceTint.withOpacity(0.08),
                    child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Expanded(
                        child: ListView(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.all(25),
                          shrinkWrap: true,
                          children: [
                            const SizedBox(height: 20),
                            Text(currentChapter.name,
                                style: Theme.of(context).textTheme.displaySmall),
                            const SizedBox(height: 20),
                            Text(currentChapter.notes,
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: LinearProgressIndicator(
                            minHeight: 20,
                            color: Theme.of(context).colorScheme.secondary,
                            value: (snapshot.data! - pastChaptersTime).inMilliseconds /
                                currentChapter.duration.inMilliseconds,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade900,
                        spreadRadius: 0.2,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    shrinkWrap: true,
                    children: [
                      Text("next", style: Theme.of(context).textTheme.labelMedium),
                      Text(nextChapter?.name ?? '',
                          style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
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

  Duration getPastChaptersTime(List<PitchChapter> chapters, int? currentChapterIndex) {
    Duration timeDelta = Duration.zero;
    for (int index = 0; index != (currentChapterIndex ?? 0); ++index) {
      timeDelta += chapters[index].duration;
    }
    return timeDelta;
  }
}
