import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/models/language_provider.dart';
import 'features/language_learning/screens/chat_screen.dart';
import 'core/theme/custom_swatch.dart';

void main() async {
  // Ensure WidgetsBinding is initialized before loading .env
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider()..loadLanguages(), // Load languages on startup
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Language Tutor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primarySwatch, // Use the custom swatch
        primaryColor: primarySwatch.shade500,
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'EuropaGrotesk', // Use the custom font
        ),
      ),
      home: const ChatScreen(),
    );
  }

}
