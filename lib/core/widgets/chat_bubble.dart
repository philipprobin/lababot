import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/text_to_speech_service.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final TextToSpeechService ttsService;

  const ChatBubble({
    required this.message,
    required this.ttsService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Add empty space for alignment when user message is on the right
          if (!isUser) const SizedBox(width: 40),

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
              child: SelectableText(
                message.text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          // Add the speaker button for bot messages
          if (!isUser)
            IconButton(
              icon: const Icon(Icons.volume_up, size: 20, color: Colors.black54),
              onPressed: () {
                ttsService.speak(message.text, message.language);
              },
            ),
        ],
      ),
    );
  }
}
