import 'package:hive_flutter/hive_flutter.dart';
import '../models/quote.dart';
import 'firebase_service.dart';
import 'quote_service.dart';

class HybridQuoteService {
  static const String _favoritesBoxName = 'favorites';
  static const String _quotesBoxName = 'quotes_cache';
  
  // Use Firebase as primary, fallback to local
  static bool _useFirebase = true;
  static bool _firebaseInitialized = false;

  // Initialize the service
  static Future<void> initialize() async {
    try {
      await FirebaseService.initialize();
      _firebaseInitialized = true;
      _useFirebase = true;
    } catch (e) {
      print('Firebase initialization failed, using local storage: $e');
      _useFirebase = false;
      _firebaseInitialized = false;
    }
  }

  // Get all quotes
  static Future<List<Quote>> getAllQuotes() async {
    if (_useFirebase && _firebaseInitialized) {
      try {
        final quotes = await FirebaseService.getAllQuotes();
        if (quotes.isNotEmpty) {
          // Cache quotes locally
          await _cacheQuotes(quotes);
          return quotes;
        }
      } catch (e) {
        print('Firebase failed, falling back to local: $e');
        _useFirebase = false;
      }
    }
    
    // Fallback to local quotes
    return QuoteService.getAllQuotes();
  }

  // Get quotes by tradition
  static Future<List<Quote>> getQuotesByTradition(String tradition) async {
    if (_useFirebase && _firebaseInitialized) {
      try {
        final quotes = await FirebaseService.getQuotesByTradition(tradition);
        if (quotes.isNotEmpty) {
          return quotes;
        }
      } catch (e) {
        print('Firebase failed, falling back to local: $e');
        _useFirebase = false;
      }
    }
    
    // Fallback to local quotes
    return QuoteService.getQuotesByTradition(tradition);
  }

  // Get random quote
  static Future<Quote?> getRandomQuote() async {
    if (_useFirebase && _firebaseInitialized) {
      try {
        final quote = await FirebaseService.getRandomQuote();
        if (quote != null) {
          return quote;
        }
      } catch (e) {
        print('Firebase failed, falling back to local: $e');
        _useFirebase = false;
      }
    }
    
    // Fallback to local quotes
    return QuoteService.getRandomQuote();
  }

  // Get random quote by tradition
  static Future<Quote?> getRandomQuoteByTradition(String tradition) async {
    if (_useFirebase && _firebaseInitialized) {
      try {
        final quote = await FirebaseService.getRandomQuoteByTradition(tradition);
        if (quote != null) {
          return quote;
        }
      } catch (e) {
        print('Firebase failed, falling back to local: $e');
        _useFirebase = false;
      }
    }
    
    // Fallback to local quotes
    return QuoteService.getRandomQuoteByTradition(tradition);
  }

  // Get traditions
  static List<String> getTraditions() {
    return QuoteService.getTraditions();
  }

  // Toggle favorite
  static Future<void> toggleFavorite(Quote quote) async {
    final userId = _getUserId();
    
    if (_useFirebase && _firebaseInitialized) {
      try {
        final isFavorited = await FirebaseService.isFavorited(userId, quote.id);
        if (isFavorited) {
          await FirebaseService.removeFromFavorites(userId, quote.id);
        } else {
          await FirebaseService.addToFavorites(userId, quote.id);
        }
      } catch (e) {
        print('Firebase failed, falling back to local: $e');
        _useFirebase = false;
      }
    }
    
    // Always update local storage as backup
    final box = Hive.box(_favoritesBoxName);
    final isFavorited = box.get(quote.id) ?? false;
    await box.put(quote.id, !isFavorited);
  }

  // Check if quote is favorited
  static Future<bool> isFavorited(Quote quote) async {
    final userId = _getUserId();
    
    if (_useFirebase && _firebaseInitialized) {
      try {
        return await FirebaseService.isFavorited(userId, quote.id);
      } catch (e) {
        print('Firebase failed, falling back to local: $e');
        _useFirebase = false;
      }
    }
    
    // Fallback to local storage
    final box = Hive.box(_favoritesBoxName);
    return box.get(quote.id) ?? false;
  }

  // Get favorite quotes
  static Future<List<Quote>> getFavoriteQuotes() async {
    final userId = _getUserId();
    
    if (_useFirebase && _firebaseInitialized) {
      try {
        return await FirebaseService.getFavoriteQuotes(userId);
      } catch (e) {
        print('Firebase failed, falling back to local: $e');
        _useFirebase = false;
      }
    }
    
    // Fallback to local storage
    final box = Hive.box(_favoritesBoxName);
    final favoriteIds = box.keys.where((key) => box.get(key) == true).cast<String>();
    
    final allQuotes = await getAllQuotes();
    return allQuotes.where((quote) => favoriteIds.contains(quote.id)).toList();
  }

  // Cache quotes locally
  static Future<void> _cacheQuotes(List<Quote> quotes) async {
    try {
      final box = Hive.box(_quotesBoxName);
      for (final quote in quotes) {
        await box.put(quote.id, {
          'text': quote.text,
          'author': quote.author,
          'tradition': quote.tradition,
          'category': quote.category,
          'imageUrl': quote.imageUrl,
        });
      }
    } catch (e) {
      print('Error caching quotes: $e');
    }
  }

  // Get cached quotes
  static Future<List<Quote>> _getCachedQuotes() async {
    try {
      final box = Hive.box(_quotesBoxName);
      final List<Quote> quotes = [];
      
      for (final key in box.keys) {
        final data = box.get(key) as Map<String, dynamic>;
        quotes.add(Quote(
          id: key.toString(),
          text: data['text'] ?? '',
          author: data['author'] ?? '',
          tradition: data['tradition'] ?? '',
          category: data['category'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        ));
      }
      
      return quotes;
    } catch (e) {
      print('Error getting cached quotes: $e');
      return [];
    }
  }

  // Get user ID (for now, using a simple identifier)
  static String _getUserId() {
    // In a real app, you'd get this from Firebase Auth
    // For now, using a simple identifier
    return 'default_user';
  }

  // Sync local favorites to Firebase
  static Future<void> syncFavoritesToFirebase() async {
    if (!_useFirebase || !_firebaseInitialized) return;
    
    try {
      final userId = _getUserId();
      final box = Hive.box(_favoritesBoxName);
      final localFavorites = box.keys.where((key) => box.get(key) == true).cast<String>();
      
      for (final quoteId in localFavorites) {
        final isInFirebase = await FirebaseService.isFavorited(userId, quoteId);
        if (!isInFirebase) {
          await FirebaseService.addToFavorites(userId, quoteId);
        }
      }
    } catch (e) {
      print('Error syncing favorites to Firebase: $e');
    }
  }

  // Check Firebase connection
  static bool get isFirebaseAvailable => _useFirebase && _firebaseInitialized;
} 