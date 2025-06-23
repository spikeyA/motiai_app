import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/quote.dart';
import 'quote_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HiveQuoteService implements QuoteService {
  static const String _quotesBoxName = 'quotes';
  static const String _favoritesBoxName = 'favorites';
  static const String _settingsBoxName = 'settings';
  static const String _cachedImagesBoxName = 'cached_images';
  
  late Box<dynamic> _quotesBox;
  late Box<dynamic> _favoritesBox;
  late Box<dynamic> _settingsBox;
  late Box<dynamic> _cachedImagesBox;
  
  static HiveQuoteService? _instance;
  
  HiveQuoteService._();
  
  static HiveQuoteService get instance {
    _instance ??= HiveQuoteService._();
    return _instance!;
  }
  
  static Future<void> initialize() async {
    print('[HiveQuoteService] Initializing Hive...');
    
    // Initialize Hive boxes
    instance._quotesBox = await Hive.openBox(_quotesBoxName);
    instance._favoritesBox = await Hive.openBox(_favoritesBoxName);
    instance._settingsBox = await Hive.openBox(_settingsBoxName);
    instance._cachedImagesBox = await Hive.openBox(_cachedImagesBoxName);
    
    // One-time migration to handle switch from Map to TypeAdapter
    if (instance._quotesBox.isNotEmpty && instance._quotesBox.getAt(0) is Map) {
      print('[HiveQuoteService] Old data format found. Clearing quotes box for migration...');
      await instance._quotesBox.clear();
      print('[HiveQuoteService] Quotes box cleared.');
    }
    
    // Load initial quotes if empty
    if (instance._quotesBox.isEmpty) {
      print('[HiveQuoteService] Loading initial quotes...');
      await instance._loadInitialQuotes();
    }
    
    print('[HiveQuoteService] Hive initialized successfully');
  }
  
  /// Fetch a quote from DeepAI's text generator API
  static Future<Quote?> fetchQuoteFromDeepAI() async {
    final apiKey = dotenv.env['DEEPAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('[DeepAI] No API key found for quote generation.');
      return null;
    }
    final prompt = "Give me a short motivational quote from a spiritual tradition.";
    try {
      final response = await http.post(
        Uri.parse('https://api.deepai.org/api/text-generator'),
        headers: {'api-key': apiKey},
        body: {'text': prompt},
      );
      print('[DeepAI] Quote API status: \\${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['output']?.toString().trim();
        if (text != null && text.isNotEmpty) {
          return Quote(
            id: 'ai_\\${DateTime.now().millisecondsSinceEpoch}',
            text: text,
            author: 'AI',
            tradition: 'AI',
            category: 'Motivation',
            imageUrl: '',
          );
        }
      } else {
        print('[DeepAI] Quote API error: \\${response.body}');
      }
    } catch (e) {
      print('[DeepAI] Quote API exception: \\${e.toString()}');
    }
    return null;
  }
  
  /// Try DeepAI first, fallback to Hive/local
  @override
  Future<Quote> getRandomQuote({String? category, String? tradition}) async {
    print('[HiveQuoteService] Getting random quote (category: $category, tradition: $tradition)');
    // 1. Try DeepAI
    final aiQuote = await fetchQuoteFromDeepAI();
    if (aiQuote != null) {
      print('[HiveQuoteService] Using AI-generated quote: "${aiQuote.text}"');
      return aiQuote;
    }
    // 2. Fallback to Hive/local
    print('[HiveQuoteService] Falling back to local quote.');
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
  
  @override
  Future<List<Quote>> getAllQuotes() async {
    print('[HiveQuoteService] Getting all quotes...');
    return _quotesBox.values.cast<Quote>().toList();
  }
  
  @override
  Future<void> addQuote(Quote quote) async {
    print('[HiveQuoteService] Adding quote: ${quote.id}');
    await _quotesBox.put(quote.id, quote);
  }
  
  @override
  Future<void> removeQuote(String id) async {
    print('[HiveQuoteService] Removing quote: $id');
    await _quotesBox.delete(id);
    // Also remove from favorites if present
    await _favoritesBox.delete(id);
  }
  
  @override
  Future<List<String>> getFavorites() async {
    print('[HiveQuoteService] Getting favorites...');
    
    List<String> favorites = [];
    for (var key in _favoritesBox.keys) {
      if (_favoritesBox.get(key) == true) {
        favorites.add(key.toString());
      }
    }
    
    print('[HiveQuoteService] Found ${favorites.length} favorites');
    return favorites;
  }
  
  @override
  Future<void> addFavorite(String id) async {
    await _favoritesBox.put(id, true);
  }
  
  @override
  Future<void> removeFavorite(String id) async {
    await _favoritesBox.delete(id);
  }
  
  @override
  Future<void> updateQuote(Quote quote) async {
    await _quotesBox.put(quote.id, quote);
  }
  
  // Additional methods for enhanced functionality
  
  Future<List<Quote>> getFavoriteQuotes() async {
    List<String> favoriteIds = await getFavorites();
    List<Quote> allQuotes = await getAllQuotes();
    
    return allQuotes.where((quote) => favoriteIds.contains(quote.id)).toList();
  }
  
  Future<bool> isFavorite(String quoteId) async {
    return _favoritesBox.get(quoteId) == true;
  }
  
  Future<void> toggleFavorite(String quoteId) async {
    bool isFav = await isFavorite(quoteId);
    if (isFav) {
      await removeFavorite(quoteId);
    } else {
      await addFavorite(quoteId);
    }
  }
  
  Future<void> cacheImageUrl(String quoteId, String imageUrl) async {
    await _cachedImagesBox.put(quoteId, imageUrl);
  }
  
  String? getCachedImageUrl(String quoteId) {
    return _cachedImagesBox.get(quoteId);
  }
  
  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }
  
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }
  
  // Load initial quotes from hardcoded data
  Future<void> _loadInitialQuotes() async {
    print('[HiveQuoteService] Loading initial quotes from hardcoded data...');
    
    List<Quote> initialQuotes = [
      Quote(
        id: 'zen_obstacles',
        text: 'The obstacle is the path.',
        author: 'Zen Proverb',
        tradition: 'Zen',
        category: 'Obstacles',
        imageUrl: '',
      ),
      Quote(
        id: 'zen_enlightenment',
        text: 'Before enlightenment, chop wood, carry water. After enlightenment, chop wood, carry water.',
        author: 'Zen Proverb',
        tradition: 'Zen',
        category: 'Enlightenment',
        imageUrl: '',
      ),
      Quote(
        id: 'zen_present',
        text: 'The only moment that matters is now.',
        author: 'Thich Nhat Hanh',
        tradition: 'Zen',
        category: 'Present Moment',
        imageUrl: '',
      ),
      Quote(
        id: 'sufi_love',
        text: 'The wound is the place where the Light enters you.',
        author: 'Rumi',
        tradition: 'Sufi',
        category: 'Love',
        imageUrl: '',
      ),
      Quote(
        id: 'sufi_possibility',
        text: 'What you seek is seeking you.',
        author: 'Rumi',
        tradition: 'Sufi',
        category: 'Possibility',
        imageUrl: '',
      ),
      Quote(
        id: 'sufi_destiny',
        text: 'Yesterday I was clever, so I wanted to change the world. Today I am wise, so I am changing myself.',
        author: 'Rumi',
        tradition: 'Sufi',
        category: 'Destiny',
        imageUrl: '',
      ),
      Quote(
        id: 'buddhist_self_love',
        text: 'You yourself, as much as anybody in the entire universe, deserve your love and affection.',
        author: 'Buddha',
        tradition: 'Buddhist',
        category: 'Self-Love',
        imageUrl: '',
      ),
      Quote(
        id: 'buddhist_compassion',
        text: 'If you want others to be happy, practice compassion. If you want to be happy, practice compassion.',
        author: 'Dalai Lama',
        tradition: 'Buddhist',
        category: 'Compassion',
        imageUrl: '',
      ),
      Quote(
        id: 'poetic_sufi_mystery',
        text: 'The wound is the place where the Light enters you.',
        author: 'Rumi',
        tradition: 'Poetic Sufism',
        category: 'Mystery',
        imageUrl: '',
      ),
      Quote(
        id: 'zen_learning',
        text: 'In the beginner\'s mind there are many possibilities, but in the expert\'s there are few.',
        author: 'Shunryu Suzuki',
        tradition: 'Zen',
        category: 'Learning',
        imageUrl: '',
      ),
      Quote(
        id: 'eco_consciousness',
        text: 'The environment is where we all meet; where we all have a mutual interest; it is the one thing all of us share.',
        author: 'Lady Bird Johnson',
        tradition: 'Eco-Spirituality',
        category: 'Consciousness',
        imageUrl: '',
      ),
      Quote(
        id: 'taoism_flow',
        text: 'Nature does not hurry, yet everything is accomplished.',
        author: 'Lao Tzu',
        tradition: 'Taoism',
        category: 'Flow',
        imageUrl: '',
      ),
      Quote(
        id: 'stoicism_control',
        text: 'You have power over your mind – not outside events. Realize this, and you will find strength.',
        author: 'Marcus Aurelius',
        tradition: 'Stoicism',
        category: 'Control',
        imageUrl: '',
      ),
      Quote(
        id: 'indigenous_gratitude',
        text: 'Give thanks for unknown blessings already on their way.',
        author: 'Native American Proverb',
        tradition: 'Indigenous Wisdom',
        category: 'Gratitude',
        imageUrl: '',
      ),
      Quote(
        id: 'mindful_tech_presence',
        text: 'Almost everything will work again if you unplug it for a few minutes, including you.',
        author: 'Anne Lamott',
        tradition: 'Mindful Tech',
        category: 'Presence',
        imageUrl: '',
      ),
      Quote(
        id: 'buddhist_peace',
        text: 'Peace comes from within. Do not seek it without.',
        author: 'Buddha',
        tradition: 'Buddhist',
        category: 'Peace',
        imageUrl: '',
      ),
      Quote(
        id: 'zen_simplicity',
        text: 'Simplicity is the ultimate sophistication.',
        author: 'Leonardo da Vinci',
        tradition: 'Zen',
        category: 'Simplicity',
        imageUrl: '',
      ),
      Quote(
        id: 'sufi_heart',
        text: 'Let yourself be silently drawn by the strange pull of what you really love. It will not lead you astray.',
        author: 'Rumi',
        tradition: 'Sufi',
        category: 'Heart',
        imageUrl: '',
      ),
      Quote(
        id: 'eco_interbeing',
        text: 'We are here to awaken from our illusion of separateness.',
        author: 'Thich Nhat Hanh',
        tradition: 'Eco-Spirituality',
        category: 'Interbeing',
        imageUrl: '',
      ),
      Quote(
        id: 'stoicism_obstacle',
        text: 'The impediment to action advances action. What stands in the way becomes the way.',
        author: 'Marcus Aurelius',
        tradition: 'Stoicism',
        category: 'Obstacles',
        imageUrl: '',
      ),
      Quote(
        id: 'taoism_acceptance',
        text: 'When I let go of what I am, I become what I might be.',
        author: 'Lao Tzu',
        tradition: 'Taoism',
        category: 'Acceptance',
        imageUrl: '',
      ),
      Quote(
        id: 'buddhist_beginner',
        text: 'Each morning we are born again. What we do today is what matters most.',
        author: 'Buddha',
        tradition: 'Buddhist',
        category: "Beginner's Mind",
        imageUrl: '',
      ),
    ];
    
    for (Quote quote in initialQuotes) {
      await addQuote(quote);
    }
    
    print('[HiveQuoteService] Loaded ${initialQuotes.length} initial quotes');
  }
  
  // Export/Import functionality
  Future<String> exportData() async {
    Map<String, dynamic> exportData = {
      'quotes': _quotesBox.toMap(),
      'favorites': _favoritesBox.toMap(),
      'settings': _settingsBox.toMap(),
      'cached_images': _cachedImagesBox.toMap(),
    };
    
    return jsonEncode(exportData);
  }
  
  Future<void> importData(String jsonData) async {
    Map<String, dynamic> importData = jsonDecode(jsonData);
    
    await _quotesBox.clear();
    await _favoritesBox.clear();
    await _settingsBox.clear();
    await _cachedImagesBox.clear();
    
    for (var entry in importData['quotes'].entries) {
      await _quotesBox.put(entry.key, entry.value);
    }
    
    for (var entry in importData['favorites'].entries) {
      await _favoritesBox.put(entry.key, entry.value);
    }
    
    for (var entry in importData['settings'].entries) {
      await _settingsBox.put(entry.key, entry.value);
    }
    
    for (var entry in importData['cached_images'].entries) {
      await _cachedImagesBox.put(entry.key, entry.value);
    }
  }
  
  // Cleanup
  Future<void> dispose() async {
    await _quotesBox.close();
    await _favoritesBox.close();
    await _settingsBox.close();
    await _cachedImagesBox.close();
  }
  
  /// Get a random quote from Hive/local only (no DeepAI)
  Future<Quote> getRandomQuoteFromLocalOnly({String? category, String? tradition}) async {
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