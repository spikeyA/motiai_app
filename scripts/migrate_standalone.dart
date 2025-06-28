#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  print('🚀 MotiAI Data Migration Tool (Standalone)');
  print('==========================================\n');
  
  if (args.contains('--help') || args.contains('-h')) {
    _showHelp();
    return;
  }
  
  if (args.contains('--status') || args.contains('-s')) {
    await _showStatus();
  } else if (args.contains('--migrate') || args.contains('-m')) {
    await _migrateAllData();
  } else if (args.contains('--images') || args.contains('-i')) {
    await _migrateImages();
  } else if (args.contains('--audio') || args.contains('-a')) {
    await _migrateAudio();
  } else {
    print('❌ No action specified. Use --help for usage information.');
    exit(1);
  }
}

void _showHelp() {
  print('Usage: dart scripts/migrate_standalone.dart [OPTIONS]');
  print('');
  print('Options:');
  print('  --help, -h     Show this help message');
  print('  --status, -s   Show current migration status');
  print('  --migrate, -m  Migrate all local data to Hive');
  print('  --images, -i   Migrate only images to Hive');
  print('  --audio, -a    Migrate only audio files to Hive');
  print('');
  print('Examples:');
  print('  dart scripts/migrate_standalone.dart --status');
  print('  dart scripts/migrate_standalone.dart --migrate');
  print('  dart scripts/migrate_standalone.dart --images');
  print('');
  print('Note: This script prepares data for migration. Run the Flutter app');
  print('to actually perform the migration using the MigrationService.');
}

Future<void> _showStatus() async {
  print('📊 Current Migration Status');
  print('==========================\n');
  
  // Check if assets exist
  final imageFiles = [
    'assets/images/buddhist.jpg',
    'assets/images/sufi.jpg',
    'assets/images/zen.jpg',
    'assets/images/taoism.jpg',
    'assets/images/stoicism.jpg',
    'assets/images/indigenous.jpg',
    'assets/images/tech.jpg',
    'assets/images/eco.jpg',
    'assets/images/poetic_sufi.jpg',
  ];
  
  final audioFiles = [
    'assets/audio/meditation_bells.mp3',
    'assets/audio/ney-flute.mp3',
    'assets/audio/calm-zen-river-flowing.mp3',
    'assets/audio/om_tone.mp3',
  ];
  
  print('📝 Local Assets Status:');
  
  int existingImages = 0;
  int missingImages = 0;
  for (final imagePath in imageFiles) {
    final file = File(imagePath);
    if (await file.exists()) {
      existingImages++;
      print('  ✅ ${imagePath.split('/').last}');
    } else {
      missingImages++;
      print('  ❌ ${imagePath.split('/').last} (missing)');
    }
  }
  
  print('\n🎵 Audio Files Status:');
  int existingAudio = 0;
  int missingAudio = 0;
  for (final audioPath in audioFiles) {
    final file = File(audioPath);
    if (await file.exists()) {
      existingAudio++;
      print('  ✅ ${audioPath.split('/').last}');
    } else {
      missingAudio++;
      print('  ❌ ${audioPath.split('/').last} (missing)');
    }
  }
  
  print('\n📊 Summary:');
  print('  Images: $existingImages existing, $missingImages missing');
  print('  Audio: $existingAudio existing, $missingAudio missing');
  print('  Total: ${existingImages + existingAudio} ready for migration');
  
  if (missingImages > 0 || missingAudio > 0) {
    print('\n⚠️  Some assets are missing. Please ensure all files exist before migration.');
  } else {
    print('\n✅ All assets are ready for migration!');
  }
}

Future<void> _migrateAllData() async {
  print('🚀 Starting Full Migration Preparation...\n');
  
  await _migrateImages();
  await _migrateAudio();
  
  print('\n✅ Migration preparation completed!');
  print('\n📋 Next Steps:');
  print('1. Run the Flutter app: flutter run');
  print('2. Use the MigrationService in the app to perform the actual migration');
  print('3. Or run the migration from within the app using the service');
}

Future<void> _migrateImages() async {
  print('🖼️  Preparing Images for Migration...');
  
  final imageFiles = [
    'assets/images/buddhist.jpg',
    'assets/images/sufi.jpg',
    'assets/images/zen.jpg',
    'assets/images/taoism.jpg',
    'assets/images/stoicism.jpg',
    'assets/images/indigenous.jpg',
    'assets/images/tech.jpg',
    'assets/images/eco.jpg',
    'assets/images/poetic_sufi.jpg',
  ];
  
  int readyCount = 0;
  int missingCount = 0;
  
  for (final imagePath in imageFiles) {
    final file = File(imagePath);
    if (await file.exists()) {
      final tradition = _getTraditionFromImagePath(imagePath);
      if (tradition != null) {
        print('  ✅ ${imagePath.split('/').last} -> $tradition');
        readyCount++;
      } else {
        print('  ⚠️  ${imagePath.split('/').last} (unknown tradition)');
        missingCount++;
      }
    } else {
      print('  ❌ ${imagePath.split('/').last} (file missing)');
      missingCount++;
    }
  }
  
  print('\n📊 Image Preparation Summary:');
  print('  ✅ Ready: $readyCount');
  print('  ❌ Issues: $missingCount');
}

Future<void> _migrateAudio() async {
  print('\n🎵 Preparing Audio Files for Migration...');
  
  final audioFiles = [
    'assets/audio/meditation_bells.mp3',
    'assets/audio/ney-flute.mp3',
    'assets/audio/calm-zen-river-flowing.mp3',
    'assets/audio/om_tone.mp3',
  ];
  
  int readyCount = 0;
  int missingCount = 0;
  
  for (final audioPath in audioFiles) {
    final file = File(audioPath);
    if (await file.exists()) {
      final tradition = _getTraditionFromAudioPath(audioPath);
      if (tradition != null) {
        print('  ✅ ${audioPath.split('/').last} -> $tradition');
        readyCount++;
      } else {
        print('  ⚠️  ${audioPath.split('/').last} (unknown tradition)');
        missingCount++;
      }
    } else {
      print('  ❌ ${audioPath.split('/').last} (file missing)');
      missingCount++;
    }
  }
  
  print('\n📊 Audio Preparation Summary:');
  print('  ✅ Ready: $readyCount');
  print('  ❌ Issues: $missingCount');
}

String? _getTraditionFromImagePath(String imagePath) {
  final fileName = imagePath.split('/').last.toLowerCase().replaceAll('.jpg', '').replaceAll('.png', '');
  
  switch (fileName) {
    case 'buddhist':
      return 'Buddhist';
    case 'sufi':
      return 'Sufi';
    case 'zen':
      return 'Zen';
    case 'taoism':
      return 'Taoism';
    case 'stoicism':
      return 'Stoicism';
    case 'indigenous':
      return 'Indigenous Wisdom';
    case 'tech':
      return 'Mindful Tech';
    case 'eco':
      return 'Eco-Spirituality';
    case 'poetic_sufi':
      return 'Poetic Sufism';
    default:
      return null;
  }
}

String? _getTraditionFromAudioPath(String audioPath) {
  final fileName = audioPath.split('/').last.toLowerCase().replaceAll('.mp3', '');
  
  switch (fileName) {
    case 'meditation_bells':
      return 'Buddhist';
    case 'ney-flute':
      return 'Sufi';
    case 'calm-zen-river-flowing':
      return 'Zen';
    case 'om_tone':
      return 'Hinduism';
    default:
      return null;
  }
} 