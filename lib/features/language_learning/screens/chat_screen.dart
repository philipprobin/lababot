import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/language_provider.dart';
import '../../../core/services/openai_service.dart';
import '../../../core/services/text_to_speech_service.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_audio_recorder.dart';
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

  bool _isTextNotEmpty = false; // Tracks whether the text field is not empty

  @override
  void initState() {
    super.initState();
    // Add listener to track text changes
    _controller.addListener(() {
      setState(() {
        _isTextNotEmpty = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    final languageProvider = context.read<LanguageProvider>();
    final sourceLanguage = languageProvider.sourceLanguage;
    final targetLanguage = languageProvider.targetLanguage;

    // Add the user's message first
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        type: MessageType.user,
        language: sourceLanguage,
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    // Get the AI response
    final response = await _openAIService.sendMessage(
      text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    setState(() {
      // If the response contains a correction, apply it to the last user message
      if (response.correction != null && response.correction!.isNotEmpty) {
        final userMessageIndex =
            _messages.length - 1; // Last added message is the user message
        final userMessage = _messages[userMessageIndex];

        // Create a new ChatMessage with the correction
        final updatedUserMessage = ChatMessage(
          text: userMessage.text,
          type: userMessage.type,
          language: userMessage.language,
          correction: response.correction,
        );

        // Replace the last user message with the updated one
        _messages[userMessageIndex] = updatedUserMessage;
      }

      // Now add the AI's answer as a new message without a correction
      _messages.add(ChatMessage(
        text: response.answer,
        type: MessageType.ai,
        language: targetLanguage,
        correction: null,
      ));
    });

    // Use text-to-speech to read out the AI's answer
    await _ttsService.speak(response.answer, targetLanguage);

    setState(() => _isLoading = false);
    _scrollToBottom();
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
      final targetLanguage = context.read<LanguageProvider>().targetLanguage;
      setState(() {
        _messages.add(ChatMessage(
          text: "Error during transcription: ${error.toString()}",
          type: MessageType.ai,
          language: targetLanguage,
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
    final languageProvider = context.watch<LanguageProvider>();

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
              openAIService: _openAIService,
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
                        decoration: InputDecoration(
                          hintText: 'Type your message',
                          hintStyle: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.6)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30), // Rounded corners
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30), // Rounded corners
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        cursorColor: Theme.of(context).primaryColor, // Cursor color
                        style: TextStyle(color: Theme.of(context).primaryColor), // Text color
                        onTap: _scrollToBottom,
                      ),
                    ),

                    _isTextNotEmpty
                        ? IconButton(
                      color: Theme.of(context).primaryColor,
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              if (_controller.text.isNotEmpty) {
                                _sendMessage(_controller.text);
                                _controller.clear();
                              }
                            },
                          )
                        : CustomAudioRecorder(
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
