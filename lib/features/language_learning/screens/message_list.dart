import 'package:flutter/material.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/services/openai_service.dart';
import '../../../core/services/text_to_speech_service.dart';
import '../../../core/widgets/chat_bubble.dart';
import '../../../core/widgets/loading_indicator.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isLoading;
  final ScrollController scrollController;
  final TextToSpeechService ttsService;
  final OpenAIService openAIService; // Add OpenAIService here

  const MessageList({
    super.key,
    required this.messages,
    required this.isLoading,
    required this.scrollController,
    required this.ttsService,
    required this.openAIService, // Add OpenAIService here
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (isLoading && index == messages.length) {
          return const LoadingBubble();
        }
        final message = messages[index];
        return ChatBubble(
          message: message,
          ttsService: ttsService,

          openAIService: openAIService, // Pass OpenAIService here
        );
      },
    );
  }
}
