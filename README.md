# MotiAI - Wisdom Quotes App

A beautiful Flutter macOS app that displays motivational quotes from Buddhist, Sufi, Zen, and other spiritual traditions with AI-generated background images and ambient audio.

## ✨ Features

- **Wisdom Quotes**: Curated collection of inspirational quotes from 9 spiritual traditions
- **AI-Generated Quotes**: Unique, AI-generated quotes using Anthropic Claude API with authentic author names
- **AI-Generated Backgrounds**: Beautiful, AI-generated background images using Stability AI (Stable Diffusion)
- **Glassmorphism UI**: Modern, transparent glass-like quote cards with backdrop blur effects
- **Dynamic Gradient Backgrounds**: 8 beautiful gradient combinations as fallback backgrounds
- **Audio Ambience**: Tradition-specific ambient sounds that play automatically with each quote
- **Favorite Quotes**: Heart button to save and manage your favorite quotes with persistent local storage
- **Quote Sharing**: Share inspirational quotes with others via clipboard
- **Smooth Animations**: Elegant fade and scale animations for quote transitions
- **AI Image Caching**: AI-generated images are cached locally for faster loading
- **Smart Fallbacks**: Graceful fallback to gradient backgrounds when AI images aren't available

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

## 🛠 Requirements

- Flutter 3.32.4 or higher
- Dart 3.8.1 or higher
- macOS 10.15 or higher
- Anthropic API key (optional - for AI-generated quotes)
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

The app works perfectly with beautiful gradient backgrounds even without API keys. If you want AI-generated quotes and images:

#### Create .env file
Create a `.env` file in the `motiai_app` directory:
```bash
ANTHROPIC_API_KEY=your_anthropic_api_key_here
STABILITY_API_KEY=your_stability_ai_api_key_here
```

### 4. Get Your API Keys (Optional)

#### For AI-Generated Quotes (Anthropic Claude):
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

### AI Features
- **AI Quotes**: When enabled, generates unique quotes with authentic author names
- **AI Backgrounds**: Automatically generates tradition-specific background images
- **Smart Caching**: AI images are cached for faster loading on subsequent views
- **Automatic Storage**: All AI-generated content is stored locally in Hive database

## 📁 Project Structure

```
motiai_app/
├── lib/
│   ├── screens/
│   │   └── quote_screen.dart      # Main quote display with glassmorphism UI
│   ├── services/
│   │   ├── hive_quote_service.dart # Quote management and AI integration
│   │   ├── image_service.dart     # Stability AI image generation
│   │   └── audio_service.dart     # Audio ambience management
│   └── main.dart                  # App entry point with Hive initialization
├── assets/
│   └── audio/                     # Ambient audio files
├── .env                           # Environment variables (git-ignored)
└── pubspec.yaml                   # Dependencies
```

## 🔧 Dependencies

- **flutter_dotenv**: Environment variable management
- **http**: API calls to Anthropic Claude and Stability AI
- **hive_flutter**: Local storage for quotes and images
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
- Audio ambience

### API Key Issues

#### Anthropic Claude (for quotes):
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
- Anthropic for AI quote generation
- The wisdom traditions for the inspirational quotes
- Hive for efficient local storage
- The Flutter community for excellent tooling and documentation

## 🎉 What's New

- **Stability AI Integration**: High-quality AI-generated background images
- **Glassmorphism UI**: Modern, transparent glass-like quote cards
- **AI Image Caching**: Faster loading with local image storage
- **Enhanced Audio**: Tradition-specific ambient sounds
- **Authentic Authors**: AI quotes now use real author names
- **Improved Animations**: Smooth transitions and effects
- **Better Error Handling**: Graceful fallbacks for all features
