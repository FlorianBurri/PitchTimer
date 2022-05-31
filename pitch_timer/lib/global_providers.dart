import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pitch_timer/services/pitch_data_provider.dart';

final pitchDataProvider = ChangeNotifierProvider<PitchDataProvider>((ref) {
  return PitchDataProvider();
});
