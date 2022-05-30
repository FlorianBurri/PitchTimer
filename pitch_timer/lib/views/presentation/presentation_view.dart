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
          stream: Stream.periodic(const Duration(milliseconds: 200),
              (int _) => DateTime.now().difference(start)),
          initialData: Duration.zero,
          builder: (context, AsyncSnapshot<Duration> snapshot) {
            int? chapterIndex =
                getChapterIndexForTime(snapshot.data!, pitch.chapters);

            final previousChapter = (chapterIndex ?? 0) > 0
                ? pitch.chapters[chapterIndex! - 1]
                : null;
            final currentChapter = pitch.chapters[chapterIndex ?? 0];
            final nextChapter = (chapterIndex ?? pitch.chapters.length) <
                    (pitch.chapters.length - 1)
                ? pitch.chapters[chapterIndex! + 1]
                : null;
            Duration pastChaptersTime =
                getPastChaptersTime(pitch.chapters, chapterIndex);
            return Center(
                child: Column(
              children: [
                ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 20),
                    Text("previous",
                        style: Theme.of(context).textTheme.labelLarge),
                    Text(previousChapter?.name ?? '',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 20),
                  ],
                ),
                const Divider(),
                Container(
                  ///color: Theme.of(context).colorScheme.secondary,
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    shrinkWrap: true,
                    children: [
                      const SizedBox(height: 20),
                      Text(currentChapter.name,
                          style: Theme.of(context).textTheme.headline1),
                      const SizedBox(height: 20),
                      Text(currentChapter.notes,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    LinearProgressIndicator(
                      minHeight: 40,
                      color: Theme.of(context).colorScheme.secondary,
                      value:
                          (snapshot.data! - pastChaptersTime).inMilliseconds /
                              currentChapter.duration.inMilliseconds,
                    ),
                    Text(
                      "${(pastChaptersTime + currentChapter.duration - snapshot.data!).inSeconds} sec.",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.red),
                    ),
                  ],
                ),
                const Divider(),
                ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 20),
                    Text("next", style: Theme.of(context).textTheme.labelLarge),
                    Text(nextChapter?.name ?? '',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 20),
                  ],
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

  Duration getPastChaptersTime(
      List<PitchChapter> chapters, int? currentChapterIndex) {
    Duration timeDelta = Duration.zero;
    for (int index = 0; index != (currentChapterIndex ?? 0); ++index) {
      timeDelta += chapters[index].duration;
    }
    return timeDelta;
  }
}
