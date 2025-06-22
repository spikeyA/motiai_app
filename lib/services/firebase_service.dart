import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/quote.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  static const String _quotesCollection = 'quotes';
  static const String _favoritesCollection = 'favorites';
  static const String _usersCollection = 'users';

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // Get all quotes
  static Future<List<Quote>> getAllQuotes() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_quotesCollection)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Quote(
          id: doc.id,
          text: data['text'] ?? '',
          author: data['author'] ?? '',
          tradition: data['tradition'] ?? '',
          category: data['category'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching quotes: $e');
      return [];
    }
  }

  // Get quotes by tradition
  static Future<List<Quote>> getQuotesByTradition(String tradition) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_quotesCollection)
          .where('tradition', isEqualTo: tradition)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Quote(
          id: doc.id,
          text: data['text'] ?? '',
          author: data['author'] ?? '',
          tradition: data['tradition'] ?? '',
          category: data['category'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching quotes by tradition: $e');
      return [];
    }
  }

  // Get random quote
  static Future<Quote?> getRandomQuote() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_quotesCollection)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return Quote(
          id: doc.id,
          text: data['text'] ?? '',
          author: data['author'] ?? '',
          tradition: data['tradition'] ?? '',
          category: data['category'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error fetching random quote: $e');
      return null;
    }
  }

  // Get random quote by tradition
  static Future<Quote?> getRandomQuoteByTradition(String tradition) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_quotesCollection)
          .where('tradition', isEqualTo: tradition)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return Quote(
          id: doc.id,
          text: data['text'] ?? '',
          author: data['author'] ?? '',
          tradition: data['tradition'] ?? '',
          category: data['category'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error fetching random quote by tradition: $e');
      return null;
    }
  }

  // Add quote to favorites
  static Future<void> addToFavorites(String userId, String quoteId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_favoritesCollection)
          .doc(quoteId)
          .set({
        'quoteId': quoteId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  // Remove quote from favorites
  static Future<void> removeFromFavorites(String userId, String quoteId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_favoritesCollection)
          .doc(quoteId)
          .delete();
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  // Get user favorites
  static Future<List<String>> getUserFavorites(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_favoritesCollection)
          .get();
      
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching user favorites: $e');
      return [];
    }
  }

  // Check if quote is favorited
  static Future<bool> isFavorited(String userId, String quoteId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_favoritesCollection)
          .doc(quoteId)
          .get();
      
      return doc.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Get favorite quotes
  static Future<List<Quote>> getFavoriteQuotes(String userId) async {
    try {
      final favoriteIds = await getUserFavorites(userId);
      if (favoriteIds.isEmpty) return [];

      final List<Quote> favoriteQuotes = [];
      
      for (String quoteId in favoriteIds) {
        final doc = await _firestore
            .collection(_quotesCollection)
            .doc(quoteId)
            .get();
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          favoriteQuotes.add(Quote(
            id: doc.id,
            text: data['text'] ?? '',
            author: data['author'] ?? '',
            tradition: data['tradition'] ?? '',
            category: data['category'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
          ));
        }
      }
      
      return favoriteQuotes;
    } catch (e) {
      print('Error fetching favorite quotes: $e');
      return [];
    }
  }

  // Add quote to database (for admin use)
  static Future<void> addQuote(Quote quote) async {
    try {
      await _firestore.collection(_quotesCollection).add({
        'text': quote.text,
        'author': quote.author,
        'tradition': quote.tradition,
        'category': quote.category,
        'imageUrl': quote.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding quote: $e');
    }
  }

  // Update quote in database
  static Future<void> updateQuote(Quote quote) async {
    try {
      await _firestore.collection(_quotesCollection).doc(quote.id).update({
        'text': quote.text,
        'author': quote.author,
        'tradition': quote.tradition,
        'category': quote.category,
        'imageUrl': quote.imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating quote: $e');
    }
  }

  // Delete quote from database
  static Future<void> deleteQuote(String quoteId) async {
    try {
      await _firestore.collection(_quotesCollection).doc(quoteId).delete();
    } catch (e) {
      print('Error deleting quote: $e');
    }
  }
} 