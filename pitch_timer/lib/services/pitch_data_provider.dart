import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pitch_timer/models/pitch_data.dart';

class PitchDataProvider extends ChangeNotifier {
  late Box _box;
  late List<PitchData> _pitches;

  Future<void> init() async {
    _box = await Hive.openBox('pitch_data');
    _pitches = _box.values.cast<PitchData>().toList();
  }

  List<PitchData> get pitches => _pitches;

  void addPitch(PitchData pitch) {
    _pitches.add(pitch);
    _box.put(pitch.id, pitch);
    notifyListeners();
  }

  void deletePitch(PitchData pitch) {
    _pitches.remove(pitch);
    _box.delete(pitch.id);
    notifyListeners();
  }

  void updatePitch(PitchData pitch) {
    _box.put(pitch.id, pitch);
    notifyListeners();
  }
}
