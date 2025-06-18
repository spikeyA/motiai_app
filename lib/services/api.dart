import 'package:http/http.dart' as http;

Future<String> generateQuote(String mood) async {
  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Authorization': 'Bearer YOUR_OPENAI_KEY',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'user',
          'content': 'Generate a $mood quote. Max 15 words.',
        }
      ],
    }),
  );

  return jsonDecode(response.body)['choices'][0]['message']['content'];
}