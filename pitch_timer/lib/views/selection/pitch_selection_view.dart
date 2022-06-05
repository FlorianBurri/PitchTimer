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
      appBar: AppBar(
        title: const Text(
          'Pitch Timer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(context: context, builder: (_) => AddPitchView());
        },
      ),
      body: Center(
        child: ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: pitches.length,
          itemBuilder: (context, index) => Card(
            child: Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) =>
                        pitchData.deletePitch(pitches[index]),
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
      ),
    );
  }
}
