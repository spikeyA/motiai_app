import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../lib/services/image_service.dart';
import '../lib/services/ai_audio_service.dart';
import '../lib/services/hive_quote_service.dart';
import '../lib/models/quote.dart';
import 'dart:io';

Future<void> main(List<String> args) async {
  print('--- MotiAI Hive Data Refresher ---');
  print('Usage: dart run scripts/refresh_hive_data.dart [images|audio|quotes|all]');

  final refreshImages = args.contains('images') || args.contains('all') || args.isEmpty;
  final refreshAudio = args.contains('audio') || args.contains('all') || args.isEmpty;
  final refreshQuotes = args.contains('quotes') || args.contains('all') || args.isEmpty;

  await dotenv.load();
  await Hive.initFlutter();
  Hive.registerAdapter(QuoteAdapter());
  await HiveQuoteService.instance.init();

  if (refreshImages) {
    print('\n[Refresh] Regenerating AI images for all traditions...');
    await StabilityAIGenerator.preFetchImages(onImageGenerated: (quoteId, imageData) async {
      await HiveQuoteService.instance.storeGeneratedImage(quoteId, imageData);
    });
    print('[Refresh] Images refreshed!');
  }

  if (refreshAudio) {
    print('\n[Refresh] Regenerating AI audio for all traditions...');
    await AIAudioGenerator.preGenerateAmbientSounds(onAudioGenerated: (audioId, audioData) async {
      HiveQuoteService.instance.storeGeneratedAudio(audioId, audioData);
    });
    print('[Refresh] Audio refreshed!');
  }

  if (refreshQuotes) {
    print('\n[Refresh] Regenerating AI quotes for all traditions...');
    // Generate 10 new AI quotes per tradition
    final traditions = [
      'Buddhist',
      'Sufi',
      'Taoism',
      'Confucianism',
      'Stoicism',
      'Hinduism',
      'Indigenous Wisdom',
      'Mindful Tech',
      'Social Justice',
    ];
    int count = 0;
    for (final tradition in traditions) {
      for (int i = 0; i < 10; i++) {
        final quote = await HiveQuoteService.fetchQuoteFromAnthropic();
        if (quote != null) {
          print('[Refresh] Stored AI quote: \\"${quote.text}\\" [${quote.tradition}]');
          count++;
        } else {
          print('[Refresh] Failed to generate AI quote for $tradition');
        }
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
    print('[Refresh] Quotes refreshed! ($count new AI quotes)');
  }

  print('\n--- Refresh Complete ---');
  exit(0);
} 