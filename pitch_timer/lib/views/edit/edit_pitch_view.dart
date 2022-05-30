import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pitch_timer/models/pitch_chapter.dart';
import 'package:pitch_timer/models/pitch_data.dart';
import 'package:pitch_timer/services/pitch_data_provider.dart';
import 'package:pitch_timer/views/edit/edit_chapter_view.dart';
import 'package:pitch_timer/views/presentation/presentation_view.dart';
import 'package:provider/provider.dart';
import 'package:sliding_number/sliding_number.dart';

class EditPitchView extends StatefulWidget {
  final PitchData pitch;

  const EditPitchView({required this.pitch, Key? key}) : super(key: key);

  @override
  State<EditPitchView> createState() => _EditPitchViewState();
}

class _EditPitchViewState extends State<EditPitchView> {
  @override
  Widget build(BuildContext context) {
    final pitchDataProvider = context.watch<PitchDataProvider>();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.pitch.name),
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
                                widget.pitch.chapters.removeAt(index);
                                pitchDataProvider.updatePitch(widget.pitch);
                              },
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(widget.pitch.chapters[index].name),
                          subtitle: Text(
                            "${widget.pitch.chapters[index].duration.inSeconds} seconds",
                          ),
                          trailing: ReorderableDragStartListener(
                              index: index, child: const Icon(Icons.drag_handle)),
                          onTap: () => showDialog(
                              context: context,
                              builder: (_) => EditChapterView(
                                    chapter: widget.pitch.chapters[index],
                                    onValueChanged: (chapter) {
                                      widget.pitch.chapters[index] = chapter;
                                      pitchDataProvider.updatePitch(widget.pitch);
                                    },
                                  )),
                        ),
                      ),
                    );
                  },
                  itemCount: widget.pitch.chapters.length,
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final chapter = widget.pitch.chapters.removeAt(oldIndex);
                    widget.pitch.chapters.insert(newIndex, chapter);
                    pitchDataProvider.updatePitch(widget.pitch);
                  }),
            ),
            IconButton(
                onPressed: () {
                  widget.pitch.chapters.add(
                    PitchChapter(
                        name: "Chapter ${Random().nextInt(100)}",
                        durationSeconds: const Duration(seconds: 142).inSeconds),
                  );
                  pitchDataProvider.updatePitch(widget.pitch);
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
                    number: widget.pitch.totalDuration.inMinutes,
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
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => PresentationView(pitch: widget.pitch))),
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
