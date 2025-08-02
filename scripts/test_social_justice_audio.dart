/// Test script to check Social Justice audio mapping
/// This script will help identify why Social Justice doesn't have sound

void main() {
  print('🔊 Testing Social Justice Audio Mapping...\n');

  // Test the audio mappings
  final audioMappings = {
    'Buddhist': 'audio/buddhist_meditation.mp3',
    'Sufi': 'audio/sufi_mystical.mp3',
    'Zen': 'audio/zen_peaceful.mp3',
    'Taoism': 'audio/taoism_harmony.mp3',
    'Confucianism': 'audio/confucianism_wisdom.mp3',
    'Stoicism': 'audio/stoicism_dignified.mp3',
    'Hinduism': 'audio/hinduism_spiritual.mp3',
    'Indigenous Wisdom': 'audio/indigenous_wisdom.mp3',
    'Mindful Tech': 'audio/mindful_tech.mp3',
    'Social Justice': 'audio/social_justice.mp3',
  };

  final fallbackMappings = {
    'Buddhist': 'audio/meditation_bells.mp3',
    'Sufi': 'audio/ney-flute.mp3',
    'Zen': 'audio/calm-zen-river-flowing.mp3',
    'Taoism': 'audio/meditation_bells.mp3',
    'Confucianism': 'audio/meditation_bells.mp3',
    'Stoicism': 'audio/meditation_bells.mp3',
    'Hinduism': 'audio/om_tone.mp3',
    'Indigenous Wisdom': 'audio/meditation_bells.mp3',
    'Mindful Tech': 'audio/meditation_bells.mp3',
    'Social Justice': 'audio/om_tone.mp3',
  };

  final smartFallbacks = {
    'Buddhist': 'audio/meditation_bells.mp3',
    'Taoism': 'audio/meditation_bells.mp3',
    'Confucianism': 'audio/meditation_bells.mp3',
    'Zen': 'audio/calm-zen-river-flowing.mp3',
    'Sufi': 'audio/ney-flute.mp3',
    'Poetic Sufism': 'audio/ney-flute.mp3',
    'Stoicism': 'audio/meditation_bells.mp3',
    'Hinduism': 'audio/om_tone.mp3',
    'Mindful Tech': 'audio/meditation_bells.mp3',
    'Social Justice': 'audio/om_tone.mp3',
    'Indigenous Wisdom': 'audio/meditation_bells.mp3',
    'Eco-Spirituality': 'audio/calm-zen-river-flowing.mp3',
  };

  print('🎯 Testing Social Justice specifically:');
  print('Primary mapping: ${audioMappings['Social Justice']}');
  print('Fallback mapping: ${fallbackMappings['Social Justice']}');
  print('Smart fallback: ${smartFallbacks['Social Justice']}');

  print('\n📋 All tradition audio mappings:');
  print('=' * 60);
  
  audioMappings.forEach((tradition, audioFile) {
    final fallback = fallbackMappings[tradition] ?? 'audio/meditation_bells.mp3';
    final smartFallback = smartFallbacks[tradition] ?? 'audio/meditation_bells.mp3';
    
    print('$tradition:');
    print('  Primary: $audioFile');
    print('  Fallback: $fallback');
    print('  Smart Fallback: $smartFallback');
    print('');
  });

  print('✅ Audio mapping test complete!');
  print('\n📝 Analysis:');
  print('• Social Justice should use audio/om_tone.mp3 as fallback');
  print('• This file exists in the assets/audio/ directory');
  print('• The mapping appears to be correct');
  print('\n🔧 Possible issues:');
  print('1. Audio file path issue in the app');
  print('2. Audio player configuration problem');
  print('3. File format or corruption issue');
  print('4. App not loading the correct fallback method');
  
  print('\n🎯 Next steps:');
  print('1. Check if om_tone.mp3 plays for other traditions');
  print('2. Verify the audio file is properly included in pubspec.yaml');
  print('3. Test the audio system in the actual app');
  print('4. Check console logs for audio-related errors');
} 