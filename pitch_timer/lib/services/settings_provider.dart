import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsProvider extends ChangeNotifier {
  static const _openedKey = "opened";
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox('settings');
  }

  bool hasBeenOpened() {
    return _box.get(_openedKey) ?? false;
  }

  void markOpened() {
    _box.put(_openedKey, true);
    notifyListeners();
  }
}
