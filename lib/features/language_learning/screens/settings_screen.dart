import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/language_provider.dart';
import '../../../utils/shared_prefs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> languages = [
    'English',
    'Deutsch',
    'Español',
    'Français',
    'Italiano',
    'Português',
    'Polski',
    'Tiếng Việt',
    'Chinese',
    'Japanese',
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select your native language:'),
            DropdownButton<String>(
              isExpanded: true,
              value: languageProvider.sourceLanguage, // Access from provider
              items: languages
                  .map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(lang),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  languageProvider.setSourceLanguage(value); // Update via provider
                }
              },
            ),
            const SizedBox(height: 20),
            const Text('Select the language you want to learn:'),
            DropdownButton<String>(
              isExpanded: true,
              value: languageProvider.targetLanguage, // Access from provider
              items: languages
                  .map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(lang),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  languageProvider.setTargetLanguage(value); // Update via provider
                }
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Save preferences to persistent storage
                  await SharedPrefs.setSourceLanguage(languageProvider.sourceLanguage);
                  await SharedPrefs.setTargetLanguage(languageProvider.targetLanguage);
                  Navigator.pop(context); // Navigate back
                },
                child: Text('Save', style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
