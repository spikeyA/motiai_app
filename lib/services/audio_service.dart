import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isMuted = false;
  static double _volume = 0.3; // Start with low volume

  // Placeholder URLs for royalty-free music
  // You can replace these with actual royalty-free tracks
  static const Map<String, String> _traditionMusic = {
    'Buddhist': 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav', // Placeholder
    'Sufi': 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav', // Placeholder
    'Zen': 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav', // Placeholder
  };

  // For local files (when you add them to assets/audio/)
  static const Map<String, String> _localTraditionMusic = {
    'Buddhist': 'assets/audio/buddhist_meditation.mp3',
    'Sufi': 'assets/audio/sufi_mystical.mp3',
    'Zen': 'assets/audio/zen_peaceful.mp3',
  };

  static Future<void> initialize() async {
    try {
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  static Future<void> playMusicForTradition(String tradition) async {
    if (_isMuted) return;

    try {
      // Try local file first, then fallback to placeholder URL
      String audioSource = _localTraditionMusic[tradition] ?? _traditionMusic[tradition] ?? '';
      
      if (audioSource.startsWith('assets/')) {
        // For local assets
        await _audioPlayer.setAsset(audioSource);
      } else {
        // For URLs
        await _audioPlayer.setUrl(audioSource);
      }
      
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing music for $tradition: $e');
      // Fallback to a simple meditation sound or silence
    }
  }

  static Future<void> stopMusic() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping music: $e');
    }
  }

  static Future<void> pauseMusic() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Error pausing music: $e');
    }
  }

  static Future<void> resumeMusic() async {
    if (!_isMuted) {
      try {
        await _audioPlayer.play();
      } catch (e) {
        print('Error resuming music: $e');
      }
    }
  }

  static void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      pauseMusic();
    } else {
      resumeMusic();
    }
  }

  static bool get isMuted => _isMuted;

  static Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (!_isMuted) {
      try {
        await _audioPlayer.setVolume(_volume);
      } catch (e) {
        print('Error setting volume: $e');
      }
    }
  }

  static double get volume => _volume;

  static void dispose() {
    _audioPlayer.dispose();
  }

  // Get current playing status
  static bool get isPlaying => _audioPlayer.playing;

  // Get current position
  static Duration get position => _audioPlayer.position;

  // Get total duration
  static Duration get duration => _audioPlayer.duration ?? Duration.zero;
} 