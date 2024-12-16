import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import '../../utils/tts_map.dart';

class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text, String targetLanguage) async {
    final langCode = ttsMap[targetLanguage];
    debugPrint("used lang code $langCode and $targetLanguage");
    if (langCode == null) {
      debugPrint("Language code for $targetLanguage not found.");
      return;
    }

    try {
      await _flutterTts.setLanguage(langCode);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("Error in TextToSpeechService: $e");
    }
  }
}
