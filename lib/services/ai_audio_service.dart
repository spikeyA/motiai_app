import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../secrets.dart';
import 'hive_quote_service.dart';
import 'package:flutter/services.dart';

class AIAudioGenerator {
  static const String _anthropicEndpoint = 'https://api.anthropic.com/v1/messages';
  static const String _anthropicTTSEndpoint = 'https://api.anthropic.com/v1/audio/speech';
  
  // Cache for storing generated audio
  static final Map<String, String> _audioCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(hours: 24);
  
  /// Generate ambient sound for a tradition
  static Future<String?> generateAmbientSound(String tradition) async {
    // Generate a random variation (1-11) for this tradition
    final variation = (DateTime.now().millisecondsSinceEpoch % 11) + 1;
    final cacheKey = _generateCacheKey(tradition, variation);
    
    // Check cache first
    if (_audioCache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null && DateTime.now().difference(timestamp) < _cacheExpiry) {
        print('[AIAudio] Using cached audio for: $tradition (variation $variation)');
        return _audioCache[cacheKey];
      } else {
        _audioCache.remove(cacheKey);
        _cacheTimestamps.remove(cacheKey);
      }
    }
    
    // Check local storage
    final cachedAudio = await _getCachedAudioFromStorage(cacheKey);
    if (cachedAudio != null) {
      print('[AIAudio] Using local cached audio for: $tradition (variation $variation)');
      _audioCache[cacheKey] = cachedAudio;
      _cacheTimestamps[cacheKey] = DateTime.now();
      return cachedAudio;
    }
    
    // Generate new ambient sound
    print('[AIAudio] Generating new ambient sound for: $tradition (variation $variation)');
    final audioData = await _generateAmbientSoundForTradition(tradition, variation);
    
    if (audioData != null) {
      _audioCache[cacheKey] = audioData;
      _cacheTimestamps[cacheKey] = DateTime.now();
      await _saveAudioToStorage(cacheKey, audioData);
      print('[AIAudio] Audio cached for future use');
    }
    
    return audioData;
  }
  
  /// Generate ambient sound using Claude's audio API
  static Future<String?> _generateAmbientSoundForTradition(String tradition, int variation) async {
    String? apiKey;
    try {
      apiKey = dotenv.env['ANTHROPIC_API_KEY'];
      print('[AIAudio] Anthropic API key found: ${apiKey?.substring(0, apiKey.length > 20 ? 20 : apiKey.length)}...');
    } catch (e) {
      print('[AIAudio] Error loading Anthropic API key: $e');
      return await _convertFallbackToBase64(tradition);
    }
    
    if (apiKey == null || apiKey.isEmpty) {
      print('[AIAudio] No Anthropic API key found - using fallback audio');
      return await _convertFallbackToBase64(tradition);
    }
    
    try {
      final prompt = _buildAmbientPrompt(tradition, variation);
      print('[AIAudio] Making request to Claude Audio API...');
      print('[AIAudio] Prompt: $prompt');
      
      final response = await http.post(
        Uri.parse(_anthropicTTSEndpoint),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'claude-3-haiku-20240307',
          'input': prompt,
          'voice': _getVoiceForTradition(tradition),
          'response_format': 'mp3',
          'speed': 0.8,
        }),
      );
      
      print('[AIAudio] Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final audioBytes = response.bodyBytes;
        final base64Audio = base64Encode(audioBytes);
        final audioUrl = 'data:audio/mp3;base64,$base64Audio';
        print('[AIAudio] Success! Generated audio (base64 length: ${base64Audio.length})');
        return audioUrl;
      } else {
        print('[AIAudio] Error ${response.statusCode}: ${response.body}');
        // Try alternative approach using Claude's text generation + TTS
        final ttsAudio = await _generateAudioViaClaudeText(tradition, apiKey, variation);
        if (ttsAudio != null && !ttsAudio.contains('.mp3')) {
          return ttsAudio;
        }
        return await _convertFallbackToBase64(tradition);
      }
    } catch (e) {
      print('[AIAudio] Exception: $e');
      return await _convertFallbackToBase64(tradition);
    }
  }
  
  /// Alternative method: Generate audio via Claude text generation + TTS
  static Future<String?> _generateAudioViaClaudeText(String tradition, String apiKey, int variation) async {
    try {
      // First, generate ambient sound description using Claude
      final textResponse = await http.post(
        Uri.parse(_anthropicEndpoint),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'claude-3-haiku-20240307',
          'max_tokens': 100,
          'messages': [
            {
              'role': 'user',
              'content': 'Generate a short, poetic description of ambient sounds for $tradition meditation (variation $variation). Focus on natural sounds, spiritual atmosphere, and peaceful elements. Keep it under 50 words and make it suitable for text-to-speech. Make it different from other variations.'
            }
          ]
        }),
      );
      
      if (textResponse.statusCode == 200) {
        final responseData = jsonDecode(textResponse.body);
        final generatedText = responseData['content'][0]['text'];
        print('[AIAudio] Generated text for TTS: $generatedText');
        
        // Now convert to speech using Claude's TTS
        final ttsResponse = await http.post(
          Uri.parse(_anthropicTTSEndpoint),
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'model': 'claude-3-haiku-20240307',
            'input': generatedText,
            'voice': _getVoiceForTradition(tradition),
            'response_format': 'mp3',
            'speed': 0.7,
          }),
        );
        
        if (ttsResponse.statusCode == 200) {
          final audioBytes = ttsResponse.bodyBytes;
          final base64Audio = base64Encode(audioBytes);
          final audioUrl = 'data:audio/mp3;base64,$base64Audio';
          print('[AIAudio] Success! Generated audio via Claude TTS (base64 length: ${base64Audio.length})');
          return audioUrl;
        }
      }
      
      return await _convertFallbackToBase64(tradition);
    } catch (e) {
      print('[AIAudio] Error in Claude TTS generation: $e');
      return await _convertFallbackToBase64(tradition);
    }
  }
  
  /// Get appropriate voice for tradition
  static String _getVoiceForTradition(String tradition) {
    final traditionLower = tradition.toLowerCase();
    
    if (traditionLower.contains('buddhist') || traditionLower.contains('zen')) {
      return 'alloy'; // Calm, peaceful
    } else if (traditionLower.contains('sufi')) {
      return 'echo'; // Mystical, ethereal
    } else if (traditionLower.contains('taoism')) {
      return 'fable'; // Natural, flowing
    } else if (traditionLower.contains('stoicism')) {
      return 'onyx'; // Dignified, strong
    } else if (traditionLower.contains('hinduism')) {
      return 'nova'; // Sacred, divine
    } else if (traditionLower.contains('indigenous')) {
      return 'shimmer'; // Natural, connected
    } else if (traditionLower.contains('mindful')) {
      return 'alloy'; // Modern, calm
    } else if (traditionLower.contains('social')) {
      return 'echo'; // Inclusive, harmonious
    } else {
      return 'alloy'; // Default calm voice
    }
  }
  
  /// Build ambient sound prompt for tradition (simplified for TTS)
  static String _buildAmbientPrompt(String tradition, int variation) {
    final traditionLower = tradition.toLowerCase();
    
    if (traditionLower.contains('buddhist')) {
      switch (variation) {
        case 1:
          return "Gentle meditation bells ring softly in the distance. Peaceful temple atmosphere surrounds you with flowing water and distant birdsong. The zen garden whispers tranquility.";
        case 2:
          return "Sacred mantras echo through ancient temple halls. Incense smoke drifts gently as prayer wheels turn with rhythmic devotion. Spiritual serenity fills the air.";
        case 3:
          return "Morning mist rises from lotus ponds. Bamboo wind chimes sing softly in the breeze. Monks' chanting creates a meditative atmosphere of inner peace.";
        case 4:
          return "Distant temple gongs resonate through mountain valleys. Flowing streams harmonize with meditation bells. The sacred space breathes with spiritual energy.";
        case 5:
          return "Evening prayer drums beat softly in the monastery. Candlelight flickers as incense burns. The peaceful sanctuary echoes with divine wisdom.";
        case 6:
          return "Soft chanting blends with the sound of rain on temple roofs. The air is filled with incense and the gentle hum of devotion.";
        case 7:
          return "Lotus petals float on tranquil ponds. The distant sound of wooden fish and chanting monks create a serene meditation space.";
        case 8:
          return "Wind rustles through bamboo groves. The rhythmic sound of prayer beads and soft footsteps on tatami mats bring calm.";
        case 9:
          return "Temple bells echo at dawn. The scent of sandalwood and the sound of water trickling over stones fill the air.";
        case 10:
          return "A gentle breeze carries the sound of distant chanting. The golden light of sunrise bathes the temple in peace.";
        case 11:
          return "The hush of meditation is broken only by the soft ringing of bells and the distant call of birds.";
        default:
          return "Gentle meditation bells ring softly in the distance. Peaceful temple atmosphere surrounds you with flowing water and distant birdsong.";
      }
    } else if (traditionLower.contains('sufi')) {
      switch (variation) {
        case 1:
          return "Mystical ney flute melodies drift through desert winds. Flowing robes whisper secrets as spiritual chanting echoes in the ethereal atmosphere.";
        case 2:
          return "Sacred drum rhythms pulse with cosmic energy. Whirling dervishes create mystical vibrations. The desert night echoes with divine love songs.";
        case 3:
          return "Ancient Persian instruments weave spiritual harmonies. Sufi poetry flows like gentle streams. The mystical journey unfolds through sacred sound.";
        case 4:
          return "Desert winds carry mystical chants across sand dunes. Traditional instruments create ethereal melodies. The soul's dance with the divine begins.";
        case 5:
          return "Sacred music rises from ancient courtyards. Sufi masters' teachings echo through time. The heart's longing for union creates celestial harmony.";
        case 6:
          return "The sound of hand drums and clapping fills the air. The whirling of dervishes is accompanied by haunting flute melodies.";
        case 7:
          return "A gentle breeze carries the sound of chanting and the rhythmic beat of frame drums. The desert night is alive with spiritual music.";
        case 8:
          return "The call to prayer echoes across the sands. The soft strumming of oud and the distant sound of singing create a mystical mood.";
        case 9:
          return "The hush of twilight is filled with the sound of recitation and the gentle tapping of tambourines.";
        case 10:
          return "The scent of rosewater and the sound of poetry recited in the courtyard create a sacred space.";
        case 11:
          return "The night is alive with the sound of flutes, drums, and the soft chanting of seekers on the Sufi path.";
        default:
          return "Mystical ney flute melodies drift through desert winds. Flowing robes whisper secrets as spiritual chanting echoes.";
      }
    } else if (traditionLower.contains('zen')) {
      switch (variation) {
        case 1:
          return "Flowing water cascades gently while wind rustles through bamboo. Meditation bells chime softly in the peaceful garden, creating natural tranquility.";
        case 2:
          return "Morning dew drops fall from cherry blossoms. Stone lanterns glow softly in the zen garden. The sound of silence speaks volumes of wisdom.";
        case 3:
          return "Bamboo groves sway in gentle breezes. Water features create rhythmic meditation sounds. The minimalist beauty of zen philosophy unfolds.";
        case 4:
          return "Ancient temple bells echo through misty mountains. Raked gravel gardens whisper zen wisdom. The present moment reveals its infinite depth.";
        case 5:
          return "Evening meditation hall resonates with peaceful energy. Traditional instruments play zen melodies. The mind finds stillness in natural harmony.";
        case 6:
          return "Morning mist rises from lotus ponds. Bamboo wind chimes sing softly in the breeze. Monks' chanting creates a meditative atmosphere of inner peace.";
        case 7:
          return "Distant temple gongs resonate through mountain valleys. Flowing streams harmonize with meditation bells. The sacred space breathes with spiritual energy.";
        case 8:
          return "Evening prayer drums beat softly in the monastery. Candlelight flickers as incense burns. The peaceful sanctuary echoes with divine wisdom.";
        case 9:
          return "Soft chanting blends with the sound of rain on temple roofs. The air is filled with incense and the gentle hum of devotion.";
        case 10:
          return "Lotus petals float on tranquil ponds. The distant sound of wooden fish and chanting monks create a serene meditation space.";
        case 11:
          return "Wind rustles through bamboo groves. The rhythmic sound of prayer beads and soft footsteps on tatami mats bring calm.";
        default:
          return "Flowing water cascades gently while wind rustles through bamboo. Meditation bells chime softly in the peaceful garden.";
      }
    } else if (traditionLower.contains('taoism')) {
      switch (variation) {
        case 1:
          return "Mountain streams babble harmoniously as waterfalls flow with natural rhythm. Earth tones blend with peaceful nature sounds in perfect balance.";
        case 2:
          return "Ancient wisdom flows like mountain rivers. Yin and yang energies dance in natural harmony. The Tao reveals itself through earth's gentle sounds.";
        case 3:
          return "Misty peaks echo with ancient teachings. Natural elements create cosmic music. The way of nature guides the soul's journey.";
        case 4:
          return "Sacred mountains whisper Taoist secrets. Flowing water symbolizes life's natural course. The universe's rhythm pulses through all creation.";
        case 5:
          return "Traditional instruments play Taoist melodies. Natural sounds blend with spiritual wisdom. The path of least resistance reveals inner peace.";
        case 6:
          return "Morning dew drops fall from cherry blossoms. Stone lanterns glow softly in the zen garden. The sound of silence speaks volumes of wisdom.";
        case 7:
          return "Bamboo groves sway in gentle breezes. Water features create rhythmic meditation sounds. The minimalist beauty of zen philosophy unfolds.";
        case 8:
          return "Ancient temple bells echo through misty mountains. Raked gravel gardens whisper zen wisdom. The present moment reveals its infinite depth.";
        case 9:
          return "Evening meditation hall resonates with peaceful energy. Traditional instruments play zen melodies. The mind finds stillness in natural harmony.";
        case 10:
          return "Morning mist rises from lotus ponds. Bamboo wind chimes sing softly in the breeze. Monks' chanting creates a meditative atmosphere of inner peace.";
        case 11:
          return "Distant temple gongs resonate through mountain valleys. Flowing streams harmonize with meditation bells. The sacred space breathes with spiritual energy.";
        default:
          return "Mountain streams babble harmoniously as waterfalls flow with natural rhythm. Earth tones blend with peaceful nature sounds.";
      }
    } else if (traditionLower.contains('stoicism')) {
      switch (variation) {
        case 1:
          return "Classical music plays softly in dignified atmosphere. Intellectual contemplation fills the peaceful study environment with wisdom.";
        case 2:
          return "Ancient philosophy echoes through marble halls. Stoic wisdom resonates with timeless truth. The mind finds strength in rational reflection.";
        case 3:
          return "Noble thoughts flow like clear streams. Intellectual discourse creates mental clarity. The stoic path leads to inner fortitude.";
        case 4:
          return "Philosophical discussions echo in quiet libraries. Ancient wisdom guides modern minds. The pursuit of virtue creates lasting peace.";
        case 5:
          return "Contemplative silence reveals profound insights. Stoic principles guide daily practice. The disciplined mind finds true freedom.";
        case 6:
          return "Morning dew drops fall from cherry blossoms. Stone lanterns glow softly in the zen garden. The sound of silence speaks volumes of wisdom.";
        case 7:
          return "Bamboo groves sway in gentle breezes. Water features create rhythmic meditation sounds. The minimalist beauty of zen philosophy unfolds.";
        case 8:
          return "Ancient temple bells echo through misty mountains. Raked gravel gardens whisper zen wisdom. The present moment reveals its infinite depth.";
        case 9:
          return "Evening meditation hall resonates with peaceful energy. Traditional instruments play zen melodies. The mind finds stillness in natural harmony.";
        case 10:
          return "Morning mist rises from lotus ponds. Bamboo wind chimes sing softly in the breeze. Monks' chanting creates a meditative atmosphere of inner peace.";
        case 11:
          return "Distant temple gongs resonate through mountain valleys. Flowing streams harmonize with meditation bells. The sacred space breathes with spiritual energy.";
        default:
          return "Classical music plays softly in dignified atmosphere. Intellectual contemplation fills the peaceful study environment.";
      }
    } else if (traditionLower.contains('hinduism')) {
      switch (variation) {
        case 1:
          return "Sacred mantras resonate deeply as temple bells ring. Spiritual chanting creates divine atmosphere with sacred music.";
        case 2:
          return "Ancient Sanskrit chants echo through temple halls. Sacred instruments create divine harmony. The soul connects with cosmic consciousness.";
        case 3:
          return "Bhajans and kirtans fill the air with devotion. Temple bells announce divine presence. The spiritual journey unfolds through sacred sound.";
        case 4:
          return "Vedic wisdom flows through traditional melodies. Sacred fire ceremonies create spiritual energy. The divine dance of creation continues.";
        case 5:
          return "Mantra meditation creates inner transformation. Sacred geometry resonates with cosmic frequencies. The eternal truth reveals itself.";
        case 6:
          return "Morning dew drops fall from cherry blossoms. Stone lanterns glow softly in the zen garden. The sound of silence speaks volumes of wisdom.";
        case 7:
          return "Bamboo groves sway in gentle breezes. Water features create rhythmic meditation sounds. The minimalist beauty of zen philosophy unfolds.";
        case 8:
          return "Ancient temple bells echo through misty mountains. Raked gravel gardens whisper zen wisdom. The present moment reveals its infinite depth.";
        case 9:
          return "Evening meditation hall resonates with peaceful energy. Traditional instruments play zen melodies. The mind finds stillness in natural harmony.";
        case 10:
          return "Morning mist rises from lotus ponds. Bamboo wind chimes sing softly in the breeze. Monks' chanting creates a meditative atmosphere of inner peace.";
        case 11:
          return "Distant temple gongs resonate through mountain valleys. Flowing streams harmonize with meditation bells. The sacred space breathes with spiritual energy.";
        default:
          return "Sacred mantras resonate deeply as temple bells ring. Spiritual chanting creates divine atmosphere with sacred music.";
      }
    } else if (traditionLower.contains('indigenous')) {
      switch (variation) {
        case 1:
          return "Natural earth sounds echo with sacred drum rhythms. Flowing water connects spiritually as organic harmony surrounds.";
        case 2:
          return "Traditional drums beat with ancestral wisdom. Nature's voice speaks through wind and water. The earth's heartbeat guides the spirit.";
        case 3:
          return "Sacred ceremonies create spiritual connection. Natural elements harmonize with ancient traditions. The land's wisdom flows freely.";
        case 4:
          return "Ancestral knowledge echoes through time. Earth's rhythms guide spiritual practice. The connection to nature reveals inner truth.";
        case 5:
          return "Traditional instruments honor the earth. Natural sounds create healing vibrations. The spirit finds peace in nature's embrace.";
        case 6:
          return "Morning dew drops fall from cherry blossoms. Stone lanterns glow softly in the zen garden. The sound of silence speaks volumes of wisdom.";
        case 7:
          return "Bamboo groves sway in gentle breezes. Water features create rhythmic meditation sounds. The minimalist beauty of zen philosophy unfolds.";
        case 8:
          return "Ancient temple bells echo through misty mountains. Raked gravel gardens whisper zen wisdom. The present moment reveals its infinite depth.";
        case 9:
          return "Evening meditation hall resonates with peaceful energy. Traditional instruments play zen melodies. The mind finds stillness in natural harmony.";
        case 10:
          return "Morning mist rises from lotus ponds. Bamboo wind chimes sing softly in the breeze. Monks' chanting creates a meditative atmosphere of inner peace.";
        case 11:
          return "Distant temple gongs resonate through mountain valleys. Flowing streams harmonize with meditation bells. The sacred space breathes with spiritual energy.";
        default:
          return "Natural earth sounds echo with sacred drum rhythms. Flowing water connects spiritually as organic harmony surrounds.";
      }
    } else if (traditionLower.contains('mindful')) {
      switch (variation) {
        case 1:
          return "Modern ambient music flows peacefully with technology sounds. Calming digital atmosphere creates mindful meditation space.";
        case 2:
          return "Digital mindfulness meets ancient wisdom. Technology creates peaceful meditation environments. The modern mind finds balance.";
        case 3:
          return "Ambient electronic sounds guide meditation. Digital tools support spiritual practice. The future of mindfulness unfolds.";
        case 4:
          return "Technology enhances traditional meditation. Digital calm creates inner peace. The mindful tech revolution continues.";
        case 5:
          return "Modern instruments play ancient wisdom. Digital harmony meets spiritual practice. The mindful future is now.";
        case 6:
          return "Morning dew drops fall from cherry blossoms. Stone lanterns glow softly in the zen garden. The sound of silence speaks volumes of wisdom.";
        case 7:
          return "Bamboo groves sway in gentle breezes. Water features create rhythmic meditation sounds. The minimalist beauty of zen philosophy unfolds.";
        case 8:
          return "Ancient temple bells echo through misty mountains. Raked gravel gardens whisper zen wisdom. The present moment reveals its infinite depth.";
        case 9:
          return "Evening meditation hall resonates with peaceful energy. Traditional instruments play zen melodies. The mind finds stillness in natural harmony.";
        case 10:
          return "Morning mist rises from lotus ponds. Bamboo wind chimes sing softly in the breeze. Monks' chanting creates a meditative atmosphere of inner peace.";
        case 11:
          return "Distant temple gongs resonate through mountain valleys. Flowing streams harmonize with meditation bells. The sacred space breathes with spiritual energy.";
        default:
          return "Modern ambient music flows peacefully with technology sounds. Calming digital atmosphere creates mindful meditation space.";
      }
    } else if (traditionLower.contains('social')) {
      switch (variation) {
        case 1:
          return "Community sounds blend harmoniously in peaceful gathering. Inclusive atmosphere resonates with harmonious voices and collective harmony.";
        case 2:
          return "Voices of unity create social change. Collective wisdom flows through community. The power of togetherness transforms society.";
        case 3:
          return "Diverse perspectives harmonize in dialogue. Social justice creates peaceful communities. The collective voice brings positive change.";
        case 4:
          return "Community healing through shared wisdom. Inclusive practices create social harmony. The strength of unity guides progress.";
        case 5:
          return "Collective action creates lasting peace. Social movements build better futures. The community's heart beats as one.";
        case 6:
          return "Morning dew drops fall from cherry blossoms. Stone lanterns glow softly in the zen garden. The sound of silence speaks volumes of wisdom.";
        case 7:
          return "Bamboo groves sway in gentle breezes. Water features create rhythmic meditation sounds. The minimalist beauty of zen philosophy unfolds.";
        case 8:
          return "Ancient temple bells echo through misty mountains. Raked gravel gardens whisper zen wisdom. The present moment reveals its infinite depth.";
        case 9:
          return "Evening meditation hall resonates with peaceful energy. Traditional instruments play zen melodies. The mind finds stillness in natural harmony.";
        case 10:
          return "Morning mist rises from lotus ponds. Bamboo wind chimes sing softly in the breeze. Monks' chanting creates a meditative atmosphere of inner peace.";
        case 11:
          return "Distant temple gongs resonate through mountain valleys. Flowing streams harmonize with meditation bells. The sacred space breathes with spiritual energy.";
        default:
          return "Community sounds blend harmoniously in peaceful gathering. Inclusive atmosphere resonates with harmonious voices.";
      }
    } else {
      switch (variation) {
        case 1:
          return "Peaceful meditation music flows gently with calming ambient sounds. Spiritual tranquility surrounds with gentle nature whispers.";
        case 2:
          return "Universal wisdom echoes through peaceful sounds. Spiritual practices create inner harmony. The soul finds rest in gentle meditation.";
        case 3:
          return "Ancient and modern wisdom blend harmoniously. Spiritual traditions create peaceful atmospheres. The universal truth reveals itself.";
        case 4:
          return "Sacred sounds from all traditions unite. Spiritual practices guide inner peace. The universal path leads to enlightenment.";
        case 5:
          return "Timeless wisdom flows through peaceful melodies. Spiritual traditions create harmony. The universal consciousness awakens.";
        case 6:
          return "Morning dew drops fall from cherry blossoms. Stone lanterns glow softly in the zen garden. The sound of silence speaks volumes of wisdom.";
        case 7:
          return "Bamboo groves sway in gentle breezes. Water features create rhythmic meditation sounds. The minimalist beauty of zen philosophy unfolds.";
        case 8:
          return "Ancient temple bells echo through misty mountains. Raked gravel gardens whisper zen wisdom. The present moment reveals its infinite depth.";
        case 9:
          return "Evening meditation hall resonates with peaceful energy. Traditional instruments play zen melodies. The mind finds stillness in natural harmony.";
        case 10:
          return "Morning mist rises from lotus ponds. Bamboo wind chimes sing softly in the breeze. Monks' chanting creates a meditative atmosphere of inner peace.";
        case 11:
          return "Distant temple gongs resonate through mountain valleys. Flowing streams harmonize with meditation bells. The sacred space breathes with spiritual energy.";
        default:
          return "Peaceful meditation music flows gently with calming ambient sounds. Spiritual tranquility surrounds with gentle nature whispers.";
      }
    }
  }
  
  /// Get fallback audio for tradition
  static String _getFallbackAudioForTradition(String tradition) {
    final traditionLower = tradition.toLowerCase();
    
    if (traditionLower.contains('buddhist') || traditionLower.contains('zen')) {
      return 'assets/audio/meditation_bells.mp3';
    } else if (traditionLower.contains('sufi')) {
      return 'assets/audio/ney-flute.mp3';
    } else if (traditionLower.contains('taoism')) {
      return 'assets/audio/calm-zen-river-flowing.mp3';
    } else if (traditionLower.contains('stoicism')) {
      return 'assets/audio/meditation_bells.mp3';
    } else if (traditionLower.contains('hinduism')) {
      return 'assets/audio/meditation_bells.mp3';
    } else if (traditionLower.contains('indigenous')) {
      return 'assets/audio/meditation_bells.mp3';
    } else if (traditionLower.contains('mindful')) {
      return 'assets/audio/calm-zen-river-flowing.mp3';
    } else if (traditionLower.contains('social')) {
      return 'assets/audio/calm-zen-river-flowing.mp3';
    } else {
      return 'assets/audio/meditation_bells.mp3';
    }
  }
  
  /// Generate a unique cache key for a tradition
  static String _generateCacheKey(String tradition, int variation) {
    return 'ai_audio_${tradition.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_$variation';
  }
  
  /// Save audio to local storage and Hive
  static Future<void> _saveAudioToStorage(String cacheKey, String audioData) async {
    try {
      // Save to local file storage
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/audio_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      
      final file = File('${cacheDir.path}/$cacheKey.mp3');
      if (audioData.startsWith('data:audio/')) {
        final data = audioData.split(',')[1];
        final bytes = base64Decode(data);
        await file.writeAsBytes(bytes);
      }
      
      // Also store in Hive for the debug counter
      HiveQuoteService.instance.storeGeneratedAudio(cacheKey, audioData);
      print('[AIAudio] Stored audio in both local storage and Hive: $cacheKey');
    } catch (e) {
      print('[AIAudio] Failed to save audio to storage: $e');
    }
  }
  
  /// Get cached audio from local storage
  static Future<String?> _getCachedAudioFromStorage(String cacheKey) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/audio_cache/$cacheKey.mp3');
      
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final base64Data = base64Encode(bytes);
        return 'data:audio/mp3;base64,$base64Data';
      }
    } catch (e) {
      print('[AIAudio] Failed to read cached audio: $e');
    }
    return null;
  }
  
  /// Pre-generate ambient sounds for all traditions
  static Future<void> preGenerateAmbientSounds({Function(String audioId, String audioData)? onAudioGenerated}) async {
    print('[AIAudio] Starting ambient sound pre-generation...');
    final traditions = [
      'Buddhist Inspiration', 
      'Sufi Inspiration', 
      'Zen Inspiration', 
      'Taoism Inspiration', 
      'Stoicism Inspiration',
      'Hinduism Inspiration',
      'Indigenous Wisdom Inspiration',
      'Mindful Tech Inspiration',
      'Social Justice Inspiration'
    ];
    
    for (final tradition in traditions) {
      print('[AIAudio] Generating 11 ambient sounds for $tradition...');
      
      // Generate all 11 variations for this tradition
      for (int variation = 1; variation <= 11; variation++) {
        try {
          print('[AIAudio] Generating variation $variation/11 for $tradition...');
          
          // Generate the specific variation
          final audioData = await _generateAmbientSoundForTradition(tradition, variation);
          if (audioData != null) {
            final audioId = _generateCacheKey(tradition, variation);
            // Store in Hive for debug counter
            HiveQuoteService.instance.storeGeneratedAudio(audioId, audioData);
            if (onAudioGenerated != null) {
              onAudioGenerated(audioId, audioData);
            }
            print('[AIAudio] Stored ambient sound variation $variation in Hive: $audioId');
            print('[AIAudio] Generated ambient sound variation $variation for $tradition');
          } else {
            print('[AIAudio] Failed to generate audio for $tradition variation $variation');
          }
          
          // Add delay between variations
          if (variation < 11) {
            await Future.delayed(Duration(milliseconds: 1000));
          }
        } catch (e) {
          print('[AIAudio] Failed to generate ambient sound variation $variation for $tradition: $e');
        }
      }
      
      // Add delay between traditions
      if (tradition != traditions.last) {
        await Future.delayed(Duration(milliseconds: 2000));
      }
    }
    print('[AIAudio] Ambient sound pre-generation completed - 11 variations per tradition');
  }
  
  /// Clear cached audio for a specific tradition
  static Future<void> clearCachedAudioForTradition(String tradition) async {
    try {
      // Clear all 11 variations for this tradition
      for (int variation = 1; variation <= 11; variation++) {
        final cacheKey = _generateCacheKey(tradition, variation);
        
        // Clear from memory cache
        _audioCache.remove(cacheKey);
        
        // Clear from storage
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/audio_cache/$cacheKey.mp3');
        if (await file.exists()) {
          await file.delete();
          print('[AIAudio] Cleared cached audio variation $variation for tradition: $tradition');
        }
      }
      print('[AIAudio] Cleared all 11 variations of cached audio for tradition: $tradition');
    } catch (e) {
      print('[AIAudio] Failed to clear cached audio: $e');
    }
  }

  /// Convert fallback audio to base64 and store in Hive
  static Future<String?> _convertFallbackToBase64(String tradition) async {
    try {
      final fallbackAudio = _getFallbackAudioForTradition(tradition);
      
      // Read the asset file using rootBundle
      final ByteData data = await rootBundle.load(fallbackAudio);
      final Uint8List bytes = data.buffer.asUint8List();
      final base64Audio = base64Encode(bytes);
      final audioUrl = 'data:audio/mp3;base64,$base64Audio';
      
      print('[AIAudio] Success! Generated fallback audio (base64 length: ${base64Audio.length})');
      
      // Store in Hive for the debug counter
      final cacheKey = _generateCacheKey(tradition, 1);
      HiveQuoteService.instance.storeGeneratedAudio(cacheKey, audioUrl);
      print('[AIAudio] Stored fallback audio in Hive for: $cacheKey');
      
      return audioUrl;
    } catch (e) {
      print('[AIAudio] Error converting fallback audio to base64: $e');
      return null;
    }
  }
} 