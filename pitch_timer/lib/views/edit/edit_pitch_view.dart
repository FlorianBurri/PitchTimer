import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pitch_timer/global_providers.dart';
import 'package:pitch_timer/models/pitch_chapter.dart';
import 'package:pitch_timer/models/pitch_data.dart';
import 'package:pitch_timer/services/pitch_data_provider.dart';
import 'package:pitch_timer/views/edit/edit_chapter_view.dart';
import 'package:pitch_timer/views/presentation/presentation_view.dart';

import 'edit_pitch_name_view.dart';

class EditPitchView extends StatefulWidget {
  final PitchData pitch;
  final double shortestChapterSize = 29;

  const EditPitchView({required this.pitch, Key? key}) : super(key: key);

  @override
  State<EditPitchView> createState() => _EditPitchViewState();
}

class _EditPitchViewState extends State<EditPitchView> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  late int scalingFactor;
  static const animationDuration = Duration(milliseconds: 600);
  double totalDrag = 0;
  int draggedChapterInitDuration = 0;

  @override
  void initState() {
    scalingFactor = max(widget.pitch.shortestChapterDuration.inSeconds, 10);
    super.initState();
    controller = AnimationController(duration: const Duration(), vsync: this);
    animation = Tween<double>(begin: 0, end: scalingFactor.toDouble()).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void updateScalingFactor() {
    double previousScalingfactor = scalingFactor.toDouble();
    setState(() {
      scalingFactor = max(widget.pitch.shortestChapterDuration.inSeconds, 10);
    });
    controller.reset();
    controller.duration = animationDuration;
    Animation<double> curve = CurvedAnimation(parent: controller, curve: Curves.decelerate);
    animation =
        Tween<double>(begin: previousScalingfactor, end: scalingFactor.toDouble()).animate(curve)
          ..addListener(() {
            setState(() {});
          });
    controller.forward();
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
    } else {
      dragTimeStepSize = 60;
    }
    return max((seconds / dragTimeStepSize).round() * dragTimeStepSize, dragTimeStepSize);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: ((context, ref, child) {
        final pitchData = ref.watch(pitchDataProvider);
        return Scaffold(
            appBar: AppBar(
              title: GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      builder: (_) => EditPitchNameView(
                            pitch: widget.pitch,
                            onValueChanged: (pitchName) {
                              widget.pitch.name = pitchName;
                              pitchData.updatePitch(widget.pitch);
                              updateScalingFactor();
                            },
                          )),
                  child: Row(
                    children: [
                      Flexible(child: Text(widget.pitch.name)),
                      const SizedBox(width: 20),
                      const Icon(Icons.edit),
                    ],
                  )),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: ReorderableListView.builder(
                        padding: const EdgeInsets.all(8),
                        buildDefaultDragHandles: true,
                        itemBuilder: (context, index) {
                          if (index == widget.pitch.chapters.length) {
                            return addChapterWidget(index, context, pitchData);
                          }
                          return chapterCard(index, pitchData, context);
                        },
                        itemCount: widget.pitch.chapters.length + 1,
                        onReorder: (oldIndex, newIndex) {
                          /// ignore moving below the add new widget
                          if (newIndex == (widget.pitch.chapters.length + 1)) {
                            newIndex -= 1;
                          }
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final chapter = widget.pitch.chapters.removeAt(oldIndex);
                          widget.pitch.chapters.insert(newIndex, chapter);
                          pitchData.updatePitch(widget.pitch);
                        }),
                  ),
                ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.timer_outlined),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        durationAsString(widget.pitch.totalDuration),
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
                    if (widget.pitch.chapters.isNotEmpty) {
                      HapticFeedback.heavyImpact();
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PresentationView(pitch: widget.pitch)));
                    }
                  },
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primary,
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            size: 45,
                            color: widget.pitch.chapters.isNotEmpty
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.outline,
                          ),
                          Text(
                            "Start",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: widget.pitch.chapters.isNotEmpty
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ));
      }),
    );
  }

  GestureDetector addChapterWidget(int index, BuildContext context, PitchDataProvider pitchData) {
    return GestureDetector(
      key: Key(index.toString()),
      onLongPress: () {}, // disable reordering
      onTap: () {
        var newChapter =
            PitchChapter(name: "", durationSeconds: const Duration(minutes: 1).inSeconds);
        showDialog(
            context: context,
            builder: (_) => EditChapterView(
                  chapter: newChapter,
                  onValueChanged: (chapter) {
                    newChapter = chapter;
                    widget.pitch.chapters.add(newChapter);
                    pitchData.updatePitch(widget.pitch);
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

  Widget chapterCard(int index, PitchDataProvider pitchData, BuildContext context) {
    final bgColor = Colors.primaries[(15 - index) % (Colors.primaries.length)].shade100;
    return Slidable(
      key: Key(index.toString()),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.transparent,
            onPressed: (context) {
              widget.pitch.chapters.removeAt(index);
              pitchData.updatePitch(widget.pitch);
            },
            icon: Icons.delete,
            label: 'Delete',
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
                      chapter: widget.pitch.chapters[index],
                      onValueChanged: (chapter) {
                        widget.pitch.chapters[index] = chapter;
                        pitchData.updatePitch(widget.pitch);
                        updateScalingFactor();
                      },
                    )),
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: bgColor,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: max(
                            widget.pitch.chapters[index].duration.inSeconds /
                                max(animation.value, 10),
                            1) *
                        widget.shortestChapterSize,
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
                              widget.pitch.chapters[index].name,
                              style: Theme.of(context).textTheme.headlineSmall,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          AutoSizeText(durationAsString(widget.pitch.chapters[index].duration),
                              style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                      // Notes
                      if (widget.pitch.chapters[index].notes.isNotEmpty)
                        Expanded(
                          child: AutoSizeText(
                            widget.pitch.chapters[index].notes,
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
              bottom: -7,
              right: 70,
              child: GestureDetector(
                onLongPress: () {}, // disable reordering
                onVerticalDragStart: (details) => chapterDragStart(details, index),
                onVerticalDragUpdate: (details) => chapterDragUpdate(details, index, pitchData),
                onVerticalDragEnd: (details) => chapterDragEnd(),
                child: Container(
                  /// Extending drag gesture area
                  height: 40,
                  width: 60,
                  color: Colors.transparent,
                  child: Center(
                    child: SizedBox(
                        height: 30,
                        width: 60,
                        child: Card(
                            elevation: 0, color: bgColor, child: const Icon(Icons.drag_handle))),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void chapterDragStart(details, index) {
    draggedChapterInitDuration = widget.pitch.chapters[index].durationSeconds;
    totalDrag = 0;
  }

  void chapterDragUpdate(details, index, PitchDataProvider pitchData) {
    totalDrag += details.delta.dy;
    var updatedChapter = PitchChapter(
        name: widget.pitch.chapters[index].name,
        notes: widget.pitch.chapters[index].notes,
        durationSeconds: roundSeconds(
            draggedChapterInitDuration + totalDrag * scalingFactor ~/ widget.shortestChapterSize));
    widget.pitch.chapters[index] = updatedChapter;
    pitchData.updatePitch(widget.pitch);
  }

  void chapterDragEnd() {
    updateScalingFactor();
  }
}
