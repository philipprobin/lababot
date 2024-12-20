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

    // Check if there is a correction and if it’s not empty
    final hasCorrection = message.correction != null && message.correction!.isNotEmpty;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // If this is a user message and there is a correction,
          // show the "i" icon on the left side.
          if (isUser && hasCorrection) ...[
            Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.yellow[600],
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onTap: () {
                  // You could show a dialog or a tooltip with the correction here
                  // For example:
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Correction'),
                        content: Text(message.correction!),
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
                  color: Colors.black,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 5),
          ],

          // Align AI messages to the left and user messages to the right
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
