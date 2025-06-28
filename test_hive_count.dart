#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';
import 'lib/models/quote.dart';

void main() async {
  print('🔍 MotiAI Hive Database Count Test');
  print('===================================\n');

  // Get the Hive database path for macOS
  final homeDir = Platform.environment['HOME'] ?? '';
  final hivePath = path.join(homeDir, 'Library', 'Containers', 'com.example.motiaiApp', 'Data', 'Documents');
  
  print('Hive Database Path: $hivePath');
  
  if (!Directory(hivePath).existsSync()) {
    print('❌ Hive database directory not found!');
    print('💡 Make sure the app has been run at least once.');
    return;
  }

  try {
    // Initialize Hive and register adapters
    Hive.init(hivePath);
    Hive.registerAdapter(QuoteAdapter());
    
    // Open boxes
    final quotesBox = await Hive.openBox('quotes');
    final imagesBox = await Hive.openBox('cached_images');
    final audioBox = await Hive.openBox('cached_audio');
    final favoritesBox = await Hive.openBox('favorites');
    final settingsBox = await Hive.openBox('settings');

    print('\n📊 HIVE DATABASE COUNTS');
    print('======================');
    print('📝 Quotes Box: ${quotesBox.length} entries');
    print('🖼️  Images Box: ${imagesBox.length} entries');
    print('🎵 Audio Box: ${audioBox.length} entries');
    print('❤️  Favorites Box: ${favoritesBox.length} entries');
    print('⚙️  Settings Box: ${settingsBox.length} entries');
    
    // Analyze quotes
    print('\n📝 QUOTES ANALYSIS');
    print('==================');
    int aiQuotes = 0;
    int localQuotes = 0;
    Map<String, int> quotesByTradition = {};
    
    for (var key in quotesBox.keys) {
      final quoteData = quotesBox.get(key);
      if (quoteData is Quote) {
        final quoteId = quoteData.id;
        final tradition = quoteData.tradition;
        
        if (quoteId.startsWith('ai_')) {
          aiQuotes++;
        } else {
          localQuotes++;
        }
        
        quotesByTradition[tradition] = (quotesByTradition[tradition] ?? 0) + 1;
      }
    }
    
    print('   • AI Generated: $aiQuotes');
    print('   • Local Quotes: $localQuotes');
    print('   • Total Quotes: ${aiQuotes + localQuotes}');
    
    print('\n   📊 Quotes by Tradition:');
    quotesByTradition.forEach((tradition, count) {
      print('      - $tradition: $count');
    });
    
    // Analyze images
    print('\n🖼️  IMAGES ANALYSIS');
    print('==================');
    int traditionImages = 0;
    int quoteImages = 0;
    Map<String, int> imagesByTradition = {};
    
    for (var key in imagesBox.keys) {
      final keyStr = key.toString();
      if (keyStr.contains('_image_')) {
        traditionImages++;
        // Extract tradition from key like "buddhist_inspiration_image_1"
        final parts = keyStr.split('_image_');
        if (parts.isNotEmpty) {
          final tradition = parts[0].replaceAll('_', ' ').toUpperCase();
          imagesByTradition[tradition] = (imagesByTradition[tradition] ?? 0) + 1;
        }
      } else {
        quoteImages++;
      }
    }
    
    print('   • Tradition Images: $traditionImages');
    print('   • Quote-Specific Images: $quoteImages');
    print('   • Total Images: ${traditionImages + quoteImages}');
    
    print('\n   📊 Images by Tradition:');
    imagesByTradition.forEach((tradition, count) {
      print('      - $tradition: $count');
    });
    
    // Analyze audio
    print('\n🎵 AUDIO ANALYSIS');
    print('==================');
    int aiAudio = 0;
    int fallbackAudio = 0;
    Map<String, int> audioByTradition = {};
    
    for (var key in audioBox.keys) {
      final keyStr = key.toString();
      if (keyStr.startsWith('ai_audio_')) {
        aiAudio++;
        // Extract tradition from key like "ai_audio_sufi_inspiration_1"
        final parts = keyStr.split('ai_audio_');
        if (parts.length > 1) {
          final tradition = parts[1].replaceAll('_', ' ').toUpperCase();
          audioByTradition[tradition] = (audioByTradition[tradition] ?? 0) + 1;
        }
      } else {
        fallbackAudio++;
      }
    }
    
    print('   • AI Generated Audio: $aiAudio');
    print('   • Fallback Audio: $fallbackAudio');
    print('   • Total Audio: ${aiAudio + fallbackAudio}');
    
    print('\n   📊 Audio by Tradition:');
    audioByTradition.forEach((tradition, count) {
      print('      - $tradition: $count');
    });
    
    // Summary
    print('\n📈 SUMMARY');
    print('==========');
    final totalDataPoints = quotesBox.length + imagesBox.length + audioBox.length;
    print('   • Total Data Points: $totalDataPoints');
    print('   • Database Size: ${await _getDirectorySize(hivePath)}');
    
    // Close boxes
    await quotesBox.close();
    await imagesBox.close();
    await audioBox.close();
    await favoritesBox.close();
    await settingsBox.close();
    
  } catch (e) {
    print('❌ Error accessing Hive database: $e');
  }
}

Future<String> _getDirectorySize(String dirPath) async {
  try {
    final dir = Directory(dirPath);
    int totalSize = 0;
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    
    if (totalSize < 1024) {
      return '${totalSize} B';
    } else if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  } catch (e) {
    return 'Unknown';
  }
} 