import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pitch_timer/models/pitch_chapter.dart';
import 'package:numberpicker/numberpicker.dart';

class EditChapterView extends StatefulWidget {
  final PitchChapter chapter;
  final void Function(PitchChapter) onValueChanged;

  EditChapterView({required this.chapter, required this.onValueChanged, Key? key})
      : super(key: key);

  @override
  State<EditChapterView> createState() => _EditChapterViewState();
}

class _EditChapterViewState extends State<EditChapterView> {
  final _formKey = GlobalKey<FormBuilderState>();
  int? _durationSeconds;
  int? _durationMinutes;

  @override
  Widget build(BuildContext context) {
    _durationSeconds = _durationSeconds ?? widget.chapter.durationSeconds % 60;
    _durationMinutes = _durationMinutes ?? widget.chapter.durationSeconds ~/ 60;
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
                initialValue: widget.chapter.name,
                decoration: InputDecoration(
                  labelStyle:
                      Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.black54),
                  labelText: 'Chapter name',
                  border: const OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),
              FormBuilderTextField(
                name: 'notes',
                initialValue: widget.chapter.notes,
                decoration: InputDecoration(
                  labelStyle:
                      Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.black54),
                  labelText: 'Notes',
                  border: const OutlineInputBorder(),
                ),
                minLines: 5,
                maxLines: 30,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 15),
              Text("Duration: ",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.black54)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  /// Number picker for minutes
                  NumberPicker(
                    value: _durationMinutes!,
                    minValue: 0,
                    maxValue: 60,
                    itemHeight: 40,
                    itemWidth: 60,
                    step: 1,
                    onChanged: (value) {
                      setState(() => _durationMinutes = value);
                    },
                  ),
                  const Text(":", textScaleFactor: 2),

                  /// Number picker for seconds
                  NumberPicker(
                    value: _durationSeconds!,
                    minValue: 0,
                    maxValue: 55,
                    itemHeight: 40,
                    itemWidth: 60,
                    step: 5,
                    onChanged: (value) {
                      setState(() => _durationSeconds = value);
                    },
                  )
                ],
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      widget.onValueChanged(PitchChapter(
                        name: _formKey.currentState?.value['name'] as String,
                        notes: _formKey.currentState?.value['notes'] as String,
                        durationSeconds:
                            (_durationMinutes ?? widget.chapter.durationSeconds ~/ 60) * 60 +
                                (_durationSeconds ?? widget.chapter.durationSeconds % 60),
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
