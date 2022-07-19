import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pitch_timer/services/pitch_data_provider.dart';
import 'package:pitch_timer/views/edit/edit_pitch_view.dart';
import 'package:pitch_timer/views/selection/add_pitch_view.dart';

import '../introduction/introduction_screen.dart';

final pitchDataProvider = ChangeNotifierProvider<PitchDataProvider>((ref) {
  return PitchDataProvider();
});

class PitchSelectionView extends ConsumerWidget {
  const PitchSelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pitchData = ref.watch(pitchDataProvider);
    final pitches = pitchData.pitches;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          onPressed: () {
            showDialog(context: context, builder: (_) => AddPitchView());
          },
        ),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 350.0,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 60, 0, 40),
                      child: Image.asset(
                        "assets/images/title.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: pitches.isEmpty
                      ? SliverChildListDelegate([
                          const Padding(
                              padding: EdgeInsets.only(top: 300),
                              child: Center(child: Text('Click the + button to add a new pitch'))),
                        ])
                      : SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                            child: Card(
                              elevation: 4,
                              color: Theme.of(context).colorScheme.secondary,
                              child: Slidable(
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) => pitchData.deletePitch(pitches[index]),
                                      icon: Icons.delete,
                                      label: 'Delete',
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => EditPitchView(pitch: pitches[index]),
                                      ),
                                    );
                                  },
                                  leading: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Image.asset(
                                      "assets/images/pitchIcon.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  title: Text(
                                    pitches[index].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(color: Theme.of(context).colorScheme.onSecondary),
                                  ),
                                  subtitle: Text(
                                      "${pitches[index].chapters.length}${pitches[index].chapters.length == 1 ? " chapter" : " chapters"}",
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          color: Theme.of(context).colorScheme.onSecondary)),
                                ),
                              ),
                            ),
                          ),
                          childCount: pitches.length,
                        ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 25,
              child: GestureDetector(
                onTap: () => showAppIntroductionScreen(context),
                child: SizedBox(
                  width: 60,
                  height: 30,
                  child: Container(
                    //color: Theme.of(context).colorScheme.tertiary,
                    /*decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.tertiary,
                          spreadRadius: 2,
                          blurRadius: 2,
                        ),
                      ],
                    ),*/
                    /*
                    child: Center(
                      child: Icon(
                        Icons.help_outline,
                        color: Theme.of(context).colorScheme.primary.withOpacity(1),
                      ),*/

                    child: Center(
                      child: Text(
                        "HELP",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                            backgroundColor: Theme.of(context).colorScheme.tertiary),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  void showAppIntroductionScreen(BuildContext context) {
    showDialog(context: context, builder: (context) => AppIntroductionScreen());
  }
}
