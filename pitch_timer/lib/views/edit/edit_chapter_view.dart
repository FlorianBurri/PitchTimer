import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pitch_timer/models/pitch_chapter.dart';

class EditChapterView extends StatelessWidget {
  final PitchChapter chapter;
  final void Function(PitchChapter) onValueChanged;
  final _formKey = GlobalKey<FormBuilderState>();

  EditChapterView(
      {required this.chapter, required this.onValueChanged, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: FormBuilder(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Edit Chapter",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              FormBuilderTextField(
                name: 'name',
                initialValue: chapter.name,
                decoration: const InputDecoration(
                  labelText: 'Chapter name',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),
              FormBuilderTextField(
                name: 'notes',
                initialValue: chapter.notes,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                minLines: 10,
                maxLines: 30,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),
              FormBuilderSlider(
                name: 'duration',
                initialValue: chapter.durationSeconds.toDouble(),
                max: 300,
                min: 1,
                decoration: const InputDecoration(
                  labelText: 'Duration sec.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      onValueChanged(PitchChapter(
                        name: _formKey.currentState?.value['name'] as String,
                        notes: _formKey.currentState?.value['notes'] as String,
                        durationSeconds:
                            (_formKey.currentState?.value['duration'] as double)
                                .toInt(),
                      ));
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
