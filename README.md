# MotiAI - Wisdom Quotes App

A beautiful Flutter macOS app that generates motivational quotes from Buddhist, Sufi, and Zen traditions, featuring dynamic gradient backgrounds and AI-generated images.

## ✨ Features

- **Wisdom Quotes**: Curated collection of inspirational quotes from Buddhism, Sufism, and Zen traditions
- **Dynamic Gradient Backgrounds**: 8 beautiful, vibrant gradient combinations that change dynamically
- **Background Refresh**: Tap the refresh button to cycle through different gradient backgrounds
- **AI-Generated Backgrounds**: Unique, AI-generated background images using DeepAI (when API credits available)
- **Favorite Quotes**: Heart button to save and manage your favorite quotes with persistent local storage
- **Tradition Filtering**: Filter quotes by spiritual tradition (Buddhism, Sufism, Zen)
- **Beautiful UI**: Modern, minimalist design with frosted glass quote cards
- **Quote Sharing**: Share inspirational quotes with others via clipboard
- **Dynamic Sizing**: Quote cards automatically resize to fit content
- **Smooth Animations**: Elegant fade and scale animations for quote transitions

## 🎨 Dynamic Gradients

The app features 8 carefully crafted gradient combinations:
- **Warm Sunset**: Red to teal to blue
- **Purple Dream**: Purple to pink
- **Pink Passion**: Pink to red to blue  
- **Ocean Breeze**: Blue to cyan to green
- **Golden Hour**: Pink to yellow to red
- **Soft Pastels**: Mint to pink to cream
- **Rose Gold**: Pink to gold
- **Nature Calm**: Green to purple to cream

## 📱 Screenshots

*[Screenshots would be added here]*

## 🛠 Requirements

- Flutter 3.32.4 or higher
- Dart 3.8.1 or higher
- macOS 10.15 or higher
- DeepAI API key (optional - app works beautifully with gradients alone)

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

The app works perfectly with beautiful gradient backgrounds even without API keys. If you want AI-generated images:

#### Option A: Using .env file (Recommended)
1. Create a `.env` file in the `motiai_app` directory:
```bash
echo "DEEPAI_API_KEY=your_deepai_api_key_here" > .env
```

2. Copy the `.env` file to the app's sandbox directory:
```bash
cp .env ~/Library/Containers/com.example.motiaiApp/Data/.env
```

#### Option B: Manual Setup
If the above doesn't work, manually copy your `.env` file to:
```
~/Library/Containers/com.example.motiaiApp/Data/.env
```

### 4. Get Your DeepAI API Key (Optional)
1. Sign up for a free account at [DeepAI.org](https://deepai.org)
2. Navigate to your API key section
3. Copy your API key
4. Replace `your_deepai_api_key_here` in the `.env` file with your actual key

### 5. Run the App
```bash
flutter run -d macos
```

## 🎯 How to Use

### Main Features
- **New Quote**: Tap the blue "New Quote" button to get a random quote with a new gradient background
- **Background Refresh**: Tap the small orange refresh button to cycle through different gradient backgrounds for the current quote
- **Tradition Filter**: Tap the purple filter button to choose quotes from specific traditions
- **Favorite Quotes**: Tap the heart button to save/unsave quotes (persists across app restarts)
- **Share Quote**: Tap the green share button to copy the quote to clipboard

### Quote Categories
- **Buddhist**: Wisdom from Buddhist teachings
- **Sufi**: Mystical insights from Sufi tradition  
- **Zen**: Meditative wisdom from Zen philosophy

## 📁 Project Structure

```
motiai_app/
├── lib/
│   ├── screens/
│   │   └── quote_screen.dart      # Main quote display screen with gradients
│   ├── services/
│   │   ├── quote_service.dart     # Quote data and filtering
│   │   └── image_service.dart     # DeepAI image generation with fallbacks
│   └── main.dart                  # App entry point with Hive initialization
├── assets/
│   └── images/                    # Static images (if any)
├── .env                           # Environment variables (git-ignored)
└── pubspec.yaml                   # Dependencies including Hive for storage
```

## 🔧 Dependencies

- **flutter_dotenv**: Environment variable management
- **http**: API calls to DeepAI
- **hive_flutter**: Local storage for favorite quotes
- **flutter/services**: Clipboard functionality

## 🔒 Security Notes

- The `.env` file is git-ignored to prevent API keys from being committed
- API keys are loaded securely using `flutter_dotenv`
- The app runs in a sandboxed environment on macOS for security
- Favorite quotes are stored locally using Hive, no external data transmission

## 🐛 Troubleshooting

### App Works Without API Key
The app is designed to work beautifully even without DeepAI API keys. You'll see:
- Beautiful dynamic gradient backgrounds
- All quote functionality
- Favorite quote storage
- Background refresh with different gradients

### FileNotFoundError for .env
If you see a `FileNotFoundError` when loading the `.env` file:

1. Ensure the `.env` file exists in the `motiai_app` directory
2. Copy it to the sandbox directory:
   ```bash
   cp .env ~/Library/Containers/com.example.motiaiApp/Data/.env
   ```
3. Restart the app

### Permission Errors
If you see "Operation not permitted" errors:
- This is normal for sandboxed macOS apps
- Ensure the `.env` file is in the app's sandbox directory
- The app cannot access files outside its sandbox for security reasons

### Build Issues
If you encounter build issues:
- Ensure you're running from the `motiai_app` directory (not the parent `motiAi` directory)
- Run `flutter clean` and `flutter pub get` if needed
- Check that macOS deployment target is set to 10.15 or higher

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- DeepAI for providing the image generation API
- The wisdom traditions of Buddhism, Sufism, and Zen for the inspirational quotes
- Hive for efficient local storage
- The Flutter community for excellent tooling and documentation

## 🎉 What's New

- **Dynamic Gradient Backgrounds**: 8 beautiful gradient combinations
- **Background Refresh**: Cycle through different gradients with a tap
- **Favorite Quotes**: Save and manage your favorite quotes locally
- **Improved UI**: Frosted glass cards with better animations
- **Graceful Fallbacks**: App works beautifully even without API keys
- **Better Error Handling**: No more gray backgrounds!
