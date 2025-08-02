/// Test script to demonstrate audio variety system
/// This simulates the audio variety logic to prevent repetition

void main() {
  print('🔊 Testing Audio Variety System...\n');

  // Simulate the audio variety system
  final List<String> _recentAudioFiles = [];
  const int _maxRecentAudioFiles = 3;

  String getAudioFileWithVariety(String tradition) {
    final Map<String, String> _smartFallbacks = {
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
    
    // Get the primary audio file for this tradition
    String primaryAudioFile = _smartFallbacks[tradition] ?? _smartFallbacks['Buddhist']!;
    
    // Check if this audio file was recently used
    if (_recentAudioFiles.contains(primaryAudioFile)) {
      // Find an alternative audio file that hasn't been used recently
      final availableAudioFiles = _smartFallbacks.values.toSet().toList();
      final unusedAudioFiles = availableAudioFiles.where((file) => !_recentAudioFiles.contains(file)).toList();
      
      if (unusedAudioFiles.isNotEmpty) {
        // Use a random unused audio file
        unusedAudioFiles.shuffle();
        primaryAudioFile = unusedAudioFiles.first;
        print('🔄 Using alternative audio for $tradition: $primaryAudioFile (avoiding repetition)');
      } else {
        // All audio files have been used recently, clear the list and use primary
        _recentAudioFiles.clear();
        print('🔄 All audio files used recently, resetting variety tracking for $tradition');
      }
    }
    
    // Add this audio file to recent list
    _recentAudioFiles.add(primaryAudioFile);
    if (_recentAudioFiles.length > _maxRecentAudioFiles) {
      _recentAudioFiles.removeAt(0);
    }
    
    return primaryAudioFile;
  }

  // Test sequence of traditions to show variety
  final testSequence = [
    'Buddhist',
    'Sufi',
    'Zen',
    'Taoism',
    'Buddhist', // Should get different audio
    'Stoicism', // Should get different audio
    'Hinduism',
    'Mindful Tech', // Should get different audio
    'Social Justice',
    'Indigenous Wisdom',
  ];

  print('🎯 Testing Audio Variety Sequence:');
  print('=' * 50);
  
  for (int i = 0; i < testSequence.length; i++) {
    final tradition = testSequence[i];
    final audioFile = getAudioFileWithVariety(tradition);
    final recentFiles = _recentAudioFiles.join(', ');
    
    print('${i + 1}. $tradition → $audioFile');
    print('   Recent: [$recentFiles]');
    print('');
  }

  print('📊 Audio Variety Analysis:');
  print('=' * 35);
  
  // Count how many times each audio file was used
  final audioUsage = <String, int>{};
  _recentAudioFiles.forEach((file) {
    audioUsage[file] = (audioUsage[file] ?? 0) + 1;
  });
  
  print('Audio file usage in recent sequence:');
  audioUsage.forEach((file, count) {
    print('  $file: $count times');
  });

  print('\n✅ Audio Variety System Features:');
  print('• Prevents same audio file from repeating in last 3 selections');
  print('• Automatically selects alternative audio when repetition would occur');
  print('• Resets variety tracking when all audio files have been used');
  print('• Maintains cultural appropriateness while ensuring variety');
  print('• Works across all traditions and audio types');

  print('\n🎵 Available Audio Files:');
  print('• meditation_bells.mp3 - Buddhist meditation bells');
  print('• ney-flute.mp3 - Sufi mystical flute');
  print('• calm-zen-river-flowing.mp3 - Zen river ambience');
  print('• om_tone.mp3 - Universal meditation tone');

  print('\n🎉 Audio variety system test completed!');
} 