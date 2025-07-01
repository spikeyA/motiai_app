#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:hive_flutter/hive_flutter.dart';
import '../lib/models/quote.dart';
import 'package:hive/hive.dart';
import 'package:motiai_app/models/quote.dart';

Future<void> main() async {
  // Set Hive directory to the current directory or your app's data directory
  Hive.init(Directory.current.path + '/hive_data');

  // Register adapters
  Hive.registerAdapter(QuoteAdapter());

  // Open boxes
  var quotesBox = await Hive.openBox('quotes');
  var imagesBox = await Hive.openBox('images');
  var audioBox = await Hive.openBox('audio');

  print('--- Hive Data Audit ---');
  print('Quotes: [32m${quotesBox.length}[0m');
  print('Images: [34m${imagesBox.length}[0m');
  print('Audio: [35m${audioBox.length}[0m');

  print('🔍 MotiAI Hive Database Audit');
  print('==============================\n');

  // Open boxes
  final favoritesBox = await Hive.openBox('favorites');
  final settingsBox = await Hive.openBox('settings');

  print('📊 DATABASE OVERVIEW');
  print('===================');
  print('Quotes Box: ${quotesBox.length} items');
  print('Images Box: ${imagesBox.length} items');
  print('Audio Box: ${audioBox.length} items');
  print('Favorites Box: ${favoritesBox.length} items');
  print('Settings Box: ${settingsBox.length} items');
  print('');

  // Audit Quotes
  print('📝 QUOTES AUDIT');
  print('===============');
  final quotes = await quotesBox.values.toList();
  final localQuotes = quotes.where((q) => !q.id.startsWith('ai_')).toList();
  final aiQuotes = quotes.where((q) => q.id.startsWith('ai_')).toList();
  
  print('Total Quotes: ${quotes.length}');
  print('Local Quotes: ${localQuotes.length}');
  print('AI Quotes: ${aiQuotes.length}');
  
  // Group by tradition
  final quotesByTradition = <String, int>{};
  for (final quote in quotes) {
    quotesByTradition[quote.tradition] = (quotesByTradition[quote.tradition] ?? 0) + 1;
  }
  
  print('\nQuotes by Tradition:');
  quotesByTradition.forEach((tradition, count) {
    print('  $tradition: $count');
  });
  print('');

  // Audit Images
  print('🖼️ IMAGES AUDIT');
  print('===============');
  final allImageKeys = imagesBox.keys.toList();
  print('Total Images: ${allImageKeys.length}');
  
  // Group by tradition
  final imagesByTradition = <String, int>{};
  for (final key in allImageKeys) {
    final keyStr = key.toString();
    if (keyStr.contains('_inspiration_image_')) {
      final tradition = keyStr.split('_inspiration_image_')[0].replaceAll('_', ' ').toUpperCase();
      imagesByTradition[tradition] = (imagesByTradition[tradition] ?? 0) + 1;
    } else if (keyStr.startsWith('ai_')) {
      imagesByTradition['AI GENERATED'] = (imagesByTradition['AI GENERATED'] ?? 0) + 1;
    } else {
      imagesByTradition['OTHER'] = (imagesByTradition['OTHER'] ?? 0) + 1;
    }
  }
  
  print('\nImages by Category:');
  imagesByTradition.forEach((category, count) {
    print('  $category: $count');
  });
  print('');

  // Audit Audio
  print('🎵 AUDIO AUDIT');
  print('==============');
  final allAudioKeys = audioBox.keys.toList();
  print('Total Audio Files: ${allAudioKeys.length}');
  
  // Group by tradition
  final audioByTradition = <String, int>{};
  for (final key in allAudioKeys) {
    final keyStr = key.toString();
    if (keyStr.contains('_inspiration_')) {
      final parts = keyStr.split('_inspiration_');
      if (parts.length > 1) {
        final tradition = parts[0].replaceAll('_', ' ').toUpperCase();
        final variation = parts[1].split('_')[0];
        final traditionKey = '$tradition (var $variation)';
        audioByTradition[traditionKey] = (audioByTradition[traditionKey] ?? 0) + 1;
      }
    } else {
      audioByTradition['OTHER'] = (audioByTradition['OTHER'] ?? 0) + 1;
    }
  }
  
  print('\nAudio Files by Tradition:');
  audioByTradition.forEach((tradition, count) {
    print('  $tradition: $count');
  });
  
  // Show sample audio keys
  if (allAudioKeys.isNotEmpty) {
    print('\nSample Audio Keys:');
    for (int i = 0; i < allAudioKeys.length && i < 10; i++) {
      print('  ${allAudioKeys[i]}');
    }
    if (allAudioKeys.length > 10) {
      print('  ... and ${allAudioKeys.length - 10} more');
    }
  }
  print('');

  // Check for specific patterns
  print('🔍 DETAILED ANALYSIS');
  print('===================');
  
  // Check for AI audio patterns
  final aiAudioKeys = allAudioKeys.where((key) => key.toString().contains('ai_audio_')).toList();
  print('AI Audio Files: ${aiAudioKeys.length}');
  
  // Check for tradition-specific audio
  final traditions = [
    'buddhist', 'sufi', 'zen', 'taoism', 'stoicism', 
    'hinduism', 'indigenous', 'mindful_tech', 'social_justice'
  ];
  
  for (final tradition in traditions) {
    final traditionAudio = allAudioKeys.where((key) => 
      key.toString().contains('${tradition}_inspiration_')).toList();
    print('$tradition audio: ${traditionAudio.length}');
  }
  print('');

  // Check data sizes
  print('💾 STORAGE ANALYSIS');
  print('==================');
  
  int totalQuotesSize = 0;
  int totalImagesSize = 0;
  int totalAudioSize = 0;
  
  for (final quote in quotes) {
    totalQuotesSize += quote.text.length + quote.author.length + quote.tradition.length;
  }
  
  for (final key in allImageKeys) {
    final imageData = imagesBox.get(key);
    if (imageData is String) {
      totalImagesSize += imageData.length;
    }
  }
  
  for (final key in allAudioKeys) {
    final audioData = audioBox.get(key);
    if (audioData is String) {
      totalAudioSize += audioData.length;
    }
  }
  
  print('Quotes Data Size: ${(totalQuotesSize / 1024).toStringAsFixed(2)} KB');
  print('Images Data Size: ${(totalImagesSize / 1024 / 1024).toStringAsFixed(2)} MB');
  print('Audio Data Size: ${(totalAudioSize / 1024 / 1024).toStringAsFixed(2)} MB');
  print('Total Data Size: ${((totalQuotesSize + totalImagesSize + totalAudioSize) / 1024 / 1024).toStringAsFixed(2)} MB');
  print('');

  // Close boxes
  await quotesBox.close();
  await imagesBox.close();
  await audioBox.close();
  await favoritesBox.close();
  await settingsBox.close();
  
  print('✅ Audit completed!');
} 