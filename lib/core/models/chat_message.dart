enum MessageType { user, ai }

class ChatMessage {
  final String text;
  final MessageType type;
  final String language; // Added to store the language

  ChatMessage({required this.text, required this.type, required this.language});
}
