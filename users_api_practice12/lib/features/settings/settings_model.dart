import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(
    this._prefs, {
    required this.dark,
    this.city,
    this.avatarPath,
  });

  final SharedPreferencesAsync _prefs;

  bool dark;
  String? city;
  String? avatarPath;

  // The screen never waits for the disk: notify first, write second.
  Future<void> setDark(bool v) async {
    dark = v;
    notifyListeners();
    await _prefs.setBool('darkMode', v);
  }

  Future<void> setCity(String? c) async {
    city = c;
    notifyListeners();
    if (c == null) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', c);
    }
  }

  Future<void> setAvatarPath(String? p) async {
    avatarPath = p;
    notifyListeners();
    if (p == null) {
      await _prefs.remove('avatarPath');
    } else {
      await _prefs.setString('avatarPath', p);
    }
  }
}
