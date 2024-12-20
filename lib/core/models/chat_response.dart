class ChatResponse {
  final String originalMessage;
  final String answer;
  final String? correction;

  ChatResponse({
    required this.originalMessage,
    required this.answer,
    this.correction,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      originalMessage: json['originalMessage'],
      answer: json['answer'],
      correction: json['correction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalMessage': originalMessage,
      'answer': answer,
      'correction': correction,
    };
  }
}
