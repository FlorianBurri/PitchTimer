import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../models/pitch_data.dart';

class EditPitchNameView extends StatefulWidget {
  final PitchData pitch;
  final void Function(String) onValueChanged;

  const EditPitchNameView({required this.pitch, required this.onValueChanged, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditPitchNameViewState();
}

class _EditPitchNameViewState extends State<EditPitchNameView> {
  final _formKey = GlobalKey<FormBuilderState>();

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
                    "Pitch Name",
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  FormBuilderTextField(
                    name: 'name',
                    initialValue: widget.pitch.name,
                    decoration: InputDecoration(
                      labelStyle:
                          Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.black54),
                      labelText: 'Pitch name',
                      border: const OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          widget.onValueChanged(_formKey.currentState?.value['name'] as String);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Save')),
                ],
              ),
            )));
  }
}
