import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pitch_timer/models/pitch_chapter.dart';
import 'package:pitch_timer/models/pitch_data.dart';
import 'package:pitch_timer/services/pitch_data_provider.dart';
import 'package:pitch_timer/views/selection/pitch_selection_view.dart';
import 'package:pitch_timer/views/service_initializer/service_initializer.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PitchDataAdapter());
  Hive.registerAdapter(PitchChapterAdapter());
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late PitchDataProvider _pitchDataProvider;

  @override
  void initState() {
    super.initState();
    _pitchDataProvider = PitchDataProvider();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _pitchDataProvider),
        ],
        builder: (context, _) {
          return MaterialApp(
              title: 'Pitch Timer',
              debugShowCheckedModeBanner: false,
              supportedLocales: const [
                Locale('en'),
              ],
              localizationsDelegates: const [
                FormBuilderLocalizations.delegate,
              ],
              theme: FlexThemeData.light(scheme: FlexScheme.jungle),
              darkTheme: FlexThemeData.dark(scheme: FlexScheme.jungle),
              themeMode: ThemeMode.system,
              home: ServiceInitializer(
                initializers: [
                  _pitchDataProvider.init(),
                ],
                child: const PitchSelectionView(),
              ));
        });
  }
}
