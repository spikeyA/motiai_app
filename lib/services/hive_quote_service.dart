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
  static const String _cachedAudioBoxName = 'cached_audio';
  
  late Box<dynamic> _quotesBox;
  late Box<dynamic> _favoritesBox;
  late Box<dynamic> _settingsBox;
  late Box<dynamic> _cachedImagesBox;
  late Box<dynamic> _cachedAudioBox;
  
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
    instance._cachedAudioBox = await Hive.openBox(_cachedAudioBoxName);
    
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
  
  /// Developer toggle: set to false to disable AI quotes and use only local quotes
  static bool useAIQuotes = true;
  
  /// Check Anthropic API status and return a user-friendly message
  static Future<String> getAnthropicStatus() async {
    String? apiKey;
    try {
      apiKey = dotenv.env['ANTHROPIC_API_KEY'];
    } catch (e) {
      return 'Anthropic not configured - no .env file found';
    }
    
    if (apiKey == null || apiKey.isEmpty) {
      return 'Anthropic not configured - no API key found';
    }
    
    if (apiKey == 'your_anthropic_api_key_here') {
      return 'Anthropic not configured - please add your API key to .env file';
    }
    
    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01'
        },
        body: json.encode({
          'model': 'claude-3-haiku-20240307',
          'max_tokens': 100,
          'messages': [
            {
              'role': 'user',
              'content': 'Generate a short motivational quote from a spiritual tradition. Return only the quote text, no additional formatting.'
            }
          ]
        }),
      );
      
      if (response.statusCode == 200) {
        return 'Anthropic available - API key valid';
      } else if (response.statusCode == 401) {
        return 'Anthropic authentication failed - check your API key';
      } else if (response.statusCode == 429) {
        return 'Anthropic rate limit exceeded - try again later';
      } else {
        return 'Anthropic error - status ${response.statusCode}';
      }
    } catch (e) {
      return 'Anthropic connection error - ${e.toString()}';
    }
  }
  
  /// Fetch a quote from Anthropic's Claude API
  static Future<Quote?> fetchQuoteFromAnthropic() async {
    String? apiKey;
    try {
      apiKey = dotenv.env['ANTHROPIC_API_KEY'];
    } catch (e) {
      print('[Anthropic] .env not loaded - skipping API call.');
      return null;
    }
    
    if (apiKey == null || apiKey.isEmpty) {
      print('[Anthropic] No API key found for quote generation.');
      return null;
    }
    
    // Check if API key is the placeholder value
    if (apiKey == 'your_anthropic_api_key_here') {
      print('[Anthropic] API key not configured - please add your Anthropic API key to .env file');
      return null;
    }
    
    // List of authentic author names for AI-generated quotes
    final List<String> authenticAuthors = [
      'Buddha',
      'Rumi',
      'Lao Tzu',
      'Confucius',
      'Socrates',
      'Plato',
      'Aristotle',
      'Marcus Aurelius',
      'Epictetus',
      'Seneca',
      'Krishna',
      'Ramana Maharshi',
      'Swami Vivekananda',
      'Thich Nhat Hanh',
      'Dalai Lama',
      'Khalil Gibran',
      'Osho',
      'Jiddu Krishnamurti',
      'Paramahansa Yogananda',
      'Sri Chinmoy',
      // Adding diverse women authors
      'Maya Angelou',
      'Audre Lorde',
      'bell hooks',
      'Gloria Steinem',
      'Simone de Beauvoir',
      'Hannah Arendt',
      'Virginia Woolf',
      'Mary Wollstonecraft',
      'Mother Teresa',
      'Aung San Suu Kyi',
      'Malala Yousafzai',
      'Wangari Maathai',
      'Rigoberta Menchú',
      'Shirin Ebadi',
      'Arundhati Roy',
      'Chimamanda Ngozi Adichie',
      'Toni Morrison',
      'Alice Walker',
      'Zora Neale Hurston',
      'Pema Chödrön',
      'Sharon Salzberg',
      'Tara Brach',
      'Sylvia Boorstein',
      'Joan Halifax',
      'Sister Chan Khong',
      'Dipa Ma',
      'Mae Chee Kaew',
      'Khandro Rinpoche',
      'Jetsunma Tenzin Palmo',
      'Ani Pema Chödrön',
      'Sakyadhita',
      'Thubten Chodron',
      'Ayya Khema',
      'Sister Stanislaus Kennedy',
      'Dorothy Day',
      'Hildegard of Bingen',
      'Julian of Norwich',
      'Teresa of Ávila',
      'Catherine of Siena',
      'Simone Weil',
      'Edith Stein',
      'Dorothy Stang',
    ];
    
    // List of authentic tradition names for AI-generated quotes
    final List<String> authenticTraditions = [
      'Buddhist',
      'Sufi',
      'Taoism',
      'Confucianism',
      'Stoicism',
      'Hinduism',
      'Indigenous Wisdom',
      'Mindful Tech',
      'Social Justice',
    ];
    
    // Proper author-tradition mappings to ensure historical accuracy
    final Map<String, List<String>> authorTraditionMap = {
      'Buddhist': ['Buddha', 'Thich Nhat Hanh', 'Dalai Lama', 'Pema Chödrön', 'Sharon Salzberg', 'Tara Brach', 'Sylvia Boorstein', 'Joan Halifax', 'Sister Chan Khong', 'Dipa Ma', 'Mae Chee Kaew', 'Khandro Rinpoche', 'Jetsunma Tenzin Palmo', 'Thubten Chodron', 'Ayya Khema'],
      'Sufi': ['Rumi', 'Khalil Gibran'],
      'Taoism': ['Lao Tzu'],
      'Confucianism': ['Confucius'],
      'Stoicism': ['Socrates', 'Plato', 'Aristotle', 'Marcus Aurelius', 'Epictetus', 'Seneca', 'Simone de Beauvoir', 'Hannah Arendt', 'Virginia Woolf', 'Mary Wollstonecraft', 'Simone Weil'],
      'Hinduism': ['Krishna', 'Ramana Maharshi', 'Swami Vivekananda', 'Osho', 'Jiddu Krishnamurti', 'Paramahansa Yogananda', 'Sri Chinmoy'],
      'Indigenous Wisdom': ['Wangari Maathai', 'Rigoberta Menchú', 'Arundhati Roy', 'Chimamanda Ngozi Adichie'],
      'Mindful Tech': ['Steve Jobs', 'Bill Gates', 'Albert Einstein'],
      'Social Justice': ['Maya Angelou', 'Audre Lorde', 'bell hooks', 'Gloria Steinem', 'Aung San Suu Kyi', 'Malala Yousafzai', 'Wangari Maathai', 'Rigoberta Menchú', 'Shirin Ebadi', 'Arundhati Roy', 'Chimamanda Ngozi Adichie', 'Toni Morrison', 'Alice Walker', 'Zora Neale Hurston'],
    };
    
    final prompt = "Create an original, inspiring quote in the style of spiritual wisdom. Do NOT use famous quotes or quotes from well-known authors. Create something completely new and original. Return ONLY the quote text without any author attribution, quotation marks, or additional formatting. Just the pure quote text.";
    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01'
        },
        body: json.encode({
          'model': 'claude-3-haiku-20240307',
          'max_tokens': 150,
          'messages': [
            {
              'role': 'user',
              'content': prompt
            }
          ]
        }),
      );
      print('[Anthropic] Quote API status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['content']?[0]?['text']?.toString().trim();
        if (text != null && text.isNotEmpty) {
          // Clean the text to remove any author attributions, quotes, or dashes
          String cleanText = text;
          
          // Remove quotation marks
          cleanText = cleanText.replaceAll('"', '').replaceAll('"', '').replaceAll('"', '');
          
          // Remove author attributions (patterns like " - Author" or " -Author")
          cleanText = cleanText.replaceAll(RegExp(r'\s*-\s*[A-Za-z\s]+$'), '');
          
          // Remove any remaining dashes at the end
          cleanText = cleanText.replaceAll(RegExp(r'\s*-\s*$'), '');
          
          // Trim any extra whitespace
          cleanText = cleanText.trim();
          
          // Check for common famous quotes and reject them
          final List<String> famousQuotes = [
            'the journey of a thousand miles begins with a single step',
            'be the change you wish to see in the world',
            'life is what happens when you are busy making other plans',
            'the only way to do great work is to love what you do',
            'everything you can imagine is real',
            'peace comes from within',
            'happiness is not something ready made',
            'the mind is everything',
            'wisdom begins in wonder',
            'know thyself',
            'the unexamined life is not worth living',
            'beauty is in the eye of the beholder',
            'actions speak louder than words',
            'practice makes perfect',
            'where there is a will there is a way',
          ];
          
          final cleanTextLower = cleanText.toLowerCase();
          bool isFamousQuote = famousQuotes.any((famous) => 
            cleanTextLower.contains(famous.toLowerCase()) || 
            famous.toLowerCase().contains(cleanTextLower)
          );
          
          if (isFamousQuote) {
            print('[Anthropic] Rejected famous quote: "$cleanText"');
            return null; // Skip this quote and try again
          }
          
          if (cleanText.isNotEmpty) {
            print('[Anthropic] Successfully generated AI quote: "$cleanText"');
            
            // Randomly select a tradition first
            final randomTradition = authenticTraditions[DateTime.now().millisecondsSinceEpoch % authenticTraditions.length];
            
            // Get the list of appropriate authors for this tradition
            final availableAuthors = authorTraditionMap[randomTradition] ?? ['Buddha'];
            
            // Randomly select an appropriate author for this tradition
            final randomAuthor = availableAuthors[DateTime.now().millisecondsSinceEpoch % availableAuthors.length];
            
            final aiQuote = Quote(
              id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
              text: cleanText,
              author: randomAuthor,
              tradition: randomTradition,
              category: 'Inspiration',
              imageUrl: '',
            );
            
            // Store the AI-generated quote in Hive for persistence
            await instance.addQuote(aiQuote);
            print('[Anthropic] AI quote stored in Hive: ${aiQuote.id}');
            
            return aiQuote;
          }
        }
      } else if (response.statusCode == 401) {
        print('[Anthropic] Authentication failed - check your API key');
      } else if (response.statusCode == 429) {
        print('[Anthropic] Rate limit exceeded - try again later');
      } else {
        print('[Anthropic] Quote API error: ${response.body}');
      }
    } catch (e) {
      print('[Anthropic] Quote API exception: ${e.toString()}');
    }
    return null;
  }
  
  /// Try Anthropic first, fallback to Hive/local
  @override
  Future<Quote> getRandomQuote({String? category, String? tradition}) async {
    print('[HiveQuoteService] useAIQuotes: $useAIQuotes');
    print('[HiveQuoteService] Getting random quote (category: $category, tradition: $tradition)');
    // 1. Try Anthropic if enabled
    if (useAIQuotes) {
      final aiQuote = await fetchQuoteFromAnthropic();
      if (aiQuote != null) {
        print('[HiveQuoteService] Using AI-generated quote: "${aiQuote.text}"');
        return aiQuote;
      }
    }
    // 2. Fallback to Hive/local
    print('[HiveQuoteService] Falling back to local quote.');
    List<Quote> allQuotes = await getAllQuotes();
    if (allQuotes.isEmpty) {
      throw Exception('No quotes found');
    }
    
    // Filter out AI quotes when useAIQuotes is false
    List<Quote> filteredQuotes = allQuotes;
    if (!useAIQuotes) {
      filteredQuotes = filteredQuotes.where((q) => !q.id.startsWith('ai_')).toList();
      print('[HiveQuoteService] Filtered out AI quotes, ${filteredQuotes.length} local quotes remaining');
    }
    
    if (tradition != null) {
      final trimmedTradition = tradition.trim().toLowerCase();
      filteredQuotes = filteredQuotes.where(
        (q) => q.tradition.trim().toLowerCase() == trimmedTradition
      ).toList();
    }
    if (category != null) {
      filteredQuotes = filteredQuotes.where((q) => q.category.toLowerCase() == category.toLowerCase()).toList();
    }
    if (filteredQuotes.isEmpty) {
      filteredQuotes = allQuotes;
      // Apply AI filter again if we're falling back to all quotes
      if (!useAIQuotes) {
        filteredQuotes = filteredQuotes.where((q) => !q.id.startsWith('ai_')).toList();
      }
    }
    filteredQuotes.shuffle();
    return filteredQuotes.first;
  }

  /// Get random quote while avoiding recent traditions
  Future<Quote> getRandomQuoteWithTraditionVariety({
    String? category, 
    String? tradition, 
    List<String>? avoidTraditions
  }) async {
    print('[HiveQuoteService] Getting random quote with tradition variety (avoid: $avoidTraditions)');
    
    // 1. Try Anthropic if enabled
    if (useAIQuotes) {
      final aiQuote = await fetchQuoteFromAnthropic();
      if (aiQuote != null) {
        // Check if AI quote tradition should be avoided
        if (avoidTraditions == null || !avoidTraditions.contains(aiQuote.tradition.trim())) {
          print('[HiveQuoteService] Using AI-generated quote: "${aiQuote.text}"');
          return aiQuote;
        }
      }
    }
    
    // 2. Fallback to Hive/local
    List<Quote> allQuotes = await getAllQuotes();
    if (allQuotes.isEmpty) {
      throw Exception('No quotes found');
    }
    
    // Filter out AI quotes when useAIQuotes is false
    List<Quote> filteredQuotes = allQuotes;
    if (!useAIQuotes) {
      filteredQuotes = filteredQuotes.where((q) => !q.id.startsWith('ai_')).toList();
    }
    
    // Filter out traditions to avoid
    if (avoidTraditions != null && avoidTraditions.isNotEmpty) {
      filteredQuotes = filteredQuotes.where((q) => 
        !avoidTraditions.contains(q.tradition.trim())
      ).toList();
      print('[HiveQuoteService] After avoiding traditions, ${filteredQuotes.length} quotes remaining');
    }
    
    // Apply category and tradition filters
    if (tradition != null) {
      final trimmedTradition = tradition.trim().toLowerCase();
      filteredQuotes = filteredQuotes.where(
        (q) => q.tradition.trim().toLowerCase() == trimmedTradition
      ).toList();
    }
    if (category != null) {
      filteredQuotes = filteredQuotes.where((q) => q.category.toLowerCase() == category.toLowerCase()).toList();
    }
    
    // If no quotes available after filtering, reset and use all quotes
    if (filteredQuotes.isEmpty) {
      print('[HiveQuoteService] No quotes available after tradition filtering, using all quotes');
      filteredQuotes = allQuotes;
      if (!useAIQuotes) {
        filteredQuotes = filteredQuotes.where((q) => !q.id.startsWith('ai_')).toList();
      }
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
    print('[HiveQuoteService] Cached image for quote: $quoteId');
  }
  
  String? getCachedImageUrl(String quoteId) {
    return _cachedImagesBox.get(quoteId);
  }
  
  /// Store generated image for a specific quote
  Future<void> storeGeneratedImage(String quoteId, String imageData) async {
    await _cachedImagesBox.put(quoteId, imageData);
    print('[HiveQuoteService] Stored generated image for quote: $quoteId');
  }
  
  /// Get stored image for a quote
  String? getStoredImage(String quoteId) {
    return _cachedImagesBox.get(quoteId);
  }
  
  /// Check if a quote has a stored image
  bool hasStoredImage(String quoteId) {
    return _cachedImagesBox.containsKey(quoteId);
  }
  
  /// Get all quotes with their associated images
  Future<Map<String, String>> getAllQuoteImages() async {
    Map<String, String> quoteImages = {};
    for (var key in _cachedImagesBox.keys) {
      final imageData = _cachedImagesBox.get(key);
      if (imageData != null) {
        quoteImages[key.toString()] = imageData;
      }
    }
    return quoteImages;
  }
  
  /// Get the count of stored images
  int getStoredImageCount() {
    return _cachedImagesBox.length;
  }
  
  /// Get a random quote from Hive/local only (no Anthropic)
  Future<Quote> getRandomQuoteFromLocalOnly({String? category, String? tradition}) async {
    List<Quote> allQuotes = await getAllQuotes();
    if (allQuotes.isEmpty) {
      throw Exception('No quotes found');
    }
    List<Quote> filteredQuotes = allQuotes;
    if (tradition != null) {
      final trimmedTradition = tradition.trim().toLowerCase();
      filteredQuotes = filteredQuotes.where(
        (q) => q.tradition.trim().toLowerCase() == trimmedTradition
      ).toList();
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
        id: 'buddhist_obstacles',
        text: 'The obstacle is the path.',
        author: 'Buddha',
        tradition: 'Buddhist',
        category: 'Obstacles',
        imageUrl: '',
      ),
      Quote(
        id: 'buddhist_enlightenment',
        text: 'Before enlightenment, chop wood, carry water. After enlightenment, chop wood, carry water.',
        author: 'Buddha',
        tradition: 'Buddhist',
        category: 'Enlightenment',
        imageUrl: '',
      ),
      Quote(
        id: 'buddhist_present',
        text: 'The only moment that matters is now.',
        author: 'Thich Nhat Hanh',
        tradition: 'Buddhist',
        category: 'Present Moment',
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
        id: 'buddhist_peace',
        text: 'Peace comes from within. Do not seek it without.',
        author: 'Buddha',
        tradition: 'Buddhist',
        category: 'Peace',
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
      Quote(
        id: 'buddhist_mindfulness',
        text: 'The mind is everything. What you think you become.',
        author: 'Buddha',
        tradition: 'Buddhist',
        category: 'Mindfulness',
        imageUrl: '',
      ),
      Quote(
        id: 'buddhist_compassion_2',
        text: 'Compassion is not a relationship between the healer and the wounded. It is a relationship between equals.',
        author: 'Thich Nhat Hanh',
        tradition: 'Buddhist',
        category: 'Compassion',
        imageUrl: '',
      ),
      Quote(
        id: 'buddhist_happiness',
        text: 'Happiness is not something ready made. It comes from your own actions.',
        author: 'Dalai Lama',
        tradition: 'Buddhist',
        category: 'Happiness',
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
        id: 'sufi_heart',
        text: 'Let yourself be silently drawn by the strange pull of what you really love. It will not lead you astray.',
        author: 'Rumi',
        tradition: 'Sufi',
        category: 'Heart',
        imageUrl: '',
      ),
      Quote(
        id: 'sufi_wisdom',
        text: 'Yesterday I was clever, so I wanted to change the world. Today I am wise, so I am changing myself.',
        author: 'Rumi',
        tradition: 'Sufi',
        category: 'Wisdom',
        imageUrl: '',
      ),
      Quote(
        id: 'sufi_truth',
        text: 'Beauty is not in the face; beauty is a light in the heart.',
        author: 'Khalil Gibran',
        tradition: 'Sufi',
        category: 'Beauty',
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
        id: 'taoism_acceptance',
        text: 'When I let go of what I am, I become what I might be.',
        author: 'Lao Tzu',
        tradition: 'Taoism',
        category: 'Acceptance',
        imageUrl: '',
      ),
      Quote(
        id: 'taoism_harmony',
        text: 'The Tao that can be told is not the eternal Tao.',
        author: 'Lao Tzu',
        tradition: 'Taoism',
        category: 'Harmony',
        imageUrl: '',
      ),
      Quote(
        id: 'taoism_wisdom',
        text: 'Knowing others is intelligence; knowing yourself is true wisdom.',
        author: 'Lao Tzu',
        tradition: 'Taoism',
        category: 'Wisdom',
        imageUrl: '',
      ),
      Quote(
        id: 'confucianism_learning',
        text: 'Learning without thought is labor lost; thought without learning is perilous.',
        author: 'Confucius',
        tradition: 'Confucianism',
        category: 'Learning',
        imageUrl: '',
      ),
      Quote(
        id: 'confucianism_virtue',
        text: 'The superior man is modest in his speech, but exceeds in his actions.',
        author: 'Confucius',
        tradition: 'Confucianism',
        category: 'Virtue',
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
        id: 'stoicism_obstacles',
        text: 'The impediment to action advances action. What stands in the way becomes the way.',
        author: 'Marcus Aurelius',
        tradition: 'Stoicism',
        category: 'Obstacles',
        imageUrl: '',
      ),
      Quote(
        id: 'stoicism_control_2',
        text: 'You have power over your mind – not outside events. Realize this, and you will find strength.',
        author: 'Marcus Aurelius',
        tradition: 'Stoicism',
        category: 'Control',
        imageUrl: '',
      ),
      Quote(
        id: 'stoicism_wisdom',
        text: 'The only true wisdom is in knowing you know nothing.',
        author: 'Socrates',
        tradition: 'Stoicism',
        category: 'Wisdom',
        imageUrl: '',
      ),
      Quote(
        id: 'stoicism_justice',
        text: 'Justice means minding one\'s own business and not meddling with other men\'s concerns.',
        author: 'Plato',
        tradition: 'Stoicism',
        category: 'Justice',
        imageUrl: '',
      ),
      Quote(
        id: 'stoicism_excellence',
        text: 'Excellence is never an accident. It is always the result of high intention, sincere effort, and intelligent execution.',
        author: 'Aristotle',
        tradition: 'Stoicism',
        category: 'Excellence',
        imageUrl: '',
      ),
      Quote(
        id: 'stoicism_freedom',
        text: 'Freedom is the only worthy goal in life. It is won by disregarding things that lie beyond our control.',
        author: 'Epictetus',
        tradition: 'Stoicism',
        category: 'Freedom',
        imageUrl: '',
      ),
      Quote(
        id: 'stoicism_life',
        text: 'Life is long if you know how to use it.',
        author: 'Seneca',
        tradition: 'Stoicism',
        category: 'Life',
        imageUrl: '',
      ),
      Quote(
        id: 'hinduism_karma',
        text: 'As you sow, so shall you reap.',
        author: 'Krishna',
        tradition: 'Hinduism',
        category: 'Karma',
        imageUrl: '',
      ),
      Quote(
        id: 'hinduism_self',
        text: 'The greatest meditation is a mind that lets go.',
        author: 'Ramana Maharshi',
        tradition: 'Hinduism',
        category: 'Meditation',
        imageUrl: '',
      ),
      Quote(
        id: 'hinduism_strength',
        text: 'Strength is life, weakness is death.',
        author: 'Swami Vivekananda',
        tradition: 'Hinduism',
        category: 'Strength',
        imageUrl: '',
      ),
      Quote(
        id: 'hinduism_awareness',
        text: 'Awareness is the greatest agent for change.',
        author: 'Osho',
        tradition: 'Hinduism',
        category: 'Awareness',
        imageUrl: '',
      ),
      Quote(
        id: 'hinduism_truth',
        text: 'Truth is a pathless land.',
        author: 'Jiddu Krishnamurti',
        tradition: 'Hinduism',
        category: 'Truth',
        imageUrl: '',
      ),
      Quote(
        id: 'hinduism_peace',
        text: 'Peace is not something you wish for; it is something you make, something you do, something you are.',
        author: 'Paramahansa Yogananda',
        tradition: 'Hinduism',
        category: 'Peace',
        imageUrl: '',
      ),
      Quote(
        id: 'hinduism_harmony',
        text: 'Harmony is the secret of life.',
        author: 'Sri Chinmoy',
        tradition: 'Hinduism',
        category: 'Harmony',
        imageUrl: '',
      ),
      Quote(
        id: 'indigenous_wisdom_environment',
        text: 'You cannot protect the environment unless you empower people, you inform them, and you help them understand that these resources are their own, that they must protect them.',
        author: 'Wangari Maathai',
        tradition: 'Indigenous Wisdom',
        category: 'Environment',
        imageUrl: '',
      ),
      Quote(
        id: 'indigenous_wisdom_story',
        text: 'The single story creates stereotypes, and the problem with stereotypes is not that they are untrue, but that they are incomplete.',
        author: 'Chimamanda Ngozi Adichie',
        tradition: 'Indigenous Wisdom',
        category: 'Story',
        imageUrl: '',
      ),
      Quote(
        id: 'mindful_tech_innovation',
        text: 'Innovation distinguishes between a leader and a follower.',
        author: 'Steve Jobs',
        tradition: 'Mindful Tech',
        category: 'Innovation',
        imageUrl: '',
      ),
      Quote(
        id: 'mindful_tech_future',
        text: 'The future belongs to those who believe in the beauty of their dreams.',
        author: 'Bill Gates',
        tradition: 'Mindful Tech',
        category: 'Future',
        imageUrl: '',
      ),
      Quote(
        id: 'mindful_tech_imagination',
        text: 'Imagination is more important than knowledge.',
        author: 'Albert Einstein',
        tradition: 'Mindful Tech',
        category: 'Imagination',
        imageUrl: '',
      ),
      Quote(
        id: 'social_justice_courage',
        text: 'I\'ve learned that people will forget what you said, people will forget what you did, but people will never forget how you made them feel.',
        author: 'Maya Angelou',
        tradition: 'Social Justice',
        category: 'Courage',
        imageUrl: '',
      ),
      Quote(
        id: 'social_justice_self_love',
        text: 'Caring for myself is not self-indulgence, it is self-preservation, and that is an act of political warfare.',
        author: 'Audre Lorde',
        tradition: 'Social Justice',
        category: 'Self-Love',
        imageUrl: '',
      ),
      Quote(
        id: 'social_justice_love',
        text: 'Love is an action, never simply a feeling.',
        author: 'bell hooks',
        tradition: 'Social Justice',
        category: 'Love',
        imageUrl: '',
      ),
      Quote(
        id: 'social_justice_equality',
        text: 'A feminist is anyone who recognizes the equality and full humanity of women and men.',
        author: 'Gloria Steinem',
        tradition: 'Social Justice',
        category: 'Equality',
        imageUrl: '',
      ),
      Quote(
        id: 'social_justice_humanity',
        text: 'The function of freedom is to free someone else.',
        author: 'Toni Morrison',
        tradition: 'Social Justice',
        category: 'Humanity',
        imageUrl: '',
      ),
      Quote(
        id: 'social_justice_justice',
        text: 'The most common way people give up their power is by thinking they don\'t have any.',
        author: 'Alice Walker',
        tradition: 'Social Justice',
        category: 'Justice',
        imageUrl: '',
      ),
      Quote(
        id: 'social_justice_education',
        text: 'One child, one teacher, one book, one pen can change the world.',
        author: 'Malala Yousafzai',
        tradition: 'Social Justice',
        category: 'Education',
        imageUrl: '',
      ),
      Quote(
        id: 'social_justice_peace',
        text: 'Peace is not the absence of conflict, but the ability to cope with it.',
        author: 'Aung San Suu Kyi',
        tradition: 'Social Justice',
        category: 'Peace',
        imageUrl: '',
      ),
      Quote(
        id: 'social_justice_voice',
        text: 'The most important single ingredient in the formula of success is knowing how to get along with people.',
        author: 'Shirin Ebadi',
        tradition: 'Social Justice',
        category: 'Voice',
        imageUrl: '',
      ),
      Quote(
        id: 'social_justice_truth',
        text: 'There is no greater agony than bearing an untold story inside you.',
        author: 'Zora Neale Hurston',
        tradition: 'Social Justice',
        category: 'Truth',
        imageUrl: '',
      ),
      Quote(
        id: 'social_justice_activism',
        text: 'The struggle for justice is a marathon, not a sprint.',
        author: 'Rigoberta Menchú',
        tradition: 'Social Justice',
        category: 'Activism',
        imageUrl: '',
      ),
      Quote(
        id: 'social_justice_writing',
        text: 'Writing is a form of activism.',
        author: 'Arundhati Roy',
        tradition: 'Social Justice',
        category: 'Writing',
        imageUrl: '',
      ),
    ];
    
    for (Quote quote in initialQuotes) {
      await addQuote(quote);
    }
    
    print('[HiveQuoteService] Loaded ${initialQuotes.length} initial quotes');
  }
  
  // Audio storage methods
  void storeGeneratedAudio(String audioId, String audioData) {
    _cachedAudioBox.put(audioId, audioData);
    print('[HiveQuoteService] Stored generated audio for: $audioId');
  }
  
  String? getStoredAudio(String audioId) {
    return _cachedAudioBox.get(audioId) as String?;
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
    await _cachedAudioBox.close();
  }
  
  Future<void> saveAffirmationToQuote(String quoteId, String affirmation) async {
    final quote = _quotesBox.get(quoteId) as Quote?;
    if (quote != null) {
      final updatedQuote = Quote(
        id: quote.id,
        text: quote.text,
        author: quote.author,
        tradition: quote.tradition,
        category: quote.category,
        imageUrl: quote.imageUrl,
        affirmation: affirmation,
      );
      await _quotesBox.put(quoteId, updatedQuote);
      print('[HiveQuoteService] Saved affirmation to quote: $quoteId');
    }
  }
  
  // Returns all image keys stored in the cached images box
  List<String> getQuoteIdsWithImages() {
    return _cachedImagesBox.keys.cast<String>().toList();
  }
  
  List<String> getAIAudioKeysForTradition(String tradition) {
    final pattern = 'ai_audio_${tradition.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
    return _cachedAudioBox.keys
        .where((k) => k is String && k.startsWith(pattern))
        .cast<String>()
        .toList();
  }
} 