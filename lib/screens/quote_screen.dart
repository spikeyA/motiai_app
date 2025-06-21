import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../services/quote_service.dart';
import '../services/image_service.dart';

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
    });
    final prompt = buildPrompt("${quote.tradition} ${quote.category}");
    final url = await DeepAIGenerator.generateImage(prompt);
    setState(() {
      _backgroundImageUrl = url;
      _isLoadingImage = false;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
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

  Color _getTraditionColor(String tradition) {
    switch (tradition) {
      case 'Buddhist':
        return Colors.orange.shade300;
      case 'Sufi':
        return Colors.purple.shade300;
      case 'Zen':
        return Colors.teal.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // AI-generated background image
          if (_backgroundImageUrl != null)
            Positioned.fill(
              child: Image.network(
                _backgroundImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200),
              ),
            ),
          // Loading spinner overlay
          if (_isLoadingImage)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          // Dark overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // App Title
                  Text(
                    'MotiAI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wisdom from Ancient Traditions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Quote Card
                  Expanded(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Align(
                              alignment: Alignment.center,
                              widthFactor: 0.7,
                              // Remove heightFactor for dynamic height
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 480),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 24),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                                        mainAxisAlignment: MainAxisAlignment.center,
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
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w300,
                                              height: 1.4,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(0, 2)),
                                              ],
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
                                              color: Colors.white.withOpacity(0.85),
                                              fontStyle: FontStyle.italic,
                                              shadows: const [
                                                Shadow(blurRadius: 6, color: Colors.black38, offset: Offset(0, 1)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // Category
                                          Text(
                                            _currentQuote.category,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(0.7),
                                              fontWeight: FontWeight.w400,
                                              shadows: const [
                                                Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 1)),
                                              ],
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
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
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
          ),
        ],
      ),
    );
  }

  void _showTraditionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Tradition'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: QuoteService.getTraditions().map((tradition) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getTraditionColor(tradition),
                child: Text(
                  tradition[0],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(tradition),
              onTap: () {
                Navigator.pop(context);
                _generateQuoteByTradition(tradition);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
} 