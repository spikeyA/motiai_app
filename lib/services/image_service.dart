import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepAIGenerator {
  static const _endpoint = 'https://api.deepai.org/api/text2img';
  static const _apiKey = 'dcceba12-5a62-477f-a08c-cb425e2b45b8'; // User's provided key
  static const _fallbackImage = 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80'; // Unsplash Zen garden

  static Future<String?> generateImage(String prompt) async {
    print('[DeepAI] Prompt: $prompt');
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'api-key': _apiKey},
        body: {'text': prompt},
      );
      print('[DeepAI] Status: ${response.statusCode}');
      print('[DeepAI] Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final url = data['output_url'] as String?;
        print('[DeepAI] Output URL: $url');
        return url ?? _fallbackImage;
      }
      print('[DeepAI] Error: Non-200 response');
      return _fallbackImage;
    } catch (e) {
      print('[DeepAI] Exception: $e');
      return _fallbackImage;
    }
  }
}

String buildPrompt(String theme) {
  final base = "$theme background with:";
  const constraints = "Ample negative space for text, soft colors, "
      "no text elements, minimal detail";
  return "$base $constraints, simple composition";
} 