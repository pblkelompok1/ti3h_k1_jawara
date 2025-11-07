import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String themeKey = 'isDarkMode';

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeKey, value);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(themeKey) ?? false; // default: light mode }
  }
}
