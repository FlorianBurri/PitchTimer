import 'package:flutter/material.dart';
import 'package:pitch_timer/models/pitch_data.dart';
import 'package:pitch_timer/services/pitch_data_provider.dart';
import 'package:provider/provider.dart';

class AddPitchView extends StatelessWidget {
  final _controller = TextEditingController();

  AddPitchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(25),
        shrinkWrap: true,
        children: [
          Text(
            "Add Pitch",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, child) {
                return ElevatedButton(
                  onPressed: _controller.text.isEmpty
                      ? null
                      : () {
                          context
                              .read<PitchDataProvider>()
                              .addPitch(PitchData.empty(_controller.text));
                          Navigator.of(context).pop();
                        },
                  child: const Text("Add Pitch"),
                );
              }),
        ],
      ),
    );
  }
}
