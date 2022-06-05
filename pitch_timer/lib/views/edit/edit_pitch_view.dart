import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pitch_timer/models/pitch_chapter.dart';
import 'package:pitch_timer/models/pitch_data.dart';
import 'package:pitch_timer/views/edit/edit_chapter_view.dart';
import 'package:pitch_timer/views/presentation/presentation_view.dart';
import 'package:pitch_timer/views/selection/pitch_selection_view.dart';
import 'package:sliding_number/sliding_number.dart';

class EditPitchView extends ConsumerWidget {
  final PitchData pitch;

  const EditPitchView({required this.pitch, Key? key}) : super(key: key);

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
                  buildDefaultDragHandles: false,
                  itemBuilder: (context, index) {
                    return Card(
                      key: UniqueKey(),
                      child: Slidable(
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                pitch.chapters.removeAt(index);
                                pitchData.updatePitch(pitch);
                              },
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(pitch.chapters[index].name),
                          subtitle: Text(
                            "${pitch.chapters[index].duration.inSeconds} seconds",
                          ),
                          trailing: ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle)),
                          onTap: () => showDialog(
                              context: context,
                              builder: (_) => EditChapterView(
                                    chapter: pitch.chapters[index],
                                    onValueChanged: (chapter) {
                                      pitch.chapters[index] = chapter;
                                      pitchData.updatePitch(pitch);
                                    },
                                  )),
                        ),
                      ),
                    );
                  },
                  itemCount: pitch.chapters.length,
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final chapter = pitch.chapters.removeAt(oldIndex);
                    pitch.chapters.insert(newIndex, chapter);
                    pitchData.updatePitch(pitch);
                  }),
            ),
            IconButton(
                onPressed: () {
                  var newChapter = PitchChapter(
                      name: "",
                      durationSeconds: const Duration(seconds: 30).inSeconds);
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
                icon: const Icon(
                  Icons.add_circle,
                  size: 40,
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Total time: ",
                  style: Theme.of(context).textTheme.headlineSmall!,
                ),
                Container(
                  height: 30,
                  padding: const EdgeInsets.only(right: 5),
                  child: SlidingNumber(
                    number: pitch.totalDuration.inMinutes,
                    style: Theme.of(context).textTheme.headlineSmall!,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuint,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  "min",
                  style: Theme.of(context).textTheme.headlineSmall!,
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PresentationView(pitch: pitch))),
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
