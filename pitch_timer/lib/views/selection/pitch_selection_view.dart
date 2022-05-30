import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pitch_timer/services/pitch_data_provider.dart';
import 'package:pitch_timer/views/edit/edit_pitch_view.dart';
import 'package:pitch_timer/views/selection/add_pitch_view.dart';
import 'package:provider/provider.dart';

class PitchSelectionView extends StatelessWidget {
  const PitchSelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pitchDataProvider = context.watch<PitchDataProvider>();
    final pitches = pitchDataProvider.pitches;
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
                    onPressed: (context) => pitchDataProvider.deletePitch(pitches[index]),
                    icon: Icons.delete,
                    label: 'Delete',
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
