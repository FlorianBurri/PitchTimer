import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pitch_timer/services/pitch_data_provider.dart';
import 'package:pitch_timer/views/edit/edit_pitch_view.dart';
import 'package:pitch_timer/views/selection/add_pitch_view.dart';

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
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showDialog(context: context, builder: (_) => AddPitchView());
          },
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 250.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Pitch Timer',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                background: Image.asset(
                  "assets/images/bg.jpg",
                  fit: BoxFit.cover,
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
                        padding: const EdgeInsets.all(10.0),
                        child: Card(
                          child: Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) => pitchData.deletePitch(pitches[index]),
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
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
                              title: Text(
                                pitches[index].name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              subtitle: Text("${pitches[index].chapters.length} chapters"),
                            ),
                          ),
                        ),
                      ),
                      childCount: pitches.length,
                    ),
            ),
          ],
        ));
  }
}
