import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../secrets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StabilityAIGenerator {
  static const _endpoint = 'https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image';
  
  // Cache for storing generated images
  static final Map<String, String> _imageCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(hours: 24); // Cache for 24 hours
  
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

  /// Get cached image if available, otherwise generate new one
  static Future<String?> generateImage(String prompt) async {
    final cacheKey = _generateCacheKey(prompt);
    
    // Check cache first
    if (_imageCache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null && DateTime.now().difference(timestamp) < _cacheExpiry) {
        print('[StabilityAI] Using cached image for: $prompt');
        return _imageCache[cacheKey];
      } else {
        // Cache expired, remove it
        _imageCache.remove(cacheKey);
        _cacheTimestamps.remove(cacheKey);
      }
    }
    
    // Check local storage cache
    final cachedImage = await _getCachedImageFromStorage(cacheKey);
    if (cachedImage != null) {
      print('[StabilityAI] Using local cached image for: $prompt');
      _imageCache[cacheKey] = cachedImage;
      _cacheTimestamps[cacheKey] = DateTime.now();
      return cachedImage;
    }
    
    // Generate new image
    print('[StabilityAI] Generating new image for prompt: $prompt');
    final newImage = await _generateNewImage(prompt);
    
    if (newImage != null) {
      // Cache the new image
      _imageCache[cacheKey] = newImage;
      _cacheTimestamps[cacheKey] = DateTime.now();
      await _saveImageToStorage(cacheKey, newImage);
      print('[StabilityAI] Image cached for future use');
    }
    
    return newImage;
  }
  
  /// Pre-fetch images for common traditions in the background
  static Future<void> preFetchImages() async {
    print('[StabilityAI] Starting background image pre-fetch...');
    final traditions = ['Buddhist', 'Sufi', 'Zen', 'Taoism', 'Stoicism'];
    
    for (final tradition in traditions) {
      final prompt = buildPrompt(tradition);
      final cacheKey = _generateCacheKey(prompt);
      
      // Only pre-fetch if not already cached
      if (!_imageCache.containsKey(cacheKey)) {
        print('[StabilityAI] Pre-fetching image for $tradition...');
        try {
          final image = await _generateNewImage(prompt);
          if (image != null) {
            _imageCache[cacheKey] = image;
            _cacheTimestamps[cacheKey] = DateTime.now();
            await _saveImageToStorage(cacheKey, image);
            print('[StabilityAI] Pre-fetched image for $tradition');
          }
        } catch (e) {
          print('[StabilityAI] Failed to pre-fetch image for $tradition: $e');
        }
      }
    }
    print('[StabilityAI] Background pre-fetch completed');
  }
  
  /// Clear expired cache entries
  static void _cleanupCache() {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) > _cacheExpiry)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _imageCache.remove(key);
      _cacheTimestamps.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      print('[StabilityAI] Cleaned up ${expiredKeys.length} expired cache entries');
    }
  }
  
  /// Generate a unique cache key for a prompt
  static String _generateCacheKey(String prompt) {
    return prompt.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }
  
  /// Save image to local storage
  static Future<void> _saveImageToStorage(String cacheKey, String imageData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/image_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      
      final file = File('${cacheDir.path}/$cacheKey.png');
      if (imageData.startsWith('data:image/')) {
        final data = imageData.split(',')[1];
        final bytes = base64Decode(data);
        await file.writeAsBytes(bytes);
      }
    } catch (e) {
      print('[StabilityAI] Failed to save image to storage: $e');
    }
  }
  
  /// Get cached image from local storage
  static Future<String?> _getCachedImageFromStorage(String cacheKey) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/image_cache/$cacheKey.png');
      
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final base64Data = base64Encode(bytes);
        return 'data:image/png;base64,$base64Data';
      }
    } catch (e) {
      print('[StabilityAI] Failed to read cached image: $e');
    }
    return null;
  }
  
  /// Generate new image from Stability AI
  static Future<String?> _generateNewImage(String prompt) async {
    // Get API key from environment
    String? apiKey;
    try {
      apiKey = dotenv.env['STABILITY_API_KEY'];
      print('[StabilityAI] API key found: ${apiKey?.substring(0, 8)}...');
    } catch (e) {
      print('[StabilityAI] Error loading API key: $e');
      return _getDefaultImageForPrompt(prompt);
    }
    
    if (apiKey == null || apiKey.isEmpty) {
      print('[StabilityAI] No API key found - using default image');
      return _getDefaultImageForPrompt(prompt);
    }
    
    try {
      print('[StabilityAI] Making request to Stability AI...');
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'text_prompts': [
            {
              'text': prompt,
              'weight': 1.0
            }
          ],
          'cfg_scale': 7,
          'height': 1024,
          'width': 1024,
          'samples': 1,
          'steps': 30,
        }),
      );
      
      print('[StabilityAI] Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final artifacts = data['artifacts'] as List?;
        if (artifacts != null && artifacts.isNotEmpty) {
          final base64Image = artifacts[0]['base64'] as String?;
          if (base64Image != null) {
            // Convert base64 to data URL
            final imageUrl = 'data:image/png;base64,$base64Image';
            print('[StabilityAI] Success! Generated image');
            return imageUrl;
          }
        }
        print('[StabilityAI] No image data in response - using default');
        return _getDefaultImageForPrompt(prompt);
      } else {
        print('[StabilityAI] Error ${response.statusCode}: ${response.body}');
        return _getDefaultImageForPrompt(prompt);
      }
    } catch (e) {
      print('[StabilityAI] Exception: $e');
      return _getDefaultImageForPrompt(prompt);
    }
  }
  
  static String _getDefaultImageForPrompt(String prompt) {
    // Extract tradition from prompt to select appropriate default image
    if (prompt.toLowerCase().contains('buddhist')) {
      print('[StabilityAI] Using Buddhist default image');
      return _defaultImages['Buddhist']!;
    } else if (prompt.toLowerCase().contains('sufi')) {
      print('[StabilityAI] Using Sufi default image');
      return _defaultImages['Sufi']!;
    } else if (prompt.toLowerCase().contains('zen')) {
      print('[StabilityAI] Using Zen default image');
      return _defaultImages['Zen']!;
    }
    // Return a random vibrant fallback if tradition not found
    final randomIndex = DateTime.now().millisecondsSinceEpoch % _vibrantFallbacks.length;
    print('[StabilityAI] Using random vibrant fallback image: $randomIndex');
    return _vibrantFallbacks[randomIndex];
  }
}

String buildPrompt(String theme) {
  // Create a more specific and effective prompt for Stable Diffusion
  final tradition = theme.toLowerCase();
  
  if (tradition.contains('buddhist')) {
    return "peaceful buddhist temple background, golden light, meditation atmosphere, soft colors, minimal detail, space for text, high quality, beautiful";
  } else if (tradition.contains('sufi')) {
    return "mystical sufi desert landscape, warm sunset colors, spiritual atmosphere, soft lighting, minimal detail, space for text, high quality, beautiful";
  } else if (tradition.contains('zen')) {
    return "serene zen garden background, natural elements, peaceful atmosphere, soft green tones, minimal detail, space for text, high quality, beautiful";
  } else if (tradition.contains('taoism')) {
    return "harmonious taoist mountain landscape, flowing water, natural balance, soft earth tones, minimal detail, space for text, high quality, beautiful";
  } else if (tradition.contains('stoicism')) {
    return "strong stoic architecture background, classical elements, dignified atmosphere, neutral tones, minimal detail, space for text, high quality, beautiful";
  } else {
    return "spiritual background, soft colors, peaceful atmosphere, minimal detail, space for text overlay, high quality, beautiful";
  }
} 