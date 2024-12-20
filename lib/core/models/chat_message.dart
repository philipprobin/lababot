enum MessageType { user, ai }

class ChatMessage {
  final String text;
  final MessageType type;
  final String language; // Stores the language of the message
  final String? correction; // Optional correction for grammar/syntax issues

  ChatMessage({
    required this.text,
    required this.type,
    required this.language,
    this.correction, // Initialize as optional
  });
}
