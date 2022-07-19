import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pitch_timer/models/pitch_chapter.dart';
import 'package:pitch_timer/models/pitch_data.dart';
import 'package:pitch_timer/services/pitch_data_provider.dart';
import 'package:pitch_timer/views/introduction/introduction_screen.dart';
import 'package:pitch_timer/views/selection/pitch_selection_view.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PitchDataAdapter());
  Hive.registerAdapter(PitchChapterAdapter());

  final pitchProvider = PitchDataProvider();
  await pitchProvider.init();

  runApp(ProviderScope(
    overrides: [
      pitchDataProvider.overrideWithValue(pitchProvider),
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pitch Timer',
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('en'),
      ],
      localizationsDelegates: const [
        FormBuilderLocalizations.delegate,
      ],
      theme: FlexThemeData.light(
        scheme: FlexScheme.bigStone,
        primary: const Color.fromARGB(255, 26, 26, 26),
        background: const Color(0xFFEDEEF0),
        tertiary: Colors.amber.shade100,
        secondary: Colors.orange.shade300,
      ),
      home: const PitchSelectionView(),
    );
  }
}
