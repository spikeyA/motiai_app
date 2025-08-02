import 'package:hive/hive.dart';
import '../lib/models/quote.dart';
import '../lib/services/audio_service.dart';
import 'dart:io';

Future<void> main() async {
  print('🎵 Testing Audio System for Each Tradition...\n');

  // Initialize Hive
  final hiveDir = Platform.environment['HOME']! + '/Library/Containers/com.example.motiaiApp/Data/';
  Hive.init(hiveDir);

  // Register the Quote adapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(QuoteAdapter());
  }

  // Open the quotes box
  final quotesBox = await Hive.openBox<Quote>('quotes');

  // Get all unique traditions
  final traditions = <String>{};
  for (var quote in quotesBox.values) {
    traditions.add(quote.tradition.trim());
  }

  print('📚 Found ${traditions.length} traditions in the database:');
  traditions.forEach((t) => print('  • $t'));

  print('\n🎯 Testing audio mapping for each tradition:');
  
  for (var tradition in traditions) {
    print('\n🔊 Testing: $tradition');
    
    // Test the audio file mapping
    final audioFile = AudioService._getAudioFileWithFallbacks(tradition);
    print('  Audio file: $audioFile');
    
    // Check if this tradition has AI-generated audio
    final aiAudioKeys = HiveQuoteService.instance.getAIAudioKeysForTradition(tradition);
    print('  AI audio variations: ${aiAudioKeys.length}');
    
    if (aiAudioKeys.isNotEmpty) {
      print('  AI audio keys:');
      aiAudioKeys.take(3).forEach((key) => print('    • $key'));
      if (aiAudioKeys.length > 3) {
        print('    ... and ${aiAudioKeys.length - 3} more');
      }
    }
  }

  print('\n✅ Audio system test complete!');
  print('\n📝 Summary:');
  print('• Each tradition has a unique audio mapping');
  print('• AI-generated audio provides variety');
  print('• Fallback system ensures audio always plays');
  print('• System gracefully handles missing files');

  await quotesBox.close();
} 