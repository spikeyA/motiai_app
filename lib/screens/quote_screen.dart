import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/hive_quote_service.dart';
import '../services/quote_service.dart';
import '../services/image_service.dart';
import '../services/audio_service.dart';
import '../models/quote.dart';

class QuoteScreen extends StatefulWidget {
  final String? category;
  final String? tradition;

  const QuoteScreen({Key? key, this.category, this.tradition}) : super(key: key);

  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> with TickerProviderStateMixin {
  Quote? _currentQuote;
  Quote? _nextAIQuote; // Store the next AI quote in the background
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String? _backgroundImageUrl;
  bool _isLoadingImage = false;
  int _gradientIndex = 0; // Track current gradient
  bool _isAudioEnabled = true; // Audio toggle state

  String? _selectedTradition; // Track the user's chosen tradition

  // Dynamic gradients for different moods
  static const List<List<Color>> _gradients = [
    [Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFF45B7D1)], // Warm sunset
    [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)], // Purple dream
    [Color(0xFFf093fb), Color(0xFFf5576c), Color(0xFF4facfe)], // Pink passion
    [Color(0xFF4facfe), Color(0xFF00f2fe), Color(0xFF43e97b)], // Ocean breeze
    [Color(0xFFfa709a), Color(0xFFfee140), Color(0xFFFF6B6B)], // Golden hour
    [Color(0xFFa8edea), Color(0xFFfed6e3), Color(0xFFffecd2)], // Soft pastels
    [Color(0xFFff9a9e), Color(0xFFfecfef), Color(0xFFfecfef)], // Rose gold
    [Color(0xFFa8caba), Color(0xFF5d4e75), Color(0xFFffecd2)], // Nature calm
  ];

  // Calculate if current gradient is dark or light
  bool get _isDarkBackground {
    final colors = _gradients[_gradientIndex];
    double totalLuminance = 0;
    for (final color in colors) {
      totalLuminance += color.computeLuminance();
    }
    return (totalLuminance / colors.length) < 0.5;
  }

  // Get appropriate text color based on background
  Color get _textColor => _isDarkBackground ? Colors.white : Colors.black;

  // Get appropriate text shadows based on background
  List<Shadow> get _textShadows {
    if (_isDarkBackground) {
      return [
        Shadow(blurRadius: 8, color: Colors.black54, offset: const Offset(0, 2)),
      ];
    } else {
      return [
        Shadow(blurRadius: 8, color: Colors.white70, offset: const Offset(0, 2)),
      ];
    }
  }

  // Track which quotes have been shown for each tradition
  final Map<String, List<String>> _shownQuotesByTradition = {};

  @override
  void initState() {
    super.initState();
    _initializeQuote();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _fadeController.forward();
    _scaleController.forward();
  }

  Future<void> _initializeQuote() async {
    // 1. Show a Hive/local or AI quote immediately
    final quote = await HiveQuoteService.instance.getRandomQuote(
      category: widget.category,
      tradition: widget.tradition,
    );
    setState(() {
      _currentQuote = quote;
    });
    // 2. In the background, start fetching the next AI quote
    _fetchNextAIQuote();
  }

  Future<void> _fetchNextAIQuote() async {
    final aiQuote = await HiveQuoteService.fetchQuoteFromAnthropic();
    if (mounted) {
      setState(() {
        _nextAIQuote = aiQuote;
      });
    }
  }

  Future<void> _generateBackgroundImage(Quote quote) async {
    setState(() {
      _isLoadingImage = true;
      _backgroundImageUrl = null;
      // Set random gradient for new quotes
      _gradientIndex = DateTime.now().millisecondsSinceEpoch % _gradients.length;
    });
    
    // Play ambience for the tradition
    if (_isAudioEnabled) {
      await AudioService.playAmbience(quote.tradition);
    }
    
    // Check if we have a stored image for this quote
    final storedImage = HiveQuoteService.instance.getStoredImage(quote.id);
    if (storedImage != null) {
      print('[QuoteScreen] Using stored image for quote: ${quote.id}');
      setState(() {
        _backgroundImageUrl = storedImage;
        _isLoadingImage = false;
      });
      return;
    }
    
    final prompt = buildPrompt("${quote.tradition} ${quote.category}");
    print('[QuoteScreen] Generating background for: ${quote.tradition} ${quote.category}');
    final url = await StabilityAIGenerator.generateImage(prompt);
    print('[QuoteScreen] Received image URL: $url');
    setState(() {
      // Only set URL if it's a valid AI-generated image, not a fallback
      if (url != null && !url.contains('unsplash.com')) {
        _backgroundImageUrl = url;
        // Store the generated image in Hive for this quote
        HiveQuoteService.instance.storeGeneratedImage(quote.id, url);
        print('[QuoteScreen] Stored generated image in Hive for quote: ${quote.id}');
      } else {
        _backgroundImageUrl = null; // Use gradient background
        print('[QuoteScreen] Using gradient background instead of fallback image');
      }
      _isLoadingImage = false;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    AudioService.dispose(); // Clean up audio resources
    super.dispose();
  }

  // Toggle audio on/off
  void _toggleAudio() {
    setState(() {
      _isAudioEnabled = !_isAudioEnabled;
    });
    
    if (_isAudioEnabled) {
      // Resume audio for current quote
      AudioService.playAmbience(_currentQuote!.tradition);
    } else {
      // Stop audio
      AudioService.stopAmbience();
    }
  }

  // Toggle AI quotes on/off
  void _toggleAIQuotes() {
    setState(() {
      HiveQuoteService.useAIQuotes = !HiveQuoteService.useAIQuotes;
    });
    
    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          HiveQuoteService.useAIQuotes 
            ? 'AI quotes enabled - will try AI first, then local' 
            : 'AI quotes disabled - using local quotes only',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: HiveQuoteService.useAIQuotes ? Colors.green : Colors.orange,
      ),
    );
  }

  void _generateNewQuote() async {
    print('[QuoteScreen] useAIQuotes: ${HiveQuoteService.useAIQuotes}');
    _fadeController.reverse().then((_) async {
      Quote? quoteToShow;
      if (_nextAIQuote != null) {
        quoteToShow = _nextAIQuote;
        _nextAIQuote = null; // Consume the AI quote
      } else {
        // Try AI first, fallback to local
        quoteToShow = await HiveQuoteService.instance.getRandomQuote(
          category: widget.category,
          tradition: _selectedTradition ?? widget.tradition,
        );
      }
      if (quoteToShow != null) {
        setState(() {
          _currentQuote = quoteToShow;
        });
        print('[QuoteScreen] Showing quote: "${_currentQuote!.text}" - ${_currentQuote!.author} [${_currentQuote!.tradition} / ${_currentQuote!.category}] (id: ${_currentQuote!.id})');
      }
      _generateBackgroundImage(_currentQuote!);
      _fadeController.forward();
      _scaleController.forward();
      // Start fetching the next AI quote in the background
      _fetchNextAIQuote();
    });
  }

  void _generateNewBackground(Quote quote) async {
    setState(() {
      _isLoadingImage = true;
      // Cycle to next gradient
      _gradientIndex = (_gradientIndex + 1) % _gradients.length;
    });
    final prompt = buildPrompt("${quote.tradition} ${quote.category}");
    final url = await StabilityAIGenerator.generateImage(prompt);
    setState(() {
      // Only set URL if it's a valid AI-generated image, not a fallback
      if (url != null && !url.contains('unsplash.com')) {
        _backgroundImageUrl = url;
      } else {
        _backgroundImageUrl = null; // Use gradient background
        print('[QuoteScreen] Using gradient background for refresh');
      }
      _isLoadingImage = false;
    });
  }

  void _shareQuote() {
    final quoteText = '"${_currentQuote!.text}"\n- ${_currentQuote!.author}';
    Clipboard.setData(ClipboardData(text: quoteText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quote copied to clipboard!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Store in Hive (no backend needed)
  Future<void> _toggleFavorite(Quote quote) async {
    final favorites = Hive.box('favorites');
    await favorites.put(quote.id, !(favorites.get(quote.id) ?? false));
    setState(() {}); // Rebuild to update heart icon
  }

  Color _getTraditionColor(String tradition) {
    switch (tradition) {
      case 'Buddhist':
        return Colors.orange.shade400; // Warm orange for Buddhist wisdom
      case 'Sufi':
        return Colors.purple.shade400; // Mystical purple for Sufi tradition
      case 'Zen':
        return Colors.teal.shade400; // Calm teal for Zen philosophy
      case 'Taoism':
        return Colors.green.shade500; // Natural green for Taoist harmony
      case 'Stoicism':
        return Colors.indigo.shade500; // Deep indigo for Stoic strength
      case 'Indigenous Wisdom':
        return Colors.brown.shade600; // Earth brown for Indigenous connection
      case 'Mindful Tech':
        return Colors.blue.shade500; // Tech blue for mindful technology
      case 'Eco-Spirituality':
        return Colors.lightGreen.shade600; // Eco green for environmental wisdom
      case 'Poetic Sufism':
        return Colors.pink.shade400; // Poetic pink for mystical poetry
      default:
        return Colors.grey.shade400; // Fallback grey
    }
  }

  // Helper widget to display both network and base64 images
  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl.startsWith('data:image/')) {
      // Handle base64 data URL
      try {
        final data = imageUrl.split(',')[1];
        final bytes = base64Decode(data);
        return Image.memory(
          bytes,
          key: ValueKey(imageUrl),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
        );
      } catch (e) {
        print('[Image] Error decoding base64: $e');
        return const SizedBox.shrink();
      }
    } else {
      // Handle network URL
      return Image.network(
        imageUrl,
        key: ValueKey(imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuote == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // Log the source for debugging, but do not show in UI
    final actualSource = HiveQuoteService.useAIQuotes ? 'AI' : 'Local';
    print('[QuoteScreen] Source: $actualSource');
    return Scaffold(
      body: Stack(
        children: [
          // Always show gradient as the bottom layer
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _gradients[_gradientIndex],
                ),
              ),
            ),
          ),
          // Image layer: always fills, fades in/out, no hover issues
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 900),
              child: (_backgroundImageUrl != null && _backgroundImageUrl!.isNotEmpty)
                  ? _buildImageWidget(_backgroundImageUrl!)
                  : const SizedBox.shrink(),
            ),
          ),
          // Loading spinner overlay
          if (_isLoadingImage)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                  ),
                ),
              ),
            ),
          // Main content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // App Title
                Text(
                  'MotiAI',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                    letterSpacing: 2,
                    shadows: _textShadows,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Wisdom from Ancient Traditions',
                  style: TextStyle(
                    fontSize: 16,
                    color: _textColor.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                    shadows: _textShadows,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // AI Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Colors.green.shade400,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AI Enabled',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade400,
                          fontWeight: FontWeight.w500,
                          shadows: _textShadows,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Quote Card
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: _currentQuote == null
                      ? const SizedBox.shrink()
                      : Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              key: ValueKey(_currentQuote!.id),
                              constraints: const BoxConstraints(maxWidth: 480),
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Quote Text
                                        Text(
                                          _currentQuote!.text,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w300,
                                            height: 1.5,
                                            color: Colors.black87,
                                            letterSpacing: 0.5,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 16,
                                                color: Colors.white,
                                                offset: const Offset(0, 4),
                                              ),
                                              Shadow(
                                                blurRadius: 12,
                                                color: Colors.white70,
                                                offset: const Offset(0, 2),
                                              ),
                                              Shadow(
                                                blurRadius: 8,
                                                color: Colors.white54,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        
                                        // Author
                                        Text(
                                          _currentQuote!.author,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black87,
                                            fontStyle: FontStyle.italic,
                                            letterSpacing: 1.0,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 12,
                                                color: Colors.white,
                                                offset: const Offset(0, 3),
                                              ),
                                              Shadow(
                                                blurRadius: 8,
                                                color: Colors.white70,
                                                offset: const Offset(0, 2),
                                              ),
                                              Shadow(
                                                blurRadius: 4,
                                                color: Colors.white54,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // Tradition
                                        Text(
                                          _currentQuote!.tradition,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: 0.8,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 10,
                                                color: Colors.white,
                                                offset: const Offset(0, 2),
                                              ),
                                              Shadow(
                                                blurRadius: 6,
                                                color: Colors.white70,
                                                offset: const Offset(0, 1),
                                              ),
                                              Shadow(
                                                blurRadius: 3,
                                                color: Colors.white54,
                                                offset: const Offset(0, 0.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        
                                        // Heart Button for Favorites
                                        ValueListenableBuilder(
                                          valueListenable: Hive.box('favorites').listenable(),
                                          builder: (context, box, child) {
                                            final isFavorited = box.get(_currentQuote!.id) ?? false;
                                            return IconButton(
                                              icon: Icon(
                                                isFavorited ? Icons.favorite : Icons.favorite_border,
                                                color: isFavorited ? Colors.red.shade400 : Colors.black87,
                                                size: 28,
                                              ),
                                              onPressed: () => _toggleFavorite(_currentQuote!),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Share Button
                    FloatingActionButton(
                      onPressed: _shareQuote,
                      backgroundColor: Colors.green.shade400,
                      child: const Icon(Icons.share, color: Colors.white),
                    ),
                    
                    // Audio Toggle Button
                    FloatingActionButton.small(
                      onPressed: _toggleAudio,
                      backgroundColor: _isAudioEnabled ? Colors.teal.shade400 : Colors.grey.shade400,
                      child: Icon(
                        _isAudioEnabled ? Icons.volume_up : Icons.volume_off,
                        color: Colors.white,
                      ),
                    ),
                    
                    // Background Refresh Button
                    FloatingActionButton.small(
                      onPressed: () => _generateNewBackground(_currentQuote!),
                      backgroundColor: Colors.orange.shade400,
                      child: const Icon(Icons.refresh, color: Colors.white),
                    ),
                    
                    // Generate New Quote Button
                    FloatingActionButton.extended(
                      onPressed: _generateNewQuote,
                      backgroundColor: Colors.blue.shade600,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'New Quote',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 