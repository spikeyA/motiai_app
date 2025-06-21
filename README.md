# MotiAI - Wisdom Quotes App

A beautiful Flutter macOS app that generates motivational quotes from Buddhist, Sufi, and Zen traditions, featuring AI-generated background images for each quote.

## Features

- **Wisdom Quotes**: Curated collection of inspirational quotes from Buddhism, Sufism, and Zen traditions
- **AI-Generated Backgrounds**: Unique, AI-generated background images for each quote using DeepAI
- **Tradition Filtering**: Filter quotes by spiritual tradition (Buddhism, Sufism, Zen)
- **Beautiful UI**: Modern, minimalist design with floating text over AI-generated backgrounds
- **Quote Sharing**: Share inspirational quotes with others
- **Dynamic Sizing**: Quote cards automatically resize to fit content

## Requirements

- Flutter 3.32.4 or higher
- Dart 3.8.1 or higher
- macOS 10.15 or higher
- DeepAI API key (free account at [DeepAI.org](https://deepai.org))

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd motiai_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment Variables

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

### 4. Get Your DeepAI API Key
1. Sign up for a free account at [DeepAI.org](https://deepai.org)
2. Navigate to your API key section
3. Copy your API key
4. Replace `your_deepai_api_key_here` in the `.env` file with your actual key

### 5. Run the App
```bash
flutter run -d macos
```

## Project Structure

```
motiai_app/
├── lib/
│   ├── screens/
│   │   └── quote_screen.dart      # Main quote display screen
│   ├── services/
│   │   ├── quote_service.dart     # Quote data and filtering
│   │   └── image_service.dart     # DeepAI image generation
│   └── main.dart                  # App entry point
├── assets/
│   └── images/                    # Static images (if any)
├── .env                           # Environment variables (git-ignored)
└── pubspec.yaml                   # Dependencies
```

## Environment Variables

The app uses the following environment variables:

- `DEEPAI_API_KEY`: Your DeepAI API key for generating background images

## Security Notes

- The `.env` file is git-ignored to prevent API keys from being committed
- API keys are loaded securely using `flutter_dotenv`
- The app runs in a sandboxed environment on macOS for security

## Troubleshooting

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

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- DeepAI for providing the image generation API
- The wisdom traditions of Buddhism, Sufism, and Zen for the inspirational quotes
