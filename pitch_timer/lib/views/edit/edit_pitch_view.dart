import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pitch_timer/models/pitch_chapter.dart';
import 'package:pitch_timer/models/pitch_data.dart';
import 'package:pitch_timer/views/edit/edit_chapter_view.dart';
import 'package:pitch_timer/views/presentation/presentation_view.dart';
import 'package:pitch_timer/views/selection/pitch_selection_view.dart';

class EditPitchView extends ConsumerWidget {
  final PitchData pitch;

  const EditPitchView({required this.pitch, Key? key}) : super(key: key);

  String durationAsString(Duration duration) {
    return "${duration.inSeconds ~/ 60}:${"${duration.inSeconds % 60}".padLeft(2, '0')}";
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
                                    },
                                  ));
                        },
                        child: Row(key: Key(index.toString()), children: [
                          const Icon(
                            Icons.add,
                            size: 30,
                          ),
                          const SizedBox(width: 15),
                          Text("add new chapter", style: Theme.of(context).textTheme.bodyLarge)
                        ]),
                      );
                    }
                    return Slidable(
                      key: Key(index.toString()),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            onPressed: (context) {
                              pitch.chapters.removeAt(index);
                              pitchData.updatePitch(pitch);
                            },
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => showDialog(
                            context: context,
                            builder: (_) => EditChapterView(
                                  chapter: pitch.chapters[index],
                                  onValueChanged: (chapter) {
                                    pitch.chapters[index] = chapter;
                                    pitchData.updatePitch(pitch);
                                  },
                                )),
                        child: Card(
                          color: Colors.primaries[index % (Colors.primaries.length)],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: max(
                                  pitch.chapters[index].duration.inSeconds /
                                      max(pitch.shortestChapterDuration.inSeconds, 10) *
                                      30,
                                  30 // minimum Size
                                  ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: const NeverScrollableScrollPhysics(),
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(pitch.chapters[index].name,
                                                style: Theme.of(context).textTheme.headlineSmall),
                                            Text(pitch.chapters[index].notes,
                                                style: Theme.of(context).textTheme.bodyMedium),
                                          ]),
                                    ),
                                  ),
                                  const VerticalDivider(),
                                  Text(durationAsString(pitch.chapters[index].duration),
                                      style: Theme.of(context).textTheme.headlineSmall),
                                ],
                              ),
                            ),
                          ),
                        ),
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
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Total: ",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Colors.black,
                        ),
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
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => PresentationView(pitch: pitch))),
              child: Container(
                height: 70,
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                child: Center(
                  child: Text(
                    "START",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
