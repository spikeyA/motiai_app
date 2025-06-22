# Firebase Setup for MotiAI

This guide will help you set up Firebase for your MotiAI app to enable cloud database functionality.

## Prerequisites

1. A Google account
2. Flutter development environment set up
3. Your MotiAI app running locally

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name (e.g., "motiai-app")
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add macOS App to Firebase

1. In your Firebase project console, click the gear icon ⚙️ next to "Project Overview"
2. Select "Project settings"
3. Scroll down to "Your apps" section
4. Click the macOS icon (🍎) to add a macOS app
5. Enter your app's bundle ID: `com.example.motiaiApp`
6. Enter app nickname: "MotiAI"
7. Click "Register app"

## Step 3: Download Configuration File

1. After registering the app, download the `GoogleService-Info.plist` file
2. Replace the existing file in `macos/Runner/GoogleService-Info.plist` with the downloaded file
3. Make sure the file is added to your Xcode project

## Step 4: Enable Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location closest to your users
5. Click "Done"

## Step 5: Set Up Firestore Security Rules

1. In Firestore Database, go to "Rules" tab
2. Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to quotes collection
    match /quotes/{document} {
      allow read: if true;
      allow write: if false; // Only allow admin writes
    }
    
    // Allow users to manage their own favorites
    match /users/{userId}/favorites/{document} {
      allow read, write: if true; // For now, allow all access
    }
  }
}
```

## Step 6: Populate Database with Quotes

1. Make sure your Firebase configuration is correct
2. Run the population script:

```bash
cd motiai_app
dart run scripts/populate_firebase.dart
```

This will copy all your local quotes to Firebase.

## Step 7: Test the App

1. Run your app: `flutter run -d macos`
2. The app will now use Firebase as the primary database
3. If Firebase is unavailable, it will automatically fall back to local storage

## Database Structure

The Firebase database will have the following structure:

```
firestore/
├── quotes/
│   ├── [quote_id]/
│   │   ├── text: "Quote text"
│   │   ├── author: "Author name"
│   │   ├── tradition: "Buddhist"
│   │   ├── category: "Wisdom"
│   │   ├── imageUrl: "image_url"
│   │   └── createdAt: timestamp
│   └── ...
└── users/
    └── [user_id]/
        └── favorites/
            └── [quote_id]/
                ├── quoteId: "quote_id"
                └── addedAt: timestamp
```

## Features Enabled

With Firebase integration, your app now supports:

- ✅ **Cloud Database**: All quotes stored in Firebase Firestore
- ✅ **User Favorites**: Favorites synced across devices
- ✅ **Offline Support**: Local fallback when Firebase is unavailable
- ✅ **Real-time Updates**: Changes sync automatically
- ✅ **Scalability**: Can handle thousands of quotes and users

## Troubleshooting

### Firebase Initialization Failed
- Check that `GoogleService-Info.plist` is in the correct location
- Verify your bundle ID matches the Firebase project
- Ensure you have internet connectivity

### Quotes Not Loading
- Check Firestore security rules
- Verify the database is created and accessible
- Check console logs for specific error messages

### Favorites Not Syncing
- Ensure the user collection is accessible
- Check that the user ID is being generated correctly
- Verify write permissions in security rules

## Next Steps

1. **Authentication**: Add Firebase Auth for user login
2. **Analytics**: Enable Firebase Analytics for usage insights
3. **Storage**: Use Firebase Storage for background images
4. **Functions**: Add Cloud Functions for advanced features

## Support

If you encounter issues:
1. Check the Firebase Console for error logs
2. Review the Flutter Firebase documentation
3. Check the app console output for detailed error messages

The app is designed to gracefully fall back to local storage if Firebase is unavailable, so your app will continue to work even if there are connectivity issues. 