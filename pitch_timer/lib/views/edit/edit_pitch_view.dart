import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pitch_timer/models/pitch_chapter.dart';
import 'package:pitch_timer/models/pitch_data.dart';
import 'package:pitch_timer/views/edit/edit_chapter_view.dart';
import 'package:pitch_timer/views/presentation/presentation_view.dart';
import 'package:pitch_timer/views/selection/pitch_selection_view.dart';

class EditPitchView extends ConsumerWidget {
  final PitchData pitch;
  final double shortestChapterSize = 28;
  int scalingFactor = 10;
  double totalDrag = 0;
  int draggedChapterInitDuration = 0;

  EditPitchView({required this.pitch, Key? key}) : super(key: key) {
    updateScalingFactor();
  }

  void updateScalingFactor() {
    scalingFactor = max(pitch.shortestChapterDuration.inSeconds, 10);
  }

  String durationAsString(Duration duration) {
    return "${duration.inSeconds ~/ 60}:${"${duration.inSeconds % 60}".padLeft(2, '0')}";
  }

  int roundSeconds(int seconds) {
    /* Round seconds to a appropiate value, depending on the current scale */
    int dragTimeStepSize = 0;
    if (scalingFactor < 30) {
      dragTimeStepSize = 5;
    } else if (scalingFactor < 90) {
      dragTimeStepSize = 10;
    } else if (scalingFactor < 240) {
      dragTimeStepSize = 30;
    } else if (scalingFactor < 480) {
      dragTimeStepSize = 60;
    }
    return max((seconds / dragTimeStepSize).round() * dragTimeStepSize, dragTimeStepSize);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pitchData = ref.watch(pitchDataProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text(pitch.name),
        ),
        body: Column(
          children: [
            Expanded(
              child: ReorderableListView.builder(
                  padding: const EdgeInsets.all(8),
                  buildDefaultDragHandles: true,
                  itemBuilder: (context, index) {
                    if (index == pitch.chapters.length) {
                      return GestureDetector(
                        key: Key(index.toString()),
                        onLongPress: () {}, // disable reordering
                        onTap: () {
                          var newChapter = PitchChapter(
                              name: "", durationSeconds: const Duration(seconds: 30).inSeconds);
                          showDialog(
                              context: context,
                              builder: (_) => EditChapterView(
                                    chapter: newChapter,
                                    onValueChanged: (chapter) {
                                      newChapter = chapter;
                                      pitch.chapters.add(newChapter);
                                      pitchData.updatePitch(pitch);
                                      updateScalingFactor();
                                    },
                                  ));
                        },
                        child: Row(key: Key(index.toString()), children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Icon(
                            Icons.add,
                            size: 30,
                          ),
                          const SizedBox(width: 8),
                          Text("Add new chapter", style: Theme.of(context).textTheme.bodyLarge)
                        ]),
                      );
                    }
                    final bgColor = Colors.primaries[index % (Colors.primaries.length)].shade100;
                    return Slidable(
                      key: Key(index.toString()),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            backgroundColor: bgColor,
                            onPressed: (context) {
                              pitch.chapters.removeAt(index);
                              pitchData.updatePitch(pitch);
                            },
                            icon: Icons.delete,
                            label: 'Delete',
                            borderRadius: BorderRadius.circular(8),
                            foregroundColor: Colors.black,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () => showDialog(
                                context: context,
                                builder: (_) => EditChapterView(
                                      chapter: pitch.chapters[index],
                                      onValueChanged: (chapter) {
                                        pitch.chapters[index] = chapter;
                                        pitchData.updatePitch(pitch);
                                        updateScalingFactor();
                                      },
                                    )),
                            child: Card(
                              color: bgColor,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: max(
                                            pitch.chapters[index].duration.inSeconds /
                                                max(scalingFactor, 10),
                                            1) *
                                        shortestChapterSize,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      /// Pitch title and duration
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: AutoSizeText(
                                              pitch.chapters[index].name,
                                              style: Theme.of(context).textTheme.headlineSmall,
                                              maxLines: 1,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          AutoSizeText(
                                              durationAsString(pitch.chapters[index].duration),
                                              style: Theme.of(context).textTheme.headlineSmall),
                                        ],
                                      ),
                                      // Notes
                                      if (pitch.chapters[index].notes.isNotEmpty)
                                        Expanded(
                                          child: AutoSizeText(
                                            pitch.chapters[index].notes,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                            overflow: TextOverflow.fade,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: -6,
                              right: 70,
                              child: GestureDetector(
                                onLongPress: () {}, // disable reordering
                                onVerticalDragStart: (details) {
                                  draggedChapterInitDuration =
                                      pitch.chapters[index].durationSeconds;
                                  totalDrag = 0;
                                },
                                onVerticalDragUpdate: (details) {
                                  totalDrag += details.delta.dy;
                                  var updatedChapter = PitchChapter(
                                      name: pitch.chapters[index].name,
                                      notes: pitch.chapters[index].notes,
                                      durationSeconds: roundSeconds(draggedChapterInitDuration +
                                          totalDrag * scalingFactor ~/ shortestChapterSize));
                                  pitch.chapters[index] = updatedChapter;
                                  pitchData.updatePitch(pitch);
                                },
                                onVerticalDragEnd: (details) {
                                  var updatedChapter = PitchChapter(
                                      name: pitch.chapters[index].name,
                                      notes: pitch.chapters[index].notes,
                                      durationSeconds:
                                          roundSeconds(pitch.chapters[index].durationSeconds));
                                  pitch.chapters[index] = updatedChapter;
                                  pitchData.updatePitch(pitch);
                                  updateScalingFactor();
                                },
                                child: Container(
                                  /// Extending drag gesture area
                                  height: 40,
                                  width: 60,
                                  color: Colors.transparent,
                                  child: Center(
                                    child: SizedBox(
                                        height: 32,
                                        width: 40,
                                        child: Card(
                                          elevation: 5,
                                          color: bgColor,
                                          child: Column(
                                            children: const [
                                              Icon(Icons.unfold_more),
                                            ],
                                          ),
                                        )),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    );
                  },
                  itemCount: pitch.chapters.length + 1,
                  onReorder: (oldIndex, newIndex) {
                    /// ignore moving below the add new widget
                    if (newIndex == (pitch.chapters.length + 1)) {
                      newIndex -= 1;
                    }
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final chapter = pitch.chapters.removeAt(oldIndex);
                    pitch.chapters.insert(newIndex, chapter);
                    pitchData.updatePitch(pitch);
                  }),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade900,
                    spreadRadius: 0.7,
                    blurRadius: 7,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.timer_outlined),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    durationAsString(pitch.totalDuration),
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => PresentationView(pitch: pitch)));
              },
              child: Container(
                height: 80,
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        size: 45,
                        color: Colors.white,
                      ),
                      Text(
                        "Start",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
