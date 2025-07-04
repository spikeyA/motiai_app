# MotiAI - Wisdom Quotes App

A beautiful Flutter macOS app that displays motivational quotes from Buddhist, Sufi, Zen, and other spiritual traditions with AI-generated background images and ambient audio.

## ✨ Features

- **Wisdom Quotes**: Curated collection of inspirational quotes from 9 spiritual traditions
- **AI-Generated Quotes**: Unique, AI-generated quotes using Anthropic Claude API with authentic author names
- **AI-Generated Affirmations**: Personalized "I am" affirmations generated from quotes using Claude Haiku
- **AI-Generated Backgrounds**: Beautiful, AI-generated background images using Stability AI (Stable Diffusion)
- **AI-Generated Audio**: Ambient sounds generated using Anthropic Claude TTS with fallback to local audio
- **Glassmorphism UI**: Modern, transparent glass-like quote cards with backdrop blur effects
- **Dynamic Gradient Backgrounds**: 8 beautiful gradient combinations as fallback backgrounds
- **Audio Ambience**: Tradition-specific ambient sounds that play automatically with each quote
- **Session Variety**: Smart logic prevents repeating the same tradition or audio/image variation in a session
- **Favorite Quotes**: Heart button to save and manage your favorite quotes with persistent local storage
- **Quote Sharing**: Share inspirational quotes with others via clipboard
- **Affirmation Notepad**: Save and manage your favorite affirmations in a dedicated notepad
- **Smooth Animations**: Elegant fade and scale animations for quote transitions
- **Hive Database**: Efficient local storage for quotes, images, audio, and affirmations using Hive
- **Smart Fallbacks**: Graceful fallback to gradient backgrounds when AI images aren't available
- **Optimized Loading**: Background prefetching deferred until after first quote for faster startup
- **Pro Features Banner**: Compact preview of upcoming premium features

## 🧘‍♀️ Spiritual Traditions

The app features wisdom quotes from 9 diverse spiritual traditions:

### **Core Traditions:**
- **Buddhist**: Teachings of Buddha on peace, mindfulness, and enlightenment
- **Sufi**: Mystical Islamic wisdom from Rumi and Sufi masters
- **Zen**: Japanese Zen philosophy on simplicity and presence

### **Additional Traditions:**
- **Taoism**: Ancient Chinese wisdom from Lao Tzu on flow and harmony
- **Stoicism**: Roman philosophy on resilience, virtue, and control
- **Hinduism**: Ancient Indian wisdom on spirituality and self-realization
- **Indigenous Wisdom**: Native American proverbs on connection and community
- **Mindful Tech**: Contemporary wisdom on technology and mindfulness
- **Social Justice**: Wisdom on equality, justice, and community empowerment

### **Quote Categories:**
Each tradition includes quotes across multiple categories including:
- Peace, Mindfulness, Truth, Self-Love, Gratitude, Health, Spirituality, Happiness
- Transformation, Destiny, Healing, Hope, Love, Possibility, Joy, Silence
- Flow, Wisdom, Harmony, Simplicity, Balance, Control, Resilience, Virtue
- Connection, Community, Reverence, Consciousness, Stewardship, Mystery, Union

## 🎨 AI-Generated Backgrounds

The app uses **Stability AI (Stable Diffusion)** to generate beautiful, tradition-specific background images:

### **AI Image Features:**
- **Tradition-Specific Prompts**: Each tradition has carefully crafted prompts for relevant imagery
- **High Quality**: 1024x1024 resolution images with artistic quality
- **Smart Caching**: Images are cached locally for instant loading
- **Automatic Storage**: AI images are stored in Hive database for persistence
- **Graceful Fallbacks**: Falls back to beautiful gradient backgrounds when AI isn't available
- **Pre-generation**: 8 unique images per tradition are generated and cached
- **Session Variety**: Ensures different images are shown until all variations are used

### **Background Prompts:**
- **Buddhist**: Peaceful temples with golden hour lighting
- **Sufi**: Mystical desert landscapes with warm sunset colors
- **Zen**: Serene gardens with cherry blossoms and flowing water
- **Taoism**: Harmonious mountain landscapes with mist and waterfalls
- **Stoicism**: Majestic classical architecture with dignified atmosphere
- **Hinduism**: Sacred temples with spiritual energy and vibrant colors
- **Indigenous Wisdom**: Natural landscapes with earth tones and organic forms
- **Mindful Tech**: Modern, clean technology landscapes with peaceful atmosphere
- **Social Justice**: Abstract community unity landscapes with warm colors

## 🎵 Audio Ambience

The app features tradition-specific ambient sounds that enhance the meditation experience:

### **AI-Generated Audio:**
- **Anthropic Claude TTS**: Generates unique ambient sound descriptions for each tradition
- **11 Variations per Tradition**: Multiple audio variations for variety
- **Fallback System**: Falls back to local audio files when AI generation fails
- **Hive Storage**: All AI-generated audio is stored locally for instant playback
- **Session Variety**: Prevents repeating the same audio variation until all are used

### **Tradition-Specific Sounds:**
- **Buddhist**: Meditation bells for spiritual awakening
- **Sufi**: Ney flute for mystical and meditative experiences  
- **Zen**: Calm river flowing sounds for peaceful meditation
- **Other Traditions**: Meditation bells as default ambience

### **Audio Controls:**
- **Auto-Play**: Ambience starts automatically when quotes change
- **Toggle Button**: Tap the volume icon to turn audio on/off
- **30-Second Intervals**: Audio automatically restarts every 30 seconds for continuous meditation
- **Loop Mode**: Sounds play continuously in the background
- **Smart Switching**: Audio changes automatically based on quote tradition

### **Audio Files Included:**
- `meditation_bells.mp3` - Buddhist meditation bells
- `ney-flute.mp3` - Sufi mystical flute
- `calm-zen-river-flowing.mp3` - Zen river ambience

## 💭 AI-Generated Affirmations

The app generates personalized affirmations from quotes using Anthropic Claude Haiku:

### **Affirmation Features:**
- **Personalized Generation**: Creates 1-3 "I am" affirmations based on the current quote
- **Tradition-Aware**: Affirmations reflect the spiritual tradition of the quote
- **First-Person Format**: All affirmations start with "I am" for personal connection
- **Hive Storage**: Affirmations are saved with each quote for persistence
- **Notepad Integration**: Save favorite affirmations to a dedicated notepad
- **Copy to Clipboard**: Easy sharing of affirmations

### **Affirmation Examples:**
- "I am the light that guides my own path through uncertainty"
- "I am present in each moment, embracing the wisdom within"
- "I am connected to the infinite source of peace and understanding"

## 🎨 Dynamic Gradients

The app features 8 carefully crafted gradient combinations as fallback backgrounds:
- **Warm Sunset**: Red to teal to blue
- **Purple Dream**: Purple to pink
- **Pink Passion**: Pink to red to blue  
- **Ocean Breeze**: Blue to cyan to green
- **Golden Hour**: Pink to yellow to red
- **Soft Pastels**: Mint to pink to cream
- **Rose Gold**: Pink to gold
- **Nature Calm**: Green to purple to cream

## 🚀 Pro Features (Coming Soon)

The app includes a compact Pro Features banner showcasing upcoming premium features:

### **Planned Features:**
- **Daily Wisdom Reminders**: Scheduled notifications with inspirational quotes
- **Voice-Narrated Quotes**: AI-generated voice narration for quotes
- **Personal Affirmations**: Enhanced affirmation generation and management
- **Waitlist Signup**: Join the waitlist for early access to Pro features

## 🛠 Requirements

- Flutter 3.32.4 or higher
- Dart 3.8.1 or higher
- macOS 10.15 or higher
- Anthropic API key (optional - for AI-generated quotes, audio, and affirmations)
- Stability AI API key (optional - for AI-generated backgrounds)

## 🚀 Setup Instructions

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd motiai_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment Variables (Optional)

The app works perfectly with beautiful gradient backgrounds even without API keys. If you want AI-generated quotes, images, audio, and affirmations:

#### Create .env file
Create a `.env` file in the `motiai_app` directory:
```bash
ANTHROPIC_API_KEY=your_anthropic_api_key_here
STABILITY_API_KEY=your_stability_ai_api_key_here
```

### 4. Get Your API Keys (Optional)

#### For AI-Generated Quotes, Audio, and Affirmations (Anthropic Claude):
1. Sign up for an account at [console.anthropic.com](https://console.anthropic.com)
2. Navigate to API Keys section
3. Create a new API key
4. Replace `your_anthropic_api_key_here` in the `.env` file with your actual key

#### For AI-Generated Backgrounds (Stability AI):
1. Sign up for an account at [platform.stability.ai](https://platform.stability.ai)
2. Navigate to your API keys section
3. Create a new API key
4. Replace `your_stability_ai_api_key_here` in the `.env` file with your actual key
5. Add credits to your account (images cost ~$0.012 each)

### 5. Run the App
```bash
flutter run -d macos
```

## 🎯 How to Use

### Main Features
- **New Quote**: Tap the blue "New Quote" button to get a random quote with AI-generated background
- **Favorite Quotes**: Tap the heart button to save/unsave quotes (persists across app restarts)
- **Share Quote**: Tap the green share button to copy the quote to clipboard
- **Audio Toggle**: Tap the volume icon to turn ambient audio on/off
- **Generate Affirmations**: Tap the affirmation button to create personalized "I am" affirmations
- **Save Affirmations**: Save affirmations to your personal notepad
- **Notepad**: Access your saved affirmations in the dedicated notepad screen

### AI Features
- **AI Quotes**: When enabled, generates unique quotes with authentic author names
- **AI Backgrounds**: Automatically generates tradition-specific background images
- **AI Audio**: Generates unique ambient sounds for each tradition
- **AI Affirmations**: Creates personalized affirmations from quotes
- **Smart Caching**: AI content is cached for faster loading on subsequent views
- **Automatic Storage**: All AI-generated content is stored locally in Hive database
- **Session Variety**: Ensures different traditions, images, and audio are shown in each session

## 📁 Project Structure

```
motiai_app/
├── lib/
│   ├── screens/
│   │   ├── quote_screen.dart      # Main quote display with glassmorphism UI
│   │   └── notepad_screen.dart    # Affirmation notepad and management
│   ├── services/
│   │   ├── hive_quote_service.dart # Quote management and Hive integration
│   │   ├── image_service.dart     # Stability AI image generation
│   │   ├── audio_service.dart     # Audio ambience management
│   │   ├── ai_audio_service.dart  # AI audio generation with Claude
│   │   ├── affirmation_service.dart # AI affirmation generation
│   │   └── background_prefetch_service.dart # Background content prefetching
│   └── main.dart                  # App entry point with Hive initialization
├── assets/
│   ├── images/                    # Local background images
│   └── audio/                     # Ambient audio files
├── scripts/
│   ├── migrate_standalone.dart    # Command-line migration tool
│   ├── check_hive_data.dart       # Hive database inspector
│   ├── audit_hive_data.dart       # Comprehensive data audit
│   └── refresh_hive_data.dart     # Refresh AI content in Hive
├── bin/
│   └── audit_hive_data.dart       # Standalone audit script
├── .env                           # Environment variables (git-ignored)
└── pubspec.yaml                   # Dependencies
```

## 🔧 Dependencies

- **flutter_dotenv**: Environment variable management
- **http**: API calls to Anthropic Claude and Stability AI
- **hive_flutter**: Local storage for quotes, images, audio, and affirmations
- **audioplayers**: Audio playback for ambient sounds
- **flutter/services**: Clipboard functionality

## 🔒 Security Notes

- The `.env` file is git-ignored to prevent API keys from being committed
- API keys are loaded securely using `flutter_dotenv`
- The app runs in a sandboxed environment on macOS for security
- All data is stored locally using Hive, no external data transmission

## 🐛 Troubleshooting

### App Works Without API Keys
The app is designed to work beautifully even without API keys. You'll see:
- Beautiful dynamic gradient backgrounds
- All quote functionality with curated local quotes
- Favorite quote storage
- Local audio ambience
- Basic affirmation functionality

### API Key Issues

#### Anthropic Claude (for quotes, audio, and affirmations):
- **"Anthropic not configured"**: Add `ANTHROPIC_API_KEY=your_key` to `.env`
- **"Authentication failed"**: Check your API key at [console.anthropic.com](https://console.anthropic.com)
- **"Rate limit exceeded"**: Wait a moment and try again

#### Stability AI (for backgrounds):
- **"Stability AI not configured"**: Add `STABILITY_API_KEY=your_key` to `.env`
- **"Insufficient balance"**: Add credits to your Stability AI account
- **"API key incomplete"**: Ensure your API key is the full length (100+ characters)

### Audio Issues
- **No audio playing**: Check that audio files are in the `assets/audio/` directory
- **Audio not looping**: Audio automatically restarts every 30 seconds
- **AI audio failing**: Falls back to local audio files automatically

### Affirmation Issues
- **"Failed to generate affirmation"**: Check your Anthropic API key in `.env`
- **Affirmations not saving**: Ensure Hive is properly initialized
- **Notepad not working**: Check that the notepad screen is properly imported

### Hive Database Issues
- **Data not persisting**: Hive database is stored in app's sandboxed directory
- **Corrupted data**: Use audit scripts to check database integrity
- **Migration issues**: Use standalone migration scripts for data management

## 🔍 Database Management

### Audit Scripts
The app includes several scripts for managing and auditing the Hive database:

```bash
# Check Hive data counts and structure
dart scripts/check_hive_data.dart

# Comprehensive database audit
dart bin/audit_hive_data.dart

# Refresh AI content in Hive
dart scripts/refresh_hive_data.dart --help

# Simple data migration
dart scripts/migrate_standalone.dart --status
```

### Data Storage
- **Quotes**: Stored in Hive with local and AI-generated quotes
- **Images**: AI-generated images cached as base64 in Hive
- **Audio**: AI-generated audio cached as base64 in Hive
- **Affirmations**: AI-generated affirmations stored with quotes in Hive
- **Favorites**: User's favorite quotes stored in Hive
- **Settings**: App configuration stored in Hive
- **Waitlist**: Pro features waitlist emails stored in Hive

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Stability AI for providing the image generation API
- Anthropic for AI quote, audio, and affirmation generation
- The wisdom traditions for the inspirational quotes
- Hive for efficient local storage
- The Flutter community for excellent tooling and documentation

## 🎉 What's New

### Latest Updates
- **AI Affirmations**: Personalized "I am" affirmations generated from quotes
- **Affirmation Notepad**: Dedicated screen for managing saved affirmations
- **Pro Features Banner**: Compact preview of upcoming premium features
- **Session Variety**: Smart logic prevents repeating traditions, images, and audio
- **Optimized Loading**: Background prefetching deferred for faster startup
- **Compact UI**: Streamlined Pro Features banner with horizontal layout
- **Enhanced Hive Integration**: Comprehensive storage for quotes, images, audio, and affirmations
- **Background Pre-generation**: AI images and audio pre-generated for all traditions
- **Database Audit Tools**: Scripts for inspecting and managing Hive data
- **Improved Fallback System**: Robust fallback to local assets when AI fails
- **Clean UI**: Removed debug elements for a polished user experience

### Recent Improvements
- **Faster Startup**: Background work deferred until after first quote loads
- **Better Variety**: No repeated traditions or content variations in sessions
- **Enhanced Affirmations**: Multiple affirmation generation with copy/save functionality
- **Waitlist System**: Email collection for Pro features early access
- **Improved Error Handling**: Better fallbacks and user feedback
- **Performance Optimization**: Reduced memory usage and faster loading

## 🔧 Data Migration

The app includes a command-line migration tool to copy local assets into Hive storage for better performance and data management.

### Migration Tool Usage

```bash
# Check migration status
dart scripts/migrate_standalone.dart --status

# Prepare for full migration
dart scripts/migrate_standalone.dart --migrate

# Check only images
dart scripts/migrate_standalone.dart --images

# Check only audio files
dart scripts/migrate_standalone.dart --audio

# Show help
dart scripts/migrate_standalone.dart --help
```

### Refresh AI Content

```bash
# Refresh all AI content (quotes, images, audio)
dart scripts/refresh_hive_data.dart --all

# Refresh only images
dart scripts/refresh_hive_data.dart --images

# Refresh only audio
dart scripts/refresh_hive_data.dart --audio

# Refresh only quotes
dart scripts/refresh_hive_data.dart --quotes
```

### What Gets Migrated

- **Local Images**: Background images from `assets/images/` are converted to base64 and stored in Hive
- **Audio Files**: Ambient audio from `assets/audio/` are converted to base64 and stored in Hive
- **AI Images**: Already automatically stored in Hive when generated
- **AI Audio**: Automatically stored in Hive when generated
- **AI Quotes**: Automatically stored in Hive when generated
- **Affirmations**: Automatically stored in Hive when generated

### Migration Benefits

- **Faster Loading**: No need to read from asset files
- **Better Performance**: Direct access from Hive database
- **Consistent Storage**: All data (quotes, images, audio, affirmations) in one place
- **Offline Access**: All assets available even without internet

### Migration Process

1. **Check Status**: Run `dart scripts/migrate_standalone.dart --status` to see what assets are ready
2. **Run App**: Start the Flutter app with `flutter run -d macos`
3. **Perform Migration**: Use the MigrationService within the app to copy assets to Hive
4. **Verify**: Check that all assets are now stored in Hive for faster access
