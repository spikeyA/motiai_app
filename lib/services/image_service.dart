import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secrets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepAIGenerator {
  static const _endpoint = 'https://api.deepai.org/api/text2img';
  static const _apiKey = 'dcceba12-5a62-477f-a08c-cb425e2b45b8'; // User's provided key
  
  // Vibrant, motivational default images for each tradition
  static const Map<String, String> _defaultImages = {
    'Buddhist': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=80', // Golden Buddhist temple
    'Sufi': 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?auto=format&fit=crop&w=1200&q=80', // Warm desert sunset
    'Zen': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80', // Peaceful zen garden
  };
  
  // Additional vibrant fallback images
  static const List<String> _vibrantFallbacks = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=80', // Golden temple
    'https://images.unsplash.com/photo-1518709268805-4e9042af2176?auto=format&fit=crop&w=1200&q=80', // Desert sunset
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80', // Zen garden
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1200&q=80', // Lush forest
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=80', // Mountain sunrise
  ];

  static Future<String?> generateImage(String prompt) async {
    print('[DeepAI] Prompt: $prompt');
    
    // Check if .env is loaded
    if (dotenv.isInitialized) {
      final apiKey = dotenv.env['DEEPAI_API_KEY'];
      try {
        final response = await http.post(
          Uri.parse(_endpoint),
          headers: {'api-key': apiKey ?? ''},
          body: {'text': prompt},
        );
        print('[DeepAI] Status: ${response.statusCode}');
        print('[DeepAI] Body: ${response.body}');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final url = data['output_url'] as String?;
          print('[DeepAI] Output URL: $url');
          return url ?? _getDefaultImageForPrompt(prompt);
        }
        print('[DeepAI] Error: Non-200 response - using vibrant default image');
        return _getDefaultImageForPrompt(prompt);
      } catch (e) {
        print('[DeepAI] Exception: $e - using vibrant default image');
        return _getDefaultImageForPrompt(prompt);
      }
    } else {
      print('[DeepAI] Error: .env not loaded - using vibrant default image');
      return _getDefaultImageForPrompt(prompt);
    }
  }
  
  static String _getDefaultImageForPrompt(String prompt) {
    // Extract tradition from prompt to select appropriate default image
    if (prompt.toLowerCase().contains('buddhist')) {
      print('[DeepAI] Using Buddhist default image');
      return _defaultImages['Buddhist']!;
    } else if (prompt.toLowerCase().contains('sufi')) {
      print('[DeepAI] Using Sufi default image');
      return _defaultImages['Sufi']!;
    } else if (prompt.toLowerCase().contains('zen')) {
      print('[DeepAI] Using Zen default image');
      return _defaultImages['Zen']!;
    }
    // Return a random vibrant fallback if tradition not found
    final randomIndex = DateTime.now().millisecondsSinceEpoch % _vibrantFallbacks.length;
    print('[DeepAI] Using random vibrant fallback image: $randomIndex');
    return _vibrantFallbacks[randomIndex];
  }
}

String buildPrompt(String theme) {
  final base = "$theme background with:";
  const constraints = "Ample negative space for text, soft colors, "
      "no text elements, minimal detail";
  return "$base $constraints, simple composition";
} 