import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../services/hive_quote_service.dart';
import '../services/quote_service.dart';
import '../services/image_service.dart';
import '../services/audio_service.dart';
import '../services/affirmation_service.dart';
import '../models/quote.dart';
import 'notepad_screen.dart';
import '../services/background_prefetch_service.dart';

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
  int _gradientIndex = 0; // Track current gradient
  bool _isAudioEnabled = true; // Audio toggle state

  String? _selectedTradition; // Track the user's chosen tradition
  String? _lastTradition; // Track last shown tradition
  Set<String> _shownImageKeys = {}; // Track shown image keys in session

  bool _backgroundPrefetchStarted = false; // Ensure prefetch only runs once

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

  // Track recent traditions to prevent repetition
  final List<String> _recentTraditions = [];
  static const int _maxRecentTraditions = 3; // Don't repeat last 3 traditions

  Timer? _gradientTimer;
  Timer? _quoteTimer;

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
    print('[QuoteScreen] Initializing quote...');
    // 1. Show a Hive/local or AI quote immediately
    final quote = await HiveQuoteService.instance.getRandomQuote(
      category: widget.category,
      tradition: widget.tradition,
    );
    print('[QuoteScreen] Got quote: ${quote?.text ?? 'null'}');
    setState(() {
      _currentQuote = quote;
    });
    print('[QuoteScreen] Set current quote: ${_currentQuote?.text ?? 'null'}');
    
    // Initialize recent traditions tracking with the first quote
    if (quote != null) {
      final tradition = quote.tradition.trim();
      _recentTraditions.add(tradition);
      _lastTradition = tradition;
      print('[QuoteScreen] Initialized with tradition: $tradition');
    }
    
    // 2. Generate background image for the initial quote
    if (quote != null) {
      _generateBackgroundImage(quote);
    }
    
    // 3. In the background, start fetching the next AI quote
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
      _backgroundImageUrl = null;
      _gradientIndex = DateTime.now().millisecondsSinceEpoch % _gradients.length;
    });
    
    // Play ambience for the tradition
    if (_isAudioEnabled) {
      await AudioService.playAmbience(quote.tradition);
    }
    
    // Try to get a pre-generated image for this tradition, avoiding repeats in session
    final traditionKey = quote.tradition.toLowerCase().replaceAll(' ', '_');
    final allImageKeys = List.generate(8, (i) => '\\${traditionKey}_image_\\${i+1}');
    final unusedImageKeys = allImageKeys.where((k) => !_shownImageKeys.contains(k)).toList();
    String? selectedImageKey;
    if (unusedImageKeys.isNotEmpty) {
      selectedImageKey = (unusedImageKeys..shuffle()).first;
    } else {
      // All images shown, reset
      _shownImageKeys.clear();
      selectedImageKey = (allImageKeys..shuffle()).first;
    }
    final preGeneratedImage = HiveQuoteService.instance.getStoredImage(selectedImageKey);
    if (preGeneratedImage != null) {
      print('[QuoteScreen] Using pre-generated image for tradition: \\${selectedImageKey}');
      setState(() {
        _backgroundImageUrl = preGeneratedImage;
      });
      _shownImageKeys.add(selectedImageKey);
      HiveQuoteService.instance.storeGeneratedImage(quote.id, preGeneratedImage);
      print('[QuoteScreen] Stored pre-generated image for quote: \\${quote.id}');
      // After first image/audio is loaded, trigger background prefetch ONCE
      if (!_backgroundPrefetchStarted) {
        _backgroundPrefetchStarted = true;
        BackgroundPrefetchService.startBackgroundPrefetch();
      }
      return;
    }
    
    // If no pre-generated image available, generate a new one
    // Use random variation (1-8) for variety
    final random = DateTime.now().millisecondsSinceEpoch;
    final variation = (random % 8) + 1;
    final prompt = buildPrompt("${quote.tradition} ${quote.category}", variation: variation);
    print('[QuoteScreen] Generating background for: ${quote.tradition} ${quote.category}');
    print('[QuoteScreen] Using prompt variation $variation: $prompt');
    final url = await StabilityAIGenerator.generateImage(prompt);
    print('[QuoteScreen] Received image URL: ${url?.substring(0, url.length > 50 ? 50 : url.length)}...');
    
    setState(() {
      // Only set URL if it's a valid AI-generated image, not a fallback
      if (url != null && !url.contains('unsplash.com')) {
        _backgroundImageUrl = url;
        // Always store AI-generated images in Hive, regardless of quote source
        HiveQuoteService.instance.storeGeneratedImage(quote.id, url);
        print('[QuoteScreen] Stored generated image in Hive for quote: ${quote.id}');
      } else {
        _backgroundImageUrl = null; // Use gradient background
        print('[QuoteScreen] Using gradient background instead of fallback image');
      }
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
  }

  void _generateNewQuote() async {
    print('[QuoteScreen] useAIQuotes: ${HiveQuoteService.useAIQuotes}');
    _fadeController.reverse().then((_) async {
      Quote? quoteToShow;
      
      try {
        // Use the new method that avoids recent traditions
        quoteToShow = await HiveQuoteService.instance.getRandomQuoteWithTraditionVariety(
          category: widget.category,
          tradition: widget.tradition,
          avoidTraditions: _recentTraditions,
        );
        
        // Update recent traditions tracking
        final newTradition = quoteToShow.tradition.trim();
        _recentTraditions.add(newTradition);
        
        // Keep only the last N traditions
        if (_recentTraditions.length > _maxRecentTraditions) {
          _recentTraditions.removeAt(0);
        }
        
        _lastTradition = newTradition;
        
        setState(() {
          _currentQuote = quoteToShow;
        });
        
        print('[QuoteScreen] Showing quote: "${_currentQuote!.text}" - ${_currentQuote!.author} [${_currentQuote!.tradition} / ${_currentQuote!.category}] (id: ${_currentQuote!.id})');
        print('[QuoteScreen] Recent traditions: $_recentTraditions');
        
        _generateBackgroundImage(_currentQuote!);
        _fadeController.forward();
        _scaleController.forward();
        
        // Start fetching the next AI quote in the background
        _fetchNextAIQuote();
        
      } catch (e) {
        print('[QuoteScreen] Error generating new quote: $e');
        // Fallback to original method if there's an error
        _fadeController.forward();
        _scaleController.forward();
      }
    });
  }

  void _shareQuote() {
    final quoteText = '${_currentQuote!.text} - ${_currentQuote!.author}';
    Clipboard.setData(ClipboardData(text: quoteText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quote copied to clipboard!'),
        duration: Duration(seconds: 2),
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

  // Generate affirmation from current quote
  Future<void> _generateAffirmation() async {
    if (_currentQuote == null) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Generating affirmation...'),
          ],
        ),
      ),
    );
    
    try {
      final affirmation = await AffirmationService.generateAffirmation(
        _currentQuote!,
        _currentQuote!.tradition,
      );
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      if (affirmation != null) {
        // Show affirmation dialog with options
        if (mounted) {
          _showAffirmationDialog(affirmation);
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate affirmation. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating affirmation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Show affirmation dialog with copy and save options
  void _showAffirmationDialog(String affirmation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✨ Your Personal Affirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              affirmation,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Based on: "${_currentQuote!.text}"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              '- ${_currentQuote!.author} [${_currentQuote!.tradition}]',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: affirmation));
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Affirmation copied to clipboard!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await AffirmationService.instance.saveAffirmation(affirmation, _currentQuote!);
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Affirmation saved to notepad!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Navigate to notepad screen
  void _openNotepad() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotepadScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Log the source for debugging, but do not show in UI
    final actualSource = HiveQuoteService.useAIQuotes ? 'AI' : 'Local';
    print('[QuoteScreen] Source: $actualSource');
    print('[QuoteScreen] Current quote: ${_currentQuote?.text ?? 'null'}');
    print('[QuoteScreen] Current quote ID: ${_currentQuote?.id ?? 'null'}');
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
                      ? (() {
                          print('[QuoteScreen] Quote card: _currentQuote is null, showing SizedBox.shrink()');
                          return const SizedBox.shrink();
                        })()
                      : (() {
                          print('[QuoteScreen] Quote card: Rendering quote "${_currentQuote!.text}"');
                          print('[QuoteScreen] Animation values - scale: ${_scaleAnimation.value}, opacity: ${_fadeAnimation.value}');
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Container(
                                key: ValueKey(_currentQuote!.id),
                                constraints: const BoxConstraints(maxWidth: 480),
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.03),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.01),
                                      blurRadius: 8,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.015),
                                            Colors.white.withOpacity(0.005),
                                            Colors.white.withOpacity(0.01),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.02),
                                          width: 0.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.02),
                                            blurRadius: 10,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 6),
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.01),
                                            blurRadius: 6,
                                            spreadRadius: 0,
                                            offset: const Offset(0, -2),
                                          ),
                                        ],
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
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 20,
                                                  color: Colors.black87,
                                                  offset: const Offset(0, 4),
                                                ),
                                                Shadow(
                                                  blurRadius: 16,
                                                  color: Colors.black54,
                                                  offset: const Offset(0, 2),
                                                ),
                                                Shadow(
                                                  blurRadius: 12,
                                                  color: Colors.black38,
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
                                              color: Colors.white,
                                              fontStyle: FontStyle.italic,
                                              letterSpacing: 1.0,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 16,
                                                  color: Colors.black87,
                                                  offset: const Offset(0, 3),
                                                ),
                                                Shadow(
                                                  blurRadius: 12,
                                                  color: Colors.black54,
                                                  offset: const Offset(0, 2),
                                                ),
                                                Shadow(
                                                  blurRadius: 8,
                                                  color: Colors.black38,
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
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                              letterSpacing: 0.8,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 14,
                                                  color: Colors.black87,
                                                  offset: const Offset(0, 2),
                                                ),
                                                Shadow(
                                                  blurRadius: 10,
                                                  color: Colors.black54,
                                                  offset: const Offset(0, 1),
                                                ),
                                                Shadow(
                                                  blurRadius: 6,
                                                  color: Colors.black38,
                                                  offset: const Offset(0, 0.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // Affirmation Display
                                          if (_currentQuote!.affirmation != null && _currentQuote!.affirmation!.isNotEmpty) ...[
                                            const SizedBox(height: 20),
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.purple.withOpacity(0.1),
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.auto_awesome,
                                                        color: Colors.purple.shade300,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Your Affirmation',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.purple.shade300,
                                                          fontWeight: FontWeight.w600,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    _currentQuote!.affirmation!,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w400,
                                                      fontStyle: FontStyle.italic,
                                                      height: 1.4,
                                                      shadows: [
                                                        Shadow(
                                                          blurRadius: 12,
                                                          color: Colors.black87,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                        Shadow(
                                                          blurRadius: 8,
                                                          color: Colors.black54,
                                                          offset: const Offset(0, 1),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          
                                          const SizedBox(height: 20),
                                          
                                          // Heart Button for Favorites
                                          ValueListenableBuilder(
                                            valueListenable: Hive.box('favorites').listenable(),
                                            builder: (context, box, child) {
                                              final isFavorited = box.get(_currentQuote!.id) ?? false;
                                              return IconButton(
                                                icon: Icon(
                                                  isFavorited ? Icons.favorite : Icons.favorite_border,
                                                  color: isFavorited ? Colors.red.shade400 : Colors.white,
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
                          );
                        })(),
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
                    
                    // Affirmation Button
                    FloatingActionButton(
                      onPressed: _generateAffirmation,
                      backgroundColor: Colors.purple.shade400,
                      child: const Icon(Icons.auto_awesome, color: Colors.white),
                    ),
                    
                    // Notepad Button
                    FloatingActionButton.small(
                      onPressed: _openNotepad,
                      backgroundColor: Colors.orange.shade400,
                      child: const Icon(Icons.note, color: Colors.white),
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
                
                const SizedBox(height: 24),
                
                // Pro Features Banner
                _buildProFeaturesBanner(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // GlassMorphismCard widget
  Widget _buildGlassMorphismCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // Pro Features Banner
  Widget _buildProFeaturesBanner() {
    return _buildGlassMorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon and title
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                Text(
                  "Pro",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: _textShadows,
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // Compact feature list
            Expanded(
              child: Row(
                children: [
                  _buildCompactFeature("Daily", Icons.notifications_active),
                  const SizedBox(width: 8),
                  _buildCompactFeature("Voice", Icons.record_voice_over),
                  const SizedBox(width: 8),
                  _buildCompactFeature("Affirm", Icons.psychology),
                ],
              ),
            ),
            
            // Compact CTA
            FilledButton(
              onPressed: () => _showWaitlistDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurple.withOpacity(0.7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text("Join", style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for feature rows
  Widget _buildFeatureRow(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white70),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              shadows: _textShadows,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for compact features
  Widget _buildCompactFeature(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
            shadows: _textShadows,
          ),
        ),
      ],
    );
  }

  // Waitlist Dialog
  void _showWaitlistDialog(BuildContext context) {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Get Early Access to Pro"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Be the first to unlock:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildFeatureBullet("Daily reminders"),
            _buildFeatureBullet("Voice narration"),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: "your@email.com",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Not now"),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text("Join Waitlist"),
            onPressed: () {
              if (_isValidEmail(emailController.text)) {
                _saveEmail(emailController.text);
                Navigator.pop(context);
                _showThankYouSnackbar(context);
              }
            },
          ),
        ],
      ),
    );
  }

  // Helper widget for feature bullets in dialog
  Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
  }

  Future<void> _saveEmail(String email) async {
    final box = Hive.box('waitlist');
    final emails = box.get('emails', defaultValue: <String>[]) as List<String>;
    if (!emails.contains(email)) {
      emails.add(email);
      await box.put('emails', emails);
    }
    
    // Optional: Sync to your backend (you can implement connectivity check later)
    try {
      await http.post(
        Uri.parse('https://your-api.com/waitlist'),
        body: jsonEncode({'email': email, 'app_version': '1.0.0'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      // Silently fail if backend is not available
      print('Backend sync failed: $e');
    }
  }

  // Show thank you snackbar
  void _showThankYouSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Thanks! We'll be in touch when Pro features launch."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
} 