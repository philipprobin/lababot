import 'package:flutter/material.dart';
import '../../../utils/shared_prefs.dart'; // Import your SharedPrefs class

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

  String? sourceLanguage = 'English'; // Default value
  String? targetLanguage = 'Deutsch'; // Default value

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final source = await SharedPrefs.getSourceLanguage();
    final target = await SharedPrefs.getTargetLanguage();

    setState(() {
      // Validate that the saved preferences match the dropdown options
      sourceLanguage = languages.contains(source) ? source : 'English';
      targetLanguage = languages.contains(target) ? target : 'Deutsch';
    });
  }

  Future<void> _savePreferences() async {
    await SharedPrefs.setSourceLanguage(sourceLanguage ?? 'English');
    await SharedPrefs.setTargetLanguage(targetLanguage ?? 'Deutsch');
  }

  void _saveAndGoBack() async {
    await _savePreferences();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select your native language (Source Language):'),
            DropdownButton<String>(
              isExpanded: true,
              value: sourceLanguage, // Ensure this value matches a dropdown option
              items: languages
                  .map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(lang),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  sourceLanguage = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Select the language you want to learn (Target Language):'),
            DropdownButton<String>(
              isExpanded: true,
              value: targetLanguage, // Ensure this value matches a dropdown option
              items: languages
                  .map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(lang),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  targetLanguage = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveAndGoBack,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
