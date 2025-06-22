import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import '../lib/services/firebase_service.dart';
import '../lib/services/quote_service.dart';
import '../lib/models/quote.dart';

Future<void> main() async {
  print('🚀 Starting Firebase population script...');
  
  try {
    // Initialize Firebase
    await FirebaseService.initialize();
    print('✅ Firebase initialized successfully');
    
    // Get all quotes from local service
    final localQuotes = QuoteService.getAllQuotes();
    print('📚 Found ${localQuotes.length} quotes in local service');
    
    // Add quotes to Firebase
    int addedCount = 0;
    for (final quote in localQuotes) {
      try {
        await FirebaseService.addQuote(quote);
        addedCount++;
        print('✅ Added quote: "${quote.text.substring(0, quote.text.length > 50 ? 50 : quote.text.length)}..."');
      } catch (e) {
        print('❌ Failed to add quote: $e');
      }
    }
    
    print('\n🎉 Successfully added $addedCount quotes to Firebase!');
    print('📊 Total quotes in Firebase: ${await FirebaseService.getAllQuotes().then((quotes) => quotes.length)}');
    
  } catch (e) {
    print('❌ Error: $e');
    print('\n📝 Make sure you have:');
    print('1. Created a Firebase project');
    print('2. Downloaded GoogleService-Info.plist and placed it in macos/Runner/');
    print('3. Updated the configuration with your actual Firebase project details');
  }
} 