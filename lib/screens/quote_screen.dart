import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/quote_service.dart';
import '../services/image_service.dart';
import '../services/audio_service.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> with TickerProviderStateMixin {
  late Quote _currentQuote;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String? _backgroundImageUrl;
  bool _isLoadingImage = false;
  int _gradientIndex = 0; // Track current gradient
  bool _isAudioEnabled = true; // Audio toggle state

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

  @override
  void initState() {
    super.initState();
    _currentQuote = QuoteService.getRandomQuote();
    
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
    _generateBackgroundImage(_currentQuote);
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
    
    final prompt = buildPrompt("${quote.tradition} ${quote.category}");
    print('[QuoteScreen] Generating background for: ${quote.tradition} ${quote.category}');
    final url = await DeepAIGenerator.generateImage(prompt);
    print('[QuoteScreen] Received image URL: $url');
    setState(() {
      // Only set URL if it's a valid AI-generated image, not a fallback
      if (url != null && !url.contains('unsplash.com')) {
        _backgroundImageUrl = url;
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
      AudioService.playAmbience(_currentQuote.tradition);
    } else {
      // Stop audio
      AudioService.stopAmbience();
    }
  }

  void _generateNewQuote() {
    _fadeController.reverse().then((_) {
      setState(() {
        _currentQuote = QuoteService.getRandomQuote();
      });
      _generateBackgroundImage(_currentQuote);
      _fadeController.forward();
      _scaleController.forward();
    });
  }

  void _generateNewBackground(Quote quote) async {
    setState(() {
      _isLoadingImage = true;
      // Cycle to next gradient
      _gradientIndex = (_gradientIndex + 1) % _gradients.length;
    });
    final prompt = buildPrompt("${quote.tradition} ${quote.category}");
    final url = await DeepAIGenerator.generateImage(prompt);
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

  void _generateQuoteByTradition(String tradition) {
    _fadeController.reverse().then((_) {
      setState(() {
        _currentQuote = QuoteService.getQuoteByTradition(tradition);
      });
      _generateBackgroundImage(_currentQuote);
      _fadeController.forward();
      _scaleController.forward();
    });
  }

  void _shareQuote() {
    final quoteText = '"${_currentQuote.text}"\n- ${_currentQuote.author}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Beautiful gradient background (primary)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _gradients[_gradientIndex],
                ),
              ),
            ),
          ),
          // AI-generated background image (only if available and valid)
          if (_backgroundImageUrl != null && _backgroundImageUrl!.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                _backgroundImageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _gradients[_gradientIndex],
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('[Image] Failed to load: $_backgroundImageUrl');
                  print('[Image] Error: $error');
                  // Return the gradient background instead of gray
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _gradients[_gradientIndex],
                      ),
                    ),
                  );
                },
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
          // Dark overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.15),
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
                const SizedBox(height: 40),
                
                // Quote Card
                AnimatedBuilder(
                  animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 480),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.01),
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.10),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Tradition Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getTraditionColor(_currentQuote.tradition),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _currentQuote.tradition,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // Quote Text
                                    Text(
                                      '"${_currentQuote.text}"',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w300,
                                        height: 1.4,
                                        color: _textColor,
                                        shadows: _textShadows,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // Author
                                    Text(
                                      '- ${_currentQuote.author}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: _textColor.withOpacity(0.85),
                                        fontStyle: FontStyle.italic,
                                        shadows: _textShadows,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Category
                                    Text(
                                      _currentQuote.category,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _textColor.withOpacity(0.7),
                                        fontWeight: FontWeight.w400,
                                        shadows: _textShadows,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // Heart Button for Favorites
                                    ValueListenableBuilder(
                                      valueListenable: Hive.box('favorites').listenable(),
                                      builder: (context, box, child) {
                                        final isFavorited = box.get(_currentQuote.id) ?? false;
                                        return IconButton(
                                          icon: Icon(
                                            isFavorited ? Icons.favorite : Icons.favorite_border,
                                            color: isFavorited ? Colors.red.shade400 : _textColor.withOpacity(0.8),
                                            size: 28,
                                          ),
                                          onPressed: () => _toggleFavorite(_currentQuote),
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
                    );
                  },
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
                      onPressed: () => _generateNewBackground(_currentQuote),
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
                    
                    // Tradition Filter Button
                    FloatingActionButton(
                      onPressed: () => _showTraditionDialog(),
                      backgroundColor: Colors.purple.shade400,
                      child: const Icon(Icons.filter_list, color: Colors.white),
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

  void _showTraditionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'Choose Tradition',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                          shadows: _textShadows,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Traditions List
                      ...QuoteService.getTraditions().map((tradition) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _generateQuoteByTradition(tradition);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _getTraditionColor(tradition),
                                    radius: 20,
                                    child: Text(
                                      tradition[0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      tradition,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: _textColor,
                                        shadows: _textShadows,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: _textColor.withOpacity(0.6),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                      // Cancel Button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: _textColor.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            shadows: _textShadows,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 