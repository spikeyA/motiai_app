#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';

void main() async {
  print('🔍 MotiAI Hive Database Audit');
  print('==============================\n');

  // Get the Hive database path for macOS
  final homeDir = Platform.environment['HOME'] ?? '';
  final hivePath = path.join(homeDir, 'Library', 'Containers', 'com.example.motiaiApp', 'Data', 'Documents');
  
  print('Hive Database Path: $hivePath');
  
  if (!Directory(hivePath).existsSync()) {
    print('❌ Hive database directory not found!');
    return;
  }

  // List all Hive box files
  final hiveDir = Directory(hivePath);
  final boxFiles = hiveDir.listSync().where((f) => f.path.endsWith('.hive')).toList();
  
  print('\n📊 Hive Boxes Found:');
  print('===================');
  for (final file in boxFiles) {
    final fileName = path.basename(file.path);
    final fileSize = file.statSync().size;
    print('${fileName}: ${(fileSize / 1024).toStringAsFixed(2)} KB');
  }
  print('');

  // Try to read the cached_audio.hive file directly
  final audioBoxPath = path.join(hivePath, 'cached_audio.hive');
  if (File(audioBoxPath).existsSync()) {
    print('🎵 AUDIO BOX ANALYSIS');
    print('====================');
    
    final audioFile = File(audioBoxPath);
    final audioSize = audioFile.statSync().size;
    print('Audio Box Size: ${(audioSize / 1024 / 1024).toStringAsFixed(2)} MB');
    
    // Try to read the file content (this is a simplified approach)
    try {
      final bytes = await audioFile.readAsBytes();
      print('Audio Box Raw Size: ${bytes.length} bytes');
      
      // Look for patterns in the binary data
      final content = String.fromCharCodes(bytes);
      final aiAudioPatterns = RegExp(r'ai_audio_[a-z_]+_\d+').allMatches(content);
      final traditionPatterns = RegExp(r'[a-z]+_inspiration_\d+').allMatches(content);
      
      print('AI Audio Patterns Found: ${aiAudioPatterns.length}');
      print('Tradition Patterns Found: ${traditionPatterns.length}');
      
      if (aiAudioPatterns.isNotEmpty) {
        print('\nSample AI Audio Keys:');
        for (int i = 0; i < aiAudioPatterns.length && i < 10; i++) {
          print('  ${aiAudioPatterns.elementAt(i).group(0)}');
        }
      }
      
      if (traditionPatterns.isNotEmpty) {
        print('\nSample Tradition Keys:');
        for (int i = 0; i < traditionPatterns.length && i < 10; i++) {
          print('  ${traditionPatterns.elementAt(i).group(0)}');
        }
      }
    } catch (e) {
      print('Could not read audio box content: $e');
    }
  } else {
    print('❌ Audio box file not found!');
  }
  print('');

  // Check images box
  final imagesBoxPath = path.join(hivePath, 'cached_images.hive');
  if (File(imagesBoxPath).existsSync()) {
    print('🖼️ IMAGES BOX ANALYSIS');
    print('=====================');
    
    final imagesFile = File(imagesBoxPath);
    final imagesSize = imagesFile.statSync().size;
    print('Images Box Size: ${(imagesSize / 1024 / 1024).toStringAsFixed(2)} MB');
    
    try {
      final bytes = await imagesFile.readAsBytes();
      final content = String.fromCharCodes(bytes);
      
      final imagePatterns = RegExp(r'[a-z]+_inspiration_image_\d+').allMatches(content);
      final aiImagePatterns = RegExp(r'ai_\d+').allMatches(content);
      
      print('Tradition Image Patterns: ${imagePatterns.length}');
      print('AI Image Patterns: ${aiImagePatterns.length}');
      
      if (imagePatterns.isNotEmpty) {
        print('\nSample Image Keys:');
        for (int i = 0; i < imagePatterns.length && i < 10; i++) {
          print('  ${imagePatterns.elementAt(i).group(0)}');
        }
      }
    } catch (e) {
      print('Could not read images box content: $e');
    }
  } else {
    print('❌ Images box file not found!');
  }
  print('');

  // Check quotes box
  final quotesBoxPath = path.join(hivePath, 'quotes.hive');
  if (File(quotesBoxPath).existsSync()) {
    print('📝 QUOTES BOX ANALYSIS');
    print('=====================');
    
    final quotesFile = File(quotesBoxPath);
    final quotesSize = quotesFile.statSync().size;
    print('Quotes Box Size: ${(quotesSize / 1024).toStringAsFixed(2)} KB');
    
    try {
      final bytes = await quotesFile.readAsBytes();
      final content = String.fromCharCodes(bytes);
      
      final aiQuotePatterns = RegExp(r'ai_\d+').allMatches(content);
      final localQuotePatterns = RegExp(r'[a-z_]+_[a-z_]+').allMatches(content);
      
      print('AI Quote Patterns: ${aiQuotePatterns.length}');
      print('Local Quote Patterns: ${localQuotePatterns.length}');
      
      if (aiQuotePatterns.isNotEmpty) {
        print('\nSample AI Quote Keys:');
        for (int i = 0; i < aiQuotePatterns.length && i < 10; i++) {
          print('  ${aiQuotePatterns.elementAt(i).group(0)}');
        }
      }
    } catch (e) {
      print('Could not read quotes box content: $e');
    }
  } else {
    print('❌ Quotes box file not found!');
  }
  print('');

  print('✅ Simple audit completed!');
  print('\n💡 Note: This is a simplified analysis. For detailed data,');
  print('   use the debug dialog in the app or run the full audit script.');
} 