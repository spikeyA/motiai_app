# Audio System Documentation

## Overview

The MotiAI app features a sophisticated audio system where each spiritual tradition has its own unique ambient sound. This enhances the meditation experience by providing tradition-specific audio that matches the cultural and spiritual context of each quote.

## Architecture

### Audio Sources
1. **AI-Generated Audio**: Primary source using Anthropic Claude TTS
2. **Local Audio Files**: Fallback system with tradition-specific sounds
3. **Smart Fallbacks**: Intelligent mapping when specific files are unavailable

### Audio Flow
```
Quote Tradition → AI Audio Check → Local Audio → Smart Fallback → Play
```

## Tradition-Specific Audio Mapping

### Primary Audio Files (Target)
Each tradition should have its own unique audio file:

| Tradition | Audio File | Description |
|-----------|------------|-------------|
| Buddhist | `buddhist_meditation.mp3` | Tibetan singing bowls and meditation bells |
| Sufi | `sufi_mystical.mp3` | Ney flute and mystical Middle Eastern sounds |
| Zen | `zen_peaceful.mp3` | Japanese koto and flowing water sounds |
| Taoism | `taoism_harmony.mp3` | Chinese guqin and mountain wind sounds |
| Confucianism | `confucianism_wisdom.mp3` | Traditional Chinese instruments |
| Stoicism | `stoicism_dignified.mp3` | Classical Greek/Roman inspired music |
| Hinduism | `hinduism_spiritual.mp3` | Indian sitar and tabla meditation music |
| Indigenous Wisdom | `indigenous_wisdom.mp3` | Native American flute and nature sounds |
| Mindful Tech | `mindful_tech.mp3` | Modern ambient electronic meditation music |
| Social Justice | `social_justice.mp3` | Uplifting community and unity meditation music |

### Current Fallback Mapping
Until all unique audio files are added, the system uses smart fallbacks:

| Tradition | Current Audio | Fallback Logic |
|-----------|---------------|----------------|
| Buddhist | `meditation_bells.mp3` | Eastern meditation tradition |
| Sufi | `ney-flute.mp3` | Middle Eastern mystical tradition |
| Zen | `calm-zen-river-flowing.mp3` | Japanese Zen tradition |
| Taoism | `meditation_bells.mp3` | Eastern meditation tradition |
| Confucianism | `meditation_bells.mp3` | Eastern meditation tradition |
| Stoicism | `meditation_bells.mp3` | Western philosophical tradition |
| Hinduism | `om_tone.mp3` | Indian spiritual tradition |
| Indigenous Wisdom | `meditation_bells.mp3` | Nature-based tradition |
| Mindful Tech | `meditation_bells.mp3` | Modern meditation tradition |
| Social Justice | `om_tone.mp3` | Universal spiritual tradition |

## Audio Features

### AI-Generated Audio
- **11 Variations per Tradition**: Multiple audio variations for variety
- **Anthropic Claude TTS**: Generates unique ambient sound descriptions
- **Hive Storage**: All AI-generated audio is stored locally for instant playback
- **Session Variety**: Prevents repeating the same audio variation until all are used

### Local Audio System
- **Tradition-Specific**: Each tradition has its own unique sound
- **Loop Mode**: Sounds play continuously in the background
- **30-Second Intervals**: Audio automatically restarts every 30 seconds
- **Smart Switching**: Audio changes automatically based on quote tradition

### Audio Controls
- **Auto-Play**: Ambience starts automatically when quotes change
- **Toggle Button**: Tap the volume icon to turn audio on/off
- **Background Playback**: Audio continues even when app is in background
- **Graceful Fallbacks**: System continues working even if specific audio files are missing

## Implementation Details

### AudioService Class
Located in `lib/services/audio_service.dart`

Key methods:
- `playAmbience(String tradition)`: Main method to play tradition-specific audio
- `_getAudioFileWithFallbacks(String tradition)`: Smart fallback logic
- `_playAIAudio(String audioData, String audioId)`: AI-generated audio playback
- `_playLocalAudio(String audioFile)`: Local audio file playback

### Audio File Requirements
- **Format**: MP3 for maximum compatibility
- **Size**: Under 5MB each for optimal performance
- **Quality**: 128kbps minimum for good audio quality
- **Duration**: 2-5 minutes, designed for looping
- **License**: Must be royalty-free for commercial use

## Adding New Audio Files

### Step 1: Prepare Audio Files
1. Obtain royalty-free meditation music appropriate for each tradition
2. Ensure files meet the requirements above
3. Name files according to the convention: `{tradition}_{description}.mp3`

### Step 2: Add to Assets
1. Place audio files in `assets/audio/` directory
2. Update `pubspec.yaml` to include new files:

```yaml
flutter:
  assets:
    - assets/audio/buddhist_meditation.mp3
    - assets/audio/sufi_mystical.mp3
    # ... add all new files
```

### Step 3: Update Audio Service
1. Remove the `_temporaryAudioMapping` section in `AudioService`
2. The system will automatically use the new audio files
3. Test each tradition to ensure audio plays correctly

### Step 4: Test
1. Run the app and test each tradition
2. Verify audio quality and appropriateness
3. Check that fallbacks work for missing files

## Audio Sources

### Recommended Free Sources
1. **Free Music Archive** (freemusicarchive.org)
2. **Incompetech** (incompetech.com) - Kevin MacLeod's music
3. **Bensound** (bensound.com)
4. **YouTube Audio Library**

### Recommended Paid Sources
1. **Epidemic Sound** - Professional meditation music
2. **Artlist** - Spiritual and meditation tracks
3. **AudioJungle** - Individual track purchases

## Troubleshooting

### Common Issues
1. **Audio not playing**: Check file paths and pubspec.yaml configuration
2. **Poor audio quality**: Ensure files are at least 128kbps
3. **Large file sizes**: Compress files to under 5MB
4. **Missing fallbacks**: Verify fallback mapping in AudioService

### Debug Commands
```bash
# Check audio file status
dart scripts/setup_tradition_audio.dart

# Check Hive audio data
dart scripts/check_hive_quotes.dart
```

## Future Enhancements

### Planned Features
1. **Volume Control**: User-adjustable volume levels
2. **Audio Mixing**: Blend multiple audio sources
3. **Custom Audio**: User-uploaded meditation sounds
4. **Audio Effects**: Reverb, echo, and other effects
5. **Crossfading**: Smooth transitions between audio tracks

### Technical Improvements
1. **Audio Streaming**: Stream audio from cloud storage
2. **Compression**: Better audio compression algorithms
3. **Caching**: Improved audio caching system
4. **Background Processing**: Better background audio handling

## Conclusion

The audio system provides a rich, tradition-specific meditation experience that enhances the spiritual journey of users. Each tradition's unique sound creates an immersive environment that supports deep contemplation and mindfulness practice. 