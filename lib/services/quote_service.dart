import '../models/quote.dart';

// Interface for quote services
abstract class QuoteService {
  Future<List<Quote>> getAllQuotes();
  Future<void> addQuote(Quote quote);
  Future<void> removeQuote(String id);
  Future<void> updateQuote(Quote quote);
  Future<List<Quote>> getFavoriteQuotes();
  Future<void> addFavorite(String id);
  Future<void> removeFavorite(String id);
  Future<bool> isFavorite(String id);
  Future<Quote> getRandomQuote({String? category, String? tradition}) async {
    print('[QuoteService] Fetching RANDOM quote from LOCAL');
    List<Quote> allQuotes = await getAllQuotes();
    if (allQuotes.isEmpty) {
      throw Exception('No quotes found');
    }
    List<Quote> filteredQuotes = allQuotes;
    if (tradition != null) {
      filteredQuotes = filteredQuotes.where((q) => q.tradition.toLowerCase() == tradition.toLowerCase()).toList();
    }
    if (category != null) {
      filteredQuotes = filteredQuotes.where((q) => q.category.toLowerCase() == category.toLowerCase()).toList();
    }
    if (filteredQuotes.isEmpty) {
      filteredQuotes = allQuotes;
    }
    filteredQuotes.shuffle();
    return filteredQuotes.first;
  }
}

// Static helper class for backward compatibility
class QuoteServiceHelper {
  static final Map<String, String> _traditionImages = {
    'Buddhist': 'assets/images/buddhist.jpg',
    'Sufi': 'assets/images/sufi.jpg',
    'Zen': 'assets/images/zen.jpg',
    'Taoism': 'assets/images/taoism.jpg',
    'Stoicism': 'assets/images/stoicism.jpg',
    'Indigenous Wisdom': 'assets/images/indigenous.jpg',
    'Mindful Tech': 'assets/images/tech.jpg',
    'Eco-Spirituality': 'assets/images/eco.jpg',
    'Poetic Sufism': 'assets/images/poetic_sufi.jpg',
  };

  static List<String> getTraditions() {
    return _traditionImages.keys.toList();
  }

  static String getTraditionImage(String tradition) {
    return _traditionImages[tradition] ?? 'assets/images/default.jpg';
  }
} 