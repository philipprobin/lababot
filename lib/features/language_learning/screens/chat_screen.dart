import 'package:flutter/material.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/services/openai_service.dart';
import '../../../core/services/text_to_speech_service.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_audio_recorder.dart';
import '../../../utils/shared_prefs.dart';
import 'message_list.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OpenAIService _openAIService = OpenAIService();
  final TextToSpeechService _ttsService = TextToSpeechService();

  bool _isLoading = false;
  String? sourceLanguage = 'Deutsch'; // Default language
  String? targetLanguage = 'Français';

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Lädt die Quell- und Zielsprache aus SharedPreferences
  Future<void> _loadLanguages() async {
    final source = await SharedPrefs.getSourceLanguage();
    final target = await SharedPrefs.getTargetLanguage();
    setState(() {
      sourceLanguage = source ?? 'Deutsch';
      targetLanguage = target ?? 'Français';
    });
  }

  /// Sendet eine Nachricht an den OpenAI-Dienst
  void _sendMessage(String text) async {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        type: MessageType.user,
        language: sourceLanguage ?? 'Deutsch',
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _openAIService.sendMessage(
        text,
        sourceLanguage: sourceLanguage ?? 'Deutsch',
        targetLanguage: targetLanguage ?? 'Français',
      );

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          type: MessageType.ai,
          language: targetLanguage ?? 'Français',
        ));
      });

      await _ttsService.speak(response, targetLanguage ?? 'Français');
    } catch (error) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Error: ${error.toString()}",
          type: MessageType.ai,
          language: targetLanguage ?? 'Français',
        ));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  /// Transkribiert die Audio-Datei
  Future<void> _transcribeAudio(String audioPath) async {
    try {
      setState(() => _isLoading = true);

      final transcription = await _openAIService.transcribeAudio(audioPath);
      if (transcription.isNotEmpty) {
        _sendMessage(transcription);
      }
    } catch (error) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Error during transcription: ${error.toString()}",
          type: MessageType.ai,
          language: targetLanguage ?? 'Français',
        ));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Callback für abgeschlossene Aufnahme
  void _handleRecordingComplete(String filePath) {
    debugPrint("Audio file path: $filePath");
    _transcribeAudio(filePath);
  }

  /// Scrollt die Nachricht auf den unteren Rand
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onSettingsPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(
              messages: _messages,
              isLoading: _isLoading,
              scrollController: _scrollController,
              ttsService: _ttsService,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration:
                        const InputDecoration(hintText: 'Type your message'),
                        onTap: _scrollToBottom,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          _sendMessage(_controller.text);
                          _controller.clear();
                        }
                      },
                    ),
                    CustomAudioRecorder(
                      onRecordingComplete: _handleRecordingComplete,
                    ),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
