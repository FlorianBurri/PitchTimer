import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pitch_timer/models/pitch_chapter.dart';
import 'package:pitch_timer/models/pitch_data.dart';

class PresentationView extends StatefulWidget {
  final PitchData pitch;

  const PresentationView({required this.pitch, Key? key}) : super(key: key);

  @override
  State<PresentationView> createState() => _PresentationViewState();
}

class _PresentationViewState extends State<PresentationView> {
  static const double progressIndicatorWidth = 50;

  DateTime start = DateTime.now();
  int chapterIndex = 0;
  bool isPaused = false;
  Duration pauseDuration = Duration.zero;

  void skipPrevious(Duration duration) {
    if (duration.inSeconds < 2 && chapterIndex > 0) {
      chapterIndex = chapterIndex - 1;
    }
    start = DateTime.now();
    pauseDuration = Duration.zero;
  }

  void pause(Duration duration) {
    if (isPaused) {
      /// continue where paused
      start = DateTime.now().subtract(pauseDuration);
    } else {
      pauseDuration = duration;
    }
    isPaused = !isPaused;
  }

  void skipNext() {
    if ((chapterIndex + 1) < widget.pitch.chapters.length) {
      chapterIndex = chapterIndex + 1;
      start = DateTime.now();
    }
    pauseDuration = Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pitch.name),
        elevation: 5,
      ),
      body: StreamBuilder(
          stream: Stream.periodic(
              const Duration(milliseconds: 10), (int _) => DateTime.now().difference(start)),
          initialData: Duration.zero,
          builder: (context, AsyncSnapshot<Duration> snapshot) {
            var chapters = widget.pitch.chapters;
            if (!isPaused &&
                (snapshot.data! > chapters[chapterIndex].duration) &&
                ((chapterIndex + 1) < chapters.length)) {
              chapterIndex = chapterIndex + 1;
              start = DateTime.now();
            }

            final previousChapter = (chapterIndex) > 0 ? chapters[chapterIndex - 1] : null;
            final currentChapter = chapters[chapterIndex];
            final nextChapter =
                (chapterIndex) < (chapters.length - 1) ? chapters[chapterIndex + 1] : null;
            return Center(
                child: Column(
              children: [
                Container(
                  height: 90,
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
                      AutoSizeText(
                        previousChapter?.name ?? '',
                        style: Theme.of(context).textTheme.headlineMedium,
                        maxLines: 1,
                      ),
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
                      Stack(
                        children: [
                          SizedBox(
                            width: progressIndicatorWidth,
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: LinearProgressIndicator(
                                minHeight: 20,
                                color: Theme.of(context).colorScheme.secondary,
                                value: (isPaused
                                        ? pauseDuration.inMilliseconds.toDouble()
                                        : snapshot.data!.inMilliseconds) /
                                    currentChapter.duration.inMilliseconds,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            width: progressIndicatorWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => skipPrevious(snapshot.data!),
                                  child: const RotatedBox(
                                      quarterTurns: 1,
                                      child: Icon(
                                        Icons.skip_previous,
                                        size: progressIndicatorWidth,
                                      )),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => pause(snapshot.data!),
                                    child: Icon(
                                      isPaused ? Icons.play_arrow : Icons.pause,
                                      size: progressIndicatorWidth,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: skipNext,
                                  child: const RotatedBox(
                                      quarterTurns: 1,
                                      child: Icon(
                                        Icons.skip_next,
                                        size: progressIndicatorWidth,
                                      )),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ]),
                  ),
                ),
                Container(
                  height: 90,
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
                      AutoSizeText(
                        nextChapter?.name ?? '',
                        style: Theme.of(context).textTheme.headlineMedium,
                        maxLines: 1,
                      ),
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
