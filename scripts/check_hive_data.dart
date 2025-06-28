#!/usr/bin/env dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../lib/models/quote.dart';
import '../lib/services/hive_quote_service.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 MotiAI Hive Database Inspector');
  print('================================\n');
  
  try {
    // Initialize Hive
    await Hive.initFlutter();
    Hive.registerAdapter(QuoteAdapter());
    
    // Initialize HiveQuoteService
    await HiveQuoteService.initialize();
    
    await _inspectHiveData();
    
  } catch (e) {
    print('❌ Error inspecting Hive data: $e');
    exit(1);
  }
}

Future<void> _inspectHiveData() async {
  print('📊 Hive Database Statistics');
  print('==========================\n');
  
  // Check quotes
  final allQuotes = HiveQuoteService.instance.getAllQuotes();
  final localQuotes = allQuotes.where((q) => !q.id.startsWith('ai_')).toList();
  final aiQuotes = allQuotes.where((q) => q.id.startsWith('ai_')).toList();
  
  print('📝 Quotes:');
  print('  Total: ${allQuotes.length}');
  print('  Local: ${localQuotes.length}');
  print('  AI: ${aiQuotes.length}');
  
  // Check images
  final imageCount = HiveQuoteService.instance.getStoredImageCount();
  final quoteIdsWithImages = HiveQuoteService.instance.getQuoteIdsWithImages();
  
  int localImages = 0;
  int aiImages = 0;
  
  for (final quoteId in quoteIdsWithImages) {
    if (quoteId.startsWith('local_')) {
      localImages++;
    } else if (quoteId.startsWith('ai_')) {
      aiImages++;
    }
  }
  
  print('\n🖼️  Images:');
  print('  Total: $imageCount');
  print('  Local: $localImages');
  print('  AI: $aiImages');
  
  // Check audio files
  int audioFiles = 0;
  try {
    final audioBox = await Hive.openBox('audio_files');
    audioFiles = audioBox.length;
    
    print('\n🎵 Audio Files:');
    print('  Stored: $audioFiles');
    
    if (audioFiles > 0) {
      print('\n📋 Audio Files List:');
      for (final key in audioBox.keys) {
        print('  - $key');
      }
    }
  } catch (e) {
    print('\n🎵 Audio Files:');
    print('  Stored: 0 (audio box not found)');
  }
  
  // Show recent AI quotes
  if (aiQuotes.isNotEmpty) {
    print('\n🤖 Recent AI Quotes:');
    final recentQuotes = aiQuotes.take(5).toList();
    for (final quote in recentQuotes) {
      print('  • "${quote.text}" - ${quote.author} [${quote.tradition} / ${quote.category}] (${quote.id})');
    }
  }
  
  // Show local quotes
  if (localQuotes.isNotEmpty) {
    print('\n📚 Local Quotes:');
    final sampleQuotes = localQuotes.take(3).toList();
    for (final quote in sampleQuotes) {
      print('  • "${quote.text}" - ${quote.author} [${quote.tradition} / ${quote.category}] (${quote.id})');
    }
  }
  
  // Summary
  print('\n📈 Summary:');
  print('  Total Data Points: ${allQuotes.length + imageCount + audioFiles}');
  print('  Quotes: ${allQuotes.length}');
  print('  Images: $imageCount');
  print('  Audio: $audioFiles');
  
  print('\n✅ Hive inspection completed!');
} 