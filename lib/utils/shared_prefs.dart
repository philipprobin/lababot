import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _sourceLanguageKey = 'sourceLanguage';
  static const String _targetLanguageKey = 'targetLanguage';

  // Save the source language
  static Future<void> setSourceLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sourceLanguageKey, language);
  }

  // Get the source language
  static Future<String> getSourceLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sourceLanguageKey) ?? "Deutsch";
  }

  // Save the target language
  static Future<void> setTargetLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_targetLanguageKey, language);
  }

  // Get the target language
  static Future<String> getTargetLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_targetLanguageKey) ?? "Français";
  }
}
