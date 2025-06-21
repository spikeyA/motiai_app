import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class AudioService {
  static AudioPlayer? _currentPlayer;
  static bool _isPlaying = false;
  static Timer? _audioTimer;
  static const int _audioIntervalSeconds = 30; // 30-second intervals
  static String? _currentAudioFilePath; // Track current audio file

  // Audio files for each tradition
  static const Map<String, String> _ambienceSounds = {
    'Buddhist': 'audio/meditation_bells.mp3',
    'Sufi': 'audio/ney-flute.mp3',
    'Zen': 'audio/calm-zen-river-flowing.mp3',
  };

  // Fallback sounds if specific tradition audio is not available
  static const Map<String, String> _fallbackSounds = {
    'Buddhist': 'audio/om_tone.mp3',
    'Sufi': 'audio/ney-flute.mp3',
    'Zen': 'audio/calm-zen-river-flowing.mp3',
  };

  /// Play ambience sound for a specific tradition
  static Future<void> playAmbience(String tradition) async {
    try {
      // Stop any currently playing audio
      await stopAmbience();

      // Get the appropriate audio file
      String audioFile = _getAudioFile(tradition);
      _currentAudioFilePath = audioFile; // Store current file path
      
      print('[Audio] Playing ambience for $tradition: $audioFile');

      // Create new audio player
      _currentPlayer = AudioPlayer();
      
      // Set audio mode for background playback
      await _currentPlayer!.setReleaseMode(ReleaseMode.loop);
      
      // Play the audio
      await _currentPlayer!.play(AssetSource(audioFile));
      _isPlaying = true;

      // Start 30-second timer
      _startAudioTimer();

      print('[Audio] Ambience started successfully - will loop every $_audioIntervalSeconds seconds');
    } catch (e) {
      print('[Audio] Error playing ambience: $e');
      // Don't throw error - audio is optional
    }
  }

  /// Start the audio timer for 30-second intervals
  static void _startAudioTimer() {
    _audioTimer?.cancel();
    _audioTimer = Timer.periodic(Duration(seconds: _audioIntervalSeconds), (timer) {
      if (_isPlaying && _currentPlayer != null) {
        print('[Audio] Restarting audio after $_audioIntervalSeconds seconds');
        _restartAudio();
      } else {
        timer.cancel();
      }
    });
  }

  /// Restart the current audio
  static Future<void> _restartAudio() async {
    try {
      if (_currentPlayer != null && _isPlaying && _currentAudioFilePath != null) {
        await _currentPlayer!.stop();
        await _currentPlayer!.play(AssetSource(_currentAudioFilePath!));
        print('[Audio] Audio restarted successfully: $_currentAudioFilePath');
      }
    } catch (e) {
      print('[Audio] Error restarting audio: $e');
    }
  }

  /// Stop current ambience
  static Future<void> stopAmbience() async {
    try {
      _audioTimer?.cancel();
      _audioTimer = null;
      _currentAudioFilePath = null;
      
      if (_currentPlayer != null && _isPlaying) {
        await _currentPlayer!.stop();
        await _currentPlayer!.dispose();
        _currentPlayer = null;
        _isPlaying = false;
        print('[Audio] Ambience stopped');
      }
    } catch (e) {
      print('[Audio] Error stopping ambience: $e');
    }
  }

  /// Pause current ambience
  static Future<void> pauseAmbience() async {
    try {
      _audioTimer?.cancel();
      _audioTimer = null;
      
      if (_currentPlayer != null && _isPlaying) {
        await _currentPlayer!.pause();
        _isPlaying = false;
        print('[Audio] Ambience paused');
      }
    } catch (e) {
      print('[Audio] Error pausing ambience: $e');
    }
  }

  /// Resume current ambience
  static Future<void> resumeAmbience() async {
    try {
      if (_currentPlayer != null && !_isPlaying) {
        await _currentPlayer!.resume();
        _isPlaying = true;
        _startAudioTimer(); // Restart timer
        print('[Audio] Ambience resumed');
      }
    } catch (e) {
      print('[Audio] Error resuming ambience: $e');
    }
  }

  /// Get the appropriate audio file for a tradition
  static String _getAudioFile(String tradition) {
    // Try to get tradition-specific audio
    String? audioFile = _ambienceSounds[tradition];
    
    // If not found, use fallback
    if (audioFile == null) {
      audioFile = _fallbackSounds[tradition] ?? _fallbackSounds['Zen']!;
    }
    
    return audioFile;
  }

  /// Check if ambience is currently playing
  static bool get isPlaying => _isPlaying;

  /// Get current tradition audio file
  static String? get currentAudioFile => _currentAudioFilePath;

  /// Get the current audio interval in seconds
  static int get audioIntervalSeconds => _audioIntervalSeconds;

  /// Dispose of audio resources
  static Future<void> dispose() async {
    _audioTimer?.cancel();
    _audioTimer = null;
    _currentAudioFilePath = null;
    await stopAmbience();
  }
} 