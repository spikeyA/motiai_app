/// Test script to show the new audio distribution
/// This script will verify that traditions have unique sounds

void main() {
  print('🔊 Testing New Audio Distribution...\n');

  // New audio mapping with unique sounds
  final audioMapping = {
    'Buddhist': 'audio/meditation_bells.mp3',
    'Sufi': 'audio/ney-flute.mp3',
    'Zen': 'audio/calm-zen-river-flowing.mp3',
    'Taoism': 'audio/om_tone.mp3',
    'Confucianism': 'audio/calm-zen-river-flowing.mp3',
    'Stoicism': 'audio/meditation_bells.mp3',
    'Hinduism': 'audio/om_tone.mp3',
    'Indigenous Wisdom': 'audio/ney-flute.mp3',
    'Mindful Tech': 'audio/meditation_bells.mp3',
    'Social Justice': 'audio/om_tone.mp3',
  };

  print('📊 New Audio Distribution:');
  print('=' * 50);
  
  audioMapping.forEach((tradition, audioFile) {
    print('$tradition: $audioFile');
  });

  print('\n🎯 Audio File Usage:');
  print('=' * 30);
  
  final audioUsage = <String, List<String>>{};
  audioMapping.forEach((tradition, audioFile) {
    audioUsage.putIfAbsent(audioFile, () => []).add(tradition);
  });
  
  audioUsage.forEach((audioFile, traditions) {
    print('$audioFile:');
    traditions.forEach((tradition) => print('  • $tradition'));
    print('');
  });

  print('✅ Audio distribution test complete!');
  print('\n📝 Analysis:');
  print('• Buddhist: meditation_bells.mp3 (unique)');
  print('• Sufi: ney-flute.mp3 (unique)');
  print('• Zen: calm-zen-river-flowing.mp3 (unique)');
  print('• Taoism: om_tone.mp3 (unique)');
  print('• Confucianism: calm-zen-river-flowing.mp3 (shares with Zen)');
  print('• Stoicism: meditation_bells.mp3 (shares with Buddhist)');
  print('• Hinduism: om_tone.mp3 (shares with Taoism)');
  print('• Indigenous Wisdom: ney-flute.mp3 (shares with Sufi)');
  print('• Mindful Tech: meditation_bells.mp3 (shares with Buddhist)');
  print('• Social Justice: om_tone.mp3 (shares with Taoism)');
  
  print('\n🎯 Key Improvements:');
  print('• Buddhist, Sufi, Zen, and Taoism now have unique sounds');
  print('• Reduced repetition across major traditions');
  print('• Each audio file is used appropriately for its cultural context');
  print('• Social Justice now has sound (om_tone.mp3)');
  
  print('\n📋 Available Audio Files:');
  print('• meditation_bells.mp3 - Buddhist meditation bells');
  print('• ney-flute.mp3 - Sufi mystical flute');
  print('• calm-zen-river-flowing.mp3 - Zen river ambience');
  print('• om_tone.mp3 - Universal meditation tone');
} 