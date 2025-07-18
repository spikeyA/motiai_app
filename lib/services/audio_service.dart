import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'hive_quote_service.dart';
import 'dart:convert';

class AudioService {
  static AudioPlayer? _currentPlayer;
  static bool _isPlaying = false;
  static Timer? _audioTimer;
  static const int _audioIntervalSeconds = 30; // 30-second intervals
  static String? _currentAudioFilePath; // Track current audio file
  static String? _currentAudioId; // Track current AI audio ID
  static String? _lastAudioTradition;
  static final Map<String, Set<String>> _playedAudioKeys = {};

  // Audio files for each tradition
  static const Map<String, String> _ambienceSounds = {
    'Buddhist': 'audio/meditation_bells.mp3',
    'Sufi': 'audio/ney-flute.mp3',
    'Zen': 'audio/calm-zen-river-flowing.mp3',
    'Taoism': 'audio/meditation_bells.mp3',
    'Stoicism': 'audio/meditation_bells.mp3',
    'Indigenous Wisdom': 'audio/meditation_bells.mp3',
    'Mindful Tech': 'audio/meditation_bells.mp3',
    'Eco-Spirituality': 'audio/calm-zen-river-flowing.mp3',
    'Poetic Sufism': 'audio/ney-flute.mp3',
  };

  // Fallback sounds if specific tradition audio is not available
  static const Map<String, String> _fallbackSounds = {
    'Buddhist': 'audio/om_tone.mp3',
    'Sufi': 'audio/ney-flute.mp3',
    'Zen': 'audio/calm-zen-river-flowing.mp3',
    'Taoism': 'audio/om_tone.mp3',
    'Stoicism': 'audio/om_tone.mp3',
    'Indigenous Wisdom': 'audio/om_tone.mp3',
    'Mindful Tech': 'audio/om_tone.mp3',
    'Eco-Spirituality': 'audio/calm-zen-river-flowing.mp3',
    'Poetic Sufism': 'audio/ney-flute.mp3',
  };

  /// Play ambience sound for a specific tradition
  static Future<void> playAmbience(String tradition) async {
    try {
      // Prevent same tradition twice in a row (unless only one tradition)
      if (_lastAudioTradition == tradition) {
        print('[Audio] Skipping audio for same tradition in a row: $tradition');
        return;
      }
      _lastAudioTradition = tradition;

      // Stop any currently playing audio
      await stopAmbience();

      // Gather all available AI audio keys for this tradition
      final allAudioKeys = HiveQuoteService.instance.getAIAudioKeysForTradition(tradition);

      // Track played audio keys for this tradition in the session
      _playedAudioKeys.putIfAbsent(tradition, () => <String>{});
      final played = _playedAudioKeys[tradition]!;
      final unplayed = allAudioKeys.where((k) => !played.contains(k)).toList();

      String? selectedAudioId;
      if (unplayed.isNotEmpty) {
        unplayed.shuffle();
        selectedAudioId = unplayed.first;
      } else if (allAudioKeys.isNotEmpty) {
        // All played, reset and pick randomly
        played.clear();
        allAudioKeys.shuffle();
        selectedAudioId = allAudioKeys.first;
      }

      if (selectedAudioId != null) {
        final aiAudioData = HiveQuoteService.instance.getStoredAudio(selectedAudioId);
        if (aiAudioData != null && aiAudioData.startsWith('data:audio/')) {
          print('[Audio] Using AI-generated audio for $tradition: $selectedAudioId');
          played.add(selectedAudioId);
          await _playAIAudio(aiAudioData, selectedAudioId);
          return;
        }
      }

      // Fallback to local audio files
      String audioFile = _getAudioFile(tradition);
      _currentAudioFilePath = audioFile;
      print('[Audio] Using local audio for $tradition: $audioFile');
      await _playLocalAudio(audioFile);
    } catch (e) {
      print('[Audio] Error playing ambience: $e');
      // Don't throw error - audio is optional
    }
  }
  
  /// Play AI-generated audio
  static Future<void> _playAIAudio(String audioData, String audioId) async {
    try {
      _currentAudioId = audioId;
      
      // Create new audio player
      _currentPlayer = AudioPlayer();
      
      // Set audio mode for background playback
      await _currentPlayer!.setReleaseMode(ReleaseMode.loop);
      
      // Convert base64 to bytes and play
      final data = audioData.split(',')[1];
      final bytes = base64Decode(data);
      await _currentPlayer!.play(BytesSource(bytes));
      _isPlaying = true;
      
      // Start 30-second timer
      _startAudioTimer();
      
      print('[Audio] AI ambience started successfully - will loop every $_audioIntervalSeconds seconds');
    } catch (e) {
      print('[Audio] Error playing AI audio: $e');
      // Fall back to local audio - extract tradition from audioId
      final tradition = _extractTraditionFromAudioId(audioId);
      String audioFile = _getAudioFile(tradition);
      await _playLocalAudio(audioFile);
    }
  }
  
  /// Extract tradition from AI audio ID
  static String _extractTraditionFromAudioId(String audioId) {
    // Convert audioId like 'ai_audio_buddhist_inspiration' back to 'Buddhist Inspiration'
    final parts = audioId.replaceFirst('ai_audio_', '').split('_');
    if (parts.length >= 2) {
      final tradition = parts[0].substring(0, 1).toUpperCase() + parts[0].substring(1);
      final category = parts[1].substring(0, 1).toUpperCase() + parts[1].substring(1);
      return '$tradition $category';
    }
    return 'Zen'; // Default fallback
  }
  
  /// Play local audio file
  static Future<void> _playLocalAudio(String audioFile) async {
    try {
      _currentAudioFilePath = audioFile;
      
      // Create new audio player
      _currentPlayer = AudioPlayer();
      
      // Set audio mode for background playback
      await _currentPlayer!.setReleaseMode(ReleaseMode.loop);
      
      // Play the audio
      await _currentPlayer!.play(AssetSource(audioFile));
      _isPlaying = true;
      
      // Start 30-second timer
      _startAudioTimer();
      
      print('[Audio] Local ambience started successfully - will loop every $_audioIntervalSeconds seconds');
    } catch (e) {
      print('[Audio] Error playing local audio: $e');
    }
  }
  
  /// Generate AI audio ID for tradition
  static String _generateAIAudioId(String tradition) {
    return 'ai_audio_${tradition.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
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
      if (_currentPlayer != null && _isPlaying) {
        await _currentPlayer!.stop();
        
        if (_currentAudioId != null) {
          // Restart AI audio
          final aiAudioData = HiveQuoteService.instance.getStoredAudio(_currentAudioId!);
          if (aiAudioData != null) {
            final data = aiAudioData.split(',')[1];
            final bytes = base64Decode(data);
            await _currentPlayer!.play(BytesSource(bytes));
            print('[Audio] AI audio restarted successfully: $_currentAudioId');
          }
        } else if (_currentAudioFilePath != null) {
          // Restart local audio
          await _currentPlayer!.play(AssetSource(_currentAudioFilePath!));
          print('[Audio] Local audio restarted successfully: $_currentAudioFilePath');
        }
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
      _currentAudioId = null;
      
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
    _currentAudioId = null;
    await stopAmbience();
  }
} 