import 'package:flutter/material.dart';

import '../../utils/shared_prefs.dart';

class LanguageProvider with ChangeNotifier {
  String _sourceLanguage = 'Deutsch';
  String _targetLanguage = 'Français';

  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;

  void setSourceLanguage(String language) {
    _sourceLanguage = language;
    debugPrint("New source language: $language");
    notifyListeners();
  }

  void setTargetLanguage(String language) {
    _targetLanguage = language;
    debugPrint("New target language: $language");
    notifyListeners();
  }

  Future<void> loadLanguages() async {
    // Load languages from SharedPreferences or another persistent source
    // Example:
    final source = await SharedPrefs.getSourceLanguage();
    final target = await SharedPrefs.getTargetLanguage();
    // Set default values if none are found
    _sourceLanguage = source; // Replace with `source ?? 'Deutsch';`
    _targetLanguage = target; // Replace with `target ?? 'Français';`
    notifyListeners();
  }
}
