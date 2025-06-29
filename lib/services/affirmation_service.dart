import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/quote.dart';
import 'hive_quote_service.dart';

class AffirmationService {
  static const String _affirmationsBoxName = 'affirmations';
  late Box<dynamic> _affirmationsBox;
  
  static AffirmationService? _instance;
  
  AffirmationService._();
  
  static AffirmationService get instance {
    _instance ??= AffirmationService._();
    return _instance!;
  }
  
  static Future<void> initialize() async {
    print('[AffirmationService] Initializing...');
    instance._affirmationsBox = await Hive.openBox(_affirmationsBoxName);
    print('[AffirmationService] Initialized successfully');
  }
  
  /// Generate a personalized affirmation from a quote and tradition
  static Future<String?> generateAffirmation(Quote quote, String tradition) async {
    String? apiKey;
    try {
      apiKey = dotenv.env['ANTHROPIC_API_KEY'];
    } catch (e) {
      print('[AffirmationService] .env not loaded - skipping API call.');
      return null;
    }
    
    if (apiKey == null || apiKey.isEmpty) {
      print('[AffirmationService] No API key found for affirmation generation.');
      return null;
    }
    
    // Check if API key is the placeholder value
    if (apiKey == 'your_anthropic_api_key_here') {
      print('[AffirmationService] API key not configured - please add your Anthropic API key to .env file');
      return null;
    }
    
    final prompt = '''
Transform the following quote into 1 to 3 short, first-person affirmations, each starting with "I am" and each on a new line. The affirmations should be inspired by the $tradition tradition and capture the essence of the quote. Make them concise, authentic, and empowering.

Original Quote: "${quote.text}"
Author: ${quote.author}
Tradition: $tradition

Guidelines:
- Each affirmation must start with "I am"
- 1 to 3 affirmations only, each on a new line
- No extra formatting, no numbering, no quotes, no author attribution
- Each affirmation should be 1 sentence, max 12 words
- Return ONLY the affirmations, nothing else
''';
    
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
              'content': prompt
            }
          ]
        }),
      );
      
      print('[AffirmationService] API status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['content']?[0]?['text']?.toString().trim();
        
        if (text != null && text.isNotEmpty) {
          // Clean the text
          String cleanText = text;
          
          // Remove quotation marks
          cleanText = cleanText.replaceAll('"', '').replaceAll('"', '').replaceAll('"', '');
          
          // Remove any author attributions or dashes
          cleanText = cleanText.replaceAll(RegExp(r'\s*-\s*[A-Za-z\s]+$'), '');
          cleanText = cleanText.replaceAll(RegExp(r'\s*-\s*$'), '');
          
          // Trim whitespace
          cleanText = cleanText.trim();
          
          if (cleanText.isNotEmpty) {
            print('[AffirmationService] Generated affirmation: "$cleanText"');
            return cleanText;
          }
        }
      } else if (response.statusCode == 401) {
        print('[AffirmationService] Authentication failed - check your API key');
      } else if (response.statusCode == 429) {
        print('[AffirmationService] Rate limit exceeded - try again later');
      } else {
        print('[AffirmationService] API error: ${response.body}');
      }
    } catch (e) {
      print('[AffirmationService] Exception: ${e.toString()}');
    }
    
    return null;
  }
  
  /// Save affirmation to Hive with timestamp and to the quote
  Future<void> saveAffirmation(String affirmation, Quote originalQuote) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final affirmationData = {
      'id': 'affirmation_$timestamp',
      'text': affirmation,
      'originalQuoteId': originalQuote.id,
      'originalQuoteText': originalQuote.text,
      'originalAuthor': originalQuote.author,
      'tradition': originalQuote.tradition,
      'timestamp': timestamp,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    // Save to affirmations box
    await _affirmationsBox.put('affirmation_$timestamp', affirmationData);
    print('[AffirmationService] Saved affirmation: affirmation_$timestamp');
    
    // Also save to the quote in Hive
    try {
      await HiveQuoteService.instance.saveAffirmationToQuote(originalQuote.id, affirmation);
      print('[AffirmationService] Saved affirmation to quote: ${originalQuote.id}');
    } catch (e) {
      print('[AffirmationService] Error saving affirmation to quote: $e');
    }
  }
  
  /// Get all saved affirmations
  Future<List<Map<String, dynamic>>> getAllAffirmations() async {
    final affirmations = <Map<String, dynamic>>[];
    
    for (var key in _affirmationsBox.keys) {
      final data = _affirmationsBox.get(key);
      if (data is Map<String, dynamic>) {
        affirmations.add(data);
      }
    }
    
    // Sort by timestamp (newest first)
    affirmations.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
    
    return affirmations;
  }
  
  /// Get affirmations count
  int getAffirmationsCount() {
    return _affirmationsBox.length;
  }
  
  /// Delete an affirmation
  Future<void> deleteAffirmation(String id) async {
    await _affirmationsBox.delete(id);
    print('[AffirmationService] Deleted affirmation: $id');
  }
  
  /// Clear all affirmations
  Future<void> clearAllAffirmations() async {
    await _affirmationsBox.clear();
    print('[AffirmationService] Cleared all affirmations');
  }
} 