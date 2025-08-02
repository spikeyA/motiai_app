import 'dart:io';
import 'package:path/path.dart' as path;

/// Script to help set up unique audio files for each tradition
/// This script will guide you through adding the required audio files
Future<void> main() async {
  print('🎵 Setting up unique audio files for each tradition...\n');

  final audioDir = 'assets/audio';
  final requiredFiles = [
    'buddhist_meditation.mp3',
    'sufi_mystical.mp3', 
    'zen_peaceful.mp3',
    'taoism_harmony.mp3',
    'confucianism_wisdom.mp3',
    'stoicism_dignified.mp3',
    'hinduism_spiritual.mp3',
    'indigenous_wisdom.mp3',
    'mindful_tech.mp3',
    'social_justice.mp3',
  ];

  print('📁 Checking audio directory: $audioDir');
  
  if (!Directory(audioDir).existsSync()) {
    print('❌ Audio directory does not exist. Creating...');
    Directory(audioDir).createSync(recursive: true);
  }

  print('\n📋 Required audio files for each tradition:');
  for (int i = 0; i < requiredFiles.length; i++) {
    final file = requiredFiles[i];
    final filePath = path.join(audioDir, file);
    final exists = File(filePath).existsSync();
    final status = exists ? '✅' : '❌';
    print('  $status $file');
  }

  print('\n🎯 Current audio mapping:');
  final currentMapping = {
    'Buddhist': 'meditation_bells.mp3',
    'Sufi': 'ney-flute.mp3',
    'Zen': 'calm-zen-river-flowing.mp3',
    'Taoism': 'meditation_bells.mp3',
    'Confucianism': 'meditation_bells.mp3',
    'Stoicism': 'meditation_bells.mp3',
    'Hinduism': 'om_tone.mp3',
    'Indigenous Wisdom': 'meditation_bells.mp3',
    'Mindful Tech': 'meditation_bells.mp3',
    'Social Justice': 'om_tone.mp3',
  };

  currentMapping.forEach((tradition, audio) {
    print('  $tradition: $audio');
  });

  print('\n📝 Next steps:');
  print('1. Add the required audio files to $audioDir/');
  print('2. Ensure each file is royalty-free and appropriate for meditation');
  print('3. Keep file sizes under 5MB each');
  print('4. Use MP3 format for compatibility');
  print('5. Test the audio files in the app');
  print('6. Once all files are added, update AudioService to use the new mapping');

  print('\n🔧 To enable the new audio mapping:');
  print('1. Open lib/services/audio_service.dart');
  print('2. Remove the _temporaryAudioMapping section');
  print('3. The app will automatically use the new audio files');

  print('\n📚 Audio file recommendations:');
  print('• Buddhist: Tibetan singing bowls and meditation bells');
  print('• Sufi: Ney flute and mystical Middle Eastern sounds');
  print('• Zen: Japanese koto and flowing water sounds');
  print('• Taoism: Chinese guqin and mountain wind sounds');
  print('• Confucianism: Traditional Chinese instruments');
  print('• Stoicism: Classical Greek/Roman inspired music');
  print('• Hinduism: Indian sitar and tabla meditation music');
  print('• Indigenous Wisdom: Native American flute and nature sounds');
  print('• Mindful Tech: Modern ambient electronic meditation music');
  print('• Social Justice: Uplifting community and unity meditation music');

  print('\n✅ Setup complete! Add the audio files and update the service when ready.');
} 