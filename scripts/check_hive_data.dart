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
  final allQuotes = await HiveQuoteService.instance.getAllQuotes();
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
  
  // Check audio files in both possible boxes
  int audioFiles = 0;
  try {
    var audioBox = await Hive.openBox('audio');
    print('Audio box ("audio") keys: \\${audioBox.keys.toList()}');
    print('Audio box ("audio") count: \\${audioBox.length}');
    audioFiles = audioBox.length;
    print('\n🎵 Audio Files (audio):');
    print('  Stored: \\${audioFiles}');
    if (audioFiles > 0) {
      print('\n📋 Audio Files List (audio):');
      for (final key in audioBox.keys) {
        print('  - \\${key}');
      }
    }
  } catch (e) {
    print('\n🎵 Audio Files (audio):');
    print('  Stored: 0 (audio box not found)');
  }

  // Now check cached_audio box
  try {
    var cachedAudioBox = await Hive.openBox('cached_audio');
    print('Audio box ("cached_audio") keys: \\${cachedAudioBox.keys.toList()}');
    print('Audio box ("cached_audio") count: \\${cachedAudioBox.length}');
    audioFiles += cachedAudioBox.length;
    print('\n🎵 Audio Files (cached_audio):');
    print('  Stored: \\${cachedAudioBox.length}');
    if (cachedAudioBox.length > 0) {
      print('\n📋 Audio Files List (cached_audio):');
      for (final key in cachedAudioBox.keys) {
        print('  - \\${key}');
      }
    }
  } catch (e) {
    print('\n🎵 Audio Files (cached_audio):');
    print('  Stored: 0 (cached_audio box not found)');
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