import 'api_client.dart';

class AiChatMessage {
  final String role; // "user" or "model"
  final String text;

  const AiChatMessage({required this.role, required this.text});

  Map<String, dynamic> toJson() => {
        'role': role,
        'parts': [
          {'text': text}
        ],
      };
}

class AiChatService {
  static Future<String> sendMessage(
    String message,
    List<AiChatMessage> history,
  ) async {
    final response = await ApiClient.post('/ai/chat', {
      'message': message,
      'history': history.map((m) => m.toJson()).toList(),
    });
    return (response['data']['reply'] as String);
  }
}
