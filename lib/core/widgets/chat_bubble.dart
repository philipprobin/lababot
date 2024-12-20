import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../services/openai_service.dart';
import '../services/text_to_speech_service.dart';
import '../models/language_provider.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final TextToSpeechService ttsService;
  final OpenAIService openAIService;

  const ChatBubble({
    required this.message,
    required this.ttsService,
    required this.openAIService,
    super.key,
  });

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  String? _cachedExplanation;
  bool _isExplaining = false;

  Future<void> _showExplanation(BuildContext context) async {
    if (_cachedExplanation == null) {
      setState(() => _isExplaining = true);
      try {
        final languageProvider = context.read<LanguageProvider>();
        final explanation = await widget.openAIService.explain(
          widget.message.text,
          sourceLanguage: languageProvider.sourceLanguage,
          targetLanguage: languageProvider.targetLanguage,
        );
        setState(() {
          _cachedExplanation = explanation;
          _isExplaining = false;
        });
      } catch (error) {
        setState(() => _isExplaining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching explanation: $error')),
        );
        return;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Explanation'),
          content: MarkdownBody(
            data: _cachedExplanation!,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 16),
              strong: const TextStyle(fontWeight: FontWeight.bold),
              em: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.type == MessageType.user;
    final hasCorrection = widget.message.correction != null &&
        widget.message.correction!.isNotEmpty;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isUser && hasCorrection) ...[
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Correction'),
                      content: Text(widget.message.correction!),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(
                Icons.info,
                color: Colors.yellow,
                size: 24,
              ),
            ),
            const SizedBox(width: 5),
          ],
          if (!isUser) const SizedBox(width: 2),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                  bottomLeft: isUser ? const Radius.circular(10) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    widget.message.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (!isUser)
                    Row(
                      mainAxisSize: MainAxisSize.min, // Limit size to children
                      children: [
                        GestureDetector(
                          onTap: () => _showExplanation(context),
                          child: Container(
                            decoration: const BoxDecoration(),
                            child: _isExplaining
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.grey),
                                  )
                                : Icon(Icons.help,
                                    color: Colors.black54.withOpacity(0.5),
                                    size: 20),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.volume_up,
                            size: 20,
                            color: Colors.black54.withOpacity(0.5),
                          ),
                          onPressed: () {
                            widget.ttsService.speak(
                                widget.message.text, widget.message.language);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
