import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/chat_response.dart';

class OpenAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String _chatApiUrl = 'https://api.openai.com/v1/chat/completions';
  final String _whisperApiUrl = 'https://api.openai.com/v1/audio/transcriptions';

  Future<ChatResponse> sendMessage(String message,
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
            "content": "You are a language tutor. The user speaks $sourceLanguage and wants to learn $targetLanguage. Respond in $targetLanguage. Ask a follow-up question regarding the topic to keep the conversation going. Use very simple language. ONLY when the user seems interested in learning new words or forms, encourage the user to form sentences with them."
          },
          {"role": "user", "content": message}
        ],
        "temperature": 0,
        "max_tokens": 256,
        "top_p": 1.0,
        "frequency_penalty": 0.0,
        "presence_penalty": 0.0,
        "response_format": {
          "type": "json_schema",
          "json_schema": {
            "name": "language_tutor_response",
            "strict": true,
            "schema": {
              "type": "object",
              "properties": {
                "answer": {
                  "type": "string",
                  "description": "The answer to the user's question. Try to keep the conversation going by asking a follow-up question. Try to ask questions like you want to get to know the other person and be interested. Use very simple language for a language learner to understand."
                },
                "correction": {
                  "type": "string",
                  "description": "I case there is a mistake when the user tries to use $targetLanguage in the user's input, provide a correction here. Only return the input corrected in the $targetLanguage. If no correction is needed, return null.",
                  "nullable": true
                }
              },
              "additionalProperties": false,
              "required": [
                "answer",
                "correction"
              ]
            }
          }
        },
      }),
    );

    if (response.statusCode == 200) {
      try {
        final utf8Response = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utf8Response);
        debugPrint("Response: $data");
        debugPrint("");
        debugPrint("Answer: ${data["choices"][0]["message"]["content"]}");

        // Get the content as a string
        final contentString = data["choices"][0]["message"]["content"];

        // Decode the content string into a Map
        final contentJson = jsonDecode(contentString);

        return ChatResponse.fromJson({
          "originalMessage": message,
          "answer": contentJson["answer"],
          "correction": contentJson["correction"],
        });
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
