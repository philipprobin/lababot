import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String _chatApiUrl = 'https://api.openai.com/v1/chat/completions';
  final String _whisperApiUrl = 'https://api.openai.com/v1/audio/transcriptions';

  Future<String> sendMessage(String message,
      {required String sourceLanguage, required String targetLanguage}) async {
    final response = await http.post(
      Uri.parse(_chatApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content":
            "You are a language tutor. The user speaks $sourceLanguage and wants to learn $targetLanguage. After messages where the user tries to use the target language try to correct the user's input, if wrong or repeat his response if correct. Integrate it smoothly in the conversation. respond in $targetLanguage. Ask a follow up question regarding the topic to keep the conversation going. Use very simple language. IN CASE: the user seems interested in learning new words or forms, encourage the user to form sentences with them."
          },
          {"role": "user", "content": message}
        ],
        "temperature": 0.7,
        "max_tokens": 256,
        "top_p": 1.0,
        "frequency_penalty": 0.0,
        "presence_penalty": 0.0,
      }),
    );

    if (response.statusCode == 200) {
      try {
        // Decode the response as UTF-8
        final utf8Response = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utf8Response);
        return data["choices"][0]["message"]["content"];
      } catch (e) {
        throw Exception("Error decoding response: $e");
      }
    } else {
      throw Exception('Failed to fetch response: ${response.body}');
    }
  }

  Future<String> transcribeAudio(String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(_whisperApiUrl),
    );

    // Add headers
    request.headers.addAll({
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'multipart/form-data',
    });

    // Add file
    request.files.add(
      await http.MultipartFile.fromPath('file', filePath),
    );

    // Add model and response format
    request.fields['model'] = 'whisper-1';
    request.fields['response_format'] = 'text';

    // Send request
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return responseBody.trim(); // Whisper API returns plain text
    } else {
      throw Exception(
          'Failed to transcribe audio: ${response.statusCode} - ${await response.stream.bytesToString()}');
    }
  }
}
