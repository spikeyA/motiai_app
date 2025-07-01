import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'hive_quote_service.dart';
import 'image_service.dart';
import 'ai_audio_service.dart';

class BackgroundPrefetchService {
  static Future<void> startBackgroundPrefetch() async {
    // Start pre-fetching images in the background (non-blocking)
    if (dotenv.env['STABILITY_API_KEY'] != null) {
      print('[BackgroundPrefetch] Starting background image pre-fetch...');
      StabilityAIGenerator.preFetchImages(
        onImageGenerated: (String quoteId, String imageData) {
          HiveQuoteService.instance.storeGeneratedImage(quoteId, imageData);
          print('[BackgroundPrefetch] Stored pre-fetched image in Hive: $quoteId');
        },
      ).catchError((e) {
        print('[BackgroundPrefetch] Image pre-fetch failed: $e');
      });
    }

    // Start pre-generating ambient sounds in the background (non-blocking)
    if (dotenv.env['ANTHROPIC_API_KEY'] != null) {
      print('[BackgroundPrefetch] Starting background ambient sound pre-generation...');
      AIAudioGenerator.preGenerateAmbientSounds(
        onAudioGenerated: (String audioId, String audioData) {
          HiveQuoteService.instance.storeGeneratedAudio(audioId, audioData);
          print('[BackgroundPrefetch] Stored pre-generated audio in Hive: $audioId');
        },
      ).catchError((e) {
        print('[BackgroundPrefetch] Audio pre-generation failed: $e');
      });
    }
  }
} 