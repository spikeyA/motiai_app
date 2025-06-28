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
    'Buddhist': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=90', // Golden Buddhist temple
    'Sufi': 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?auto=format&fit=crop&w=1200&q=90', // Warm desert sunset
    'Zen': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=90', // Peaceful zen garden
    'Taoism': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1200&q=90', // Lush mountain forest
    'Stoicism': 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?auto=format&fit=crop&w=1200&q=90', // Classical architecture
    'Hinduism': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=1200&q=90', // Sacred temple
    'Indigenous': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=90', // Natural landscape
    'Mindful': 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?auto=format&fit=crop&w=1200&q=90', // Modern tech
    'Social': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=90', // Community
  };
  
  // Additional vibrant fallback images
  static const List<String> _vibrantFallbacks = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=90', // Golden temple
    'https://images.unsplash.com/photo-1518709268805-4e9042af2176?auto=format&fit=crop&w=1200&q=90', // Desert sunset
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=90', // Zen garden
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1200&q=90', // Lush forest
    'https://images.unsplash.com/photo-1541961017774-22349e4a1262?auto=format&fit=crop&w=1200&q=90', // Classical architecture
    'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=1200&q=90', // Sacred temple
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
    final traditions = [
      'Buddhist Inspiration', 
      'Sufi Inspiration', 
      'Zen Inspiration', 
      'Taoism Inspiration', 
      'Stoicism Inspiration',
      'Hinduism Inspiration',
      'Indigenous Wisdom Inspiration',
      'Mindful Tech Inspiration',
      'Social Justice Inspiration'
    ];
    
    for (final tradition in traditions) {
      final prompt = buildPrompt(tradition);
      final cacheKey = _generateCacheKey(prompt);
      
      // Only pre-fetch if not already cached
      if (!_imageCache.containsKey(cacheKey)) {
        print('[StabilityAI] Pre-fetching image for $tradition...');
        try {
          final image = await _generateNewImage(prompt);
          if (image != null && !image.contains('unsplash.com')) {
            _imageCache[cacheKey] = image;
            _cacheTimestamps[cacheKey] = DateTime.now();
            await _saveImageToStorage(cacheKey, image);
            print('[StabilityAI] Pre-fetched AI image for $tradition');
          } else {
            print('[StabilityAI] Skipped pre-fetch for $tradition (fallback image)');
          }
        } catch (e) {
          print('[StabilityAI] Failed to pre-fetch image for $tradition: $e');
        }
      } else {
        print('[StabilityAI] Using cached image for $tradition');
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
      print('[StabilityAI] API key found: ${apiKey?.substring(0, apiKey.length > 20 ? 20 : apiKey.length)}...');
      print('[StabilityAI] API key length: ${apiKey?.length}');
    } catch (e) {
      print('[StabilityAI] Error loading API key: $e');
      return _getDefaultImageForPrompt(prompt);
    }
    
    if (apiKey == null || apiKey.isEmpty) {
      print('[StabilityAI] No API key found - using default image');
      return _getDefaultImageForPrompt(prompt);
    }
    
    // Check if API key appears to be incomplete (too short or ends with %)
    if (apiKey.length < 50 || apiKey.endsWith('%')) {
      print('[StabilityAI] API key appears to be incomplete (length: ${apiKey.length}, ends with %: ${apiKey.endsWith('%')}) - using default image');
      print('[StabilityAI] Please update your STABILITY_API_KEY in .env file with a complete API key');
      return _getDefaultImageForPrompt(prompt);
    }
    
    try {
      print('[StabilityAI] Making request to Stability AI...');
      print('[StabilityAI] Endpoint: $_endpoint');
      print('[StabilityAI] Prompt: $prompt');
      
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
          'cfg_scale': 8,
          'height': 1024,
          'width': 1024,
          'samples': 1,
          'steps': 40,
          'style_preset': 'photographic',
        }),
      );
      
      print('[StabilityAI] Status: ${response.statusCode}');
      print('[StabilityAI] Response body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[StabilityAI] Response data keys: ${data.keys.toList()}');
        
        final artifacts = data['artifacts'] as List?;
        if (artifacts != null && artifacts.isNotEmpty) {
          print('[StabilityAI] Found ${artifacts.length} artifacts');
          final base64Image = artifacts[0]['base64'] as String?;
          if (base64Image != null) {
            // Convert base64 to data URL
            final imageUrl = 'data:image/png;base64,$base64Image';
            print('[StabilityAI] Success! Generated image (base64 length: ${base64Image.length})');
            return imageUrl;
          } else {
            print('[StabilityAI] No base64 data in first artifact');
          }
        } else {
          print('[StabilityAI] No artifacts found in response');
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
    } else if (prompt.toLowerCase().contains('taoism')) {
      print('[StabilityAI] Using Taoism default image');
      return _defaultImages['Taoism']!;
    } else if (prompt.toLowerCase().contains('stoicism')) {
      print('[StabilityAI] Using Stoicism default image');
      return _defaultImages['Stoicism']!;
    } else if (prompt.toLowerCase().contains('hinduism')) {
      print('[StabilityAI] Using Hinduism default image');
      return _defaultImages['Hinduism']!;
    } else if (prompt.toLowerCase().contains('indigenous')) {
      print('[StabilityAI] Using Indigenous default image');
      return _defaultImages['Indigenous']!;
    } else if (prompt.toLowerCase().contains('mindful')) {
      print('[StabilityAI] Using Mindful default image');
      return _defaultImages['Mindful']!;
    } else if (prompt.toLowerCase().contains('social')) {
      print('[StabilityAI] Using Social default image');
      return _defaultImages['Social']!;
    } else {
      // Return a random vibrant fallback if tradition not found
      final randomIndex = DateTime.now().millisecondsSinceEpoch % _vibrantFallbacks.length;
      print('[StabilityAI] Using random vibrant fallback image: $randomIndex');
      return _vibrantFallbacks[randomIndex];
    }
  }

  /// Clear cached images for a specific theme
  static Future<void> clearCachedImagesForTheme(String theme) async {
    try {
      final prompt = buildPrompt(theme);
      final cacheKey = _generateCacheKey(prompt);
      
      // Clear from memory cache
      _imageCache.remove(cacheKey);
      
      // Clear from storage
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/image_cache/$cacheKey.png');
      if (await file.exists()) {
        await file.delete();
        print('[StabilityAI] Cleared cached image for theme: $theme');
      }
    } catch (e) {
      print('[StabilityAI] Failed to clear cached image: $e');
    }
  }
}

String buildPrompt(String theme) {
  // Create more aesthetic and specific prompts for beautiful AI-generated backgrounds
  final tradition = theme.toLowerCase();
  
  if (tradition.contains('buddhist')) {
    return "beautiful peaceful buddhist temple at golden hour, soft warm lighting, meditation atmosphere, ethereal glow, minimalist composition, perfect for text overlay, high quality, artistic, serene";
  } else if (tradition.contains('sufi')) {
    return "mystical sufi desert landscape at sunset, warm golden and purple hues, spiritual atmosphere, flowing sand dunes, ethereal lighting, perfect for text overlay, high quality, artistic, dreamy";
  } else if (tradition.contains('zen')) {
    return "serene zen garden with cherry blossoms, soft natural lighting, peaceful atmosphere, flowing water elements, minimalist design, perfect for text overlay, high quality, artistic, tranquil";
  } else if (tradition.contains('taoism')) {
    return "harmonious taoist mountain landscape with mist, flowing waterfalls, natural balance, soft earth and green tones, ethereal atmosphere, perfect for text overlay, high quality, artistic, balanced";
  } else if (tradition.contains('stoicism')) {
    return "majestic stoic architecture with classical columns, dignified atmosphere, warm stone tones, dramatic lighting, strong composition, perfect for text overlay, high quality, artistic, powerful";
  } else if (tradition.contains('hinduism')) {
    return "sacred hindu temple with spiritual energy, vibrant colors, divine atmosphere, intricate details, warm lighting, perfect for text overlay, high quality, artistic, sacred";
  } else if (tradition.contains('indigenous')) {
    return "sacred indigenous landscape with natural elements, earth tones, spiritual connection, organic forms, warm lighting, perfect for text overlay, high quality, artistic, connected";
  } else if (tradition.contains('mindful')) {
    return "modern mindful technology landscape, clean lines, peaceful atmosphere, soft blue and white tones, minimalist design, perfect for text overlay, high quality, artistic, modern";
  } else if (tradition.contains('social')) {
    return "abstract community unity landscape, warm sunset colors, flowing organic shapes, no text or words, peaceful atmosphere, soft gradients, perfect for text overlay, high quality, artistic, inclusive";
  } else {
    return "beautiful spiritual background, soft ethereal lighting, peaceful atmosphere, minimalist composition, perfect for text overlay, high quality, artistic, inspiring";
  }
} 