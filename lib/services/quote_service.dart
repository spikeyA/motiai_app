class Quote {
  final String id;
  final String text;
  final String author;
  final String tradition;
  final String category;
  final String image;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.tradition,
    required this.category,
    required this.image,
  });
}

class QuoteService {
  static final Map<String, String> _traditionImages = {
    'Buddhist': 'assets/images/buddhist.jpg',
    'Sufi': 'assets/images/sufi.jpg',
    'Zen': 'assets/images/zen.jpg',
  };

  static final List<Quote> _quotes = [
    // Buddhist Quotes
    Quote(
      id: "buddhist_peace",
      text: "Peace comes from within. Do not seek it without.",
      author: "Buddha",
      tradition: "Buddhist",
      category: "Peace",
      image: 'assets/images/buddhist.jpg',
    ),
    Quote(
      id: "buddhist_mindfulness",
      text: "The mind is everything. What you think you become.",
      author: "Buddha",
      tradition: "Buddhist",
      category: "Mindfulness",
      image: 'assets/images/buddhist.jpg',
    ),
    Quote(
      id: "buddhist_truth",
      text: "Three things cannot be long hidden: the sun, the moon, and the truth.",
      author: "Buddha",
      tradition: "Buddhist",
      category: "Truth",
      image: 'assets/images/buddhist.jpg',
    ),
    Quote(
      id: "buddhist_self_love",
      text: "You yourself, as much as anybody in the entire universe, deserve your love and affection.",
      author: "Buddha",
      tradition: "Buddhist",
      category: "Self-Love",
      image: 'assets/images/buddhist.jpg',
    ),
    Quote(
      id: "buddhist_gratitude",
      text: "Health is the greatest gift, contentment the greatest wealth, faithfulness the best relationship.",
      author: "Buddha",
      tradition: "Buddhist",
      category: "Gratitude",
      image: 'assets/images/buddhist.jpg',
    ),
    Quote(
      id: "buddhist_health",
      text: "To keep the body in good health is a duty... otherwise we shall not be able to keep our mind strong and clear.",
      author: "Buddha",
      tradition: "Buddhist",
      category: "Health",
      image: 'assets/images/buddhist.jpg',
    ),
    Quote(
      id: "buddhist_spirituality",
      text: "Just as a candle cannot burn without fire, men cannot live without a spiritual life.",
      author: "Buddha",
      tradition: "Buddhist",
      category: "Spirituality",
      image: 'assets/images/buddhist.jpg',
    ),
    Quote(
      id: "buddhist_happiness",
      text: "Thousands of candles can be lit from a single candle, and the life of the candle will not be shortened. Happiness never decreases by being shared.",
      author: "Buddha",
      tradition: "Buddhist",
      category: "Happiness",
      image: 'assets/images/buddhist.jpg',
    ),

    // Sufi Quotes
    Quote(
      id: "sufi_transformation",
      text: "Yesterday I was clever, so I wanted to change the world. Today I am wise, so I am changing myself.",
      author: "Rumi",
      tradition: "Sufi",
      category: "Transformation",
      image: 'assets/images/sufi.jpg',
    ),
    Quote(
      id: "sufi_destiny",
      text: "What you seek is seeking you.",
      author: "Rumi",
      tradition: "Sufi",
      category: "Destiny",
      image: 'assets/images/sufi.jpg',
    ),
    Quote(
      id: "sufi_healing",
      text: "The wound is the place where the Light enters you.",
      author: "Rumi",
      tradition: "Sufi",
      category: "Healing",
      image: 'assets/images/sufi.jpg',
    ),
    Quote(
      id: "sufi_hope",
      text: "Where there is ruin, there is hope for a treasure.",
      author: "Rumi",
      tradition: "Sufi",
      category: "Hope",
      image: 'assets/images/sufi.jpg',
    ),
    Quote(
      id: "sufi_love",
      text: "Lovers don't finally meet somewhere. They're in each other all along.",
      author: "Rumi",
      tradition: "Sufi",
      category: "Love",
      image: 'assets/images/sufi.jpg',
    ),
    Quote(
      id: "sufi_possibility",
      text: "The garden of the world has no limits, except in your mind.",
      author: "Rumi",
      tradition: "Sufi",
      category: "Possibility",
      image: 'assets/images/sufi.jpg',
    ),
    Quote(
      id: "sufi_joy",
      text: "When you do things from your soul, you feel a river moving in you, a joy.",
      author: "Rumi",
      tradition: "Sufi",
      category: "Joy",
      image: 'assets/images/sufi.jpg',
    ),
    Quote(
      id: "sufi_silence",
      text: "Silence is the language of God, all else is poor translation.",
      author: "Rumi",
      tradition: "Sufi",
      category: "Silence",
      image: 'assets/images/sufi.jpg',
    ),

    // Zen Quotes
    Quote(
      id: "zen_obstacles",
      text: "The obstacle is the path.",
      author: "Zen Proverb",
      tradition: "Zen",
      category: "Obstacles",
      image: 'assets/images/zen.jpg',
    ),
    Quote(
      id: "zen_enlightenment",
      text: "Before enlightenment, chop wood, carry water. After enlightenment, chop wood, carry water.",
      author: "Zen Proverb",
      tradition: "Zen",
      category: "Enlightenment",
      image: 'assets/images/zen.jpg',
    ),
    Quote(
      id: "zen_growth",
      text: "When you reach the top of the mountain, keep climbing.",
      author: "Zen Proverb",
      tradition: "Zen",
      category: "Growth",
      image: 'assets/images/zen.jpg',
    ),
    Quote(
      id: "zen_silence",
      text: "The quieter you become, the more you can hear.",
      author: "Ram Dass",
      tradition: "Zen",
      category: "Silence",
      image: 'assets/images/zen.jpg',
    ),
    Quote(
      id: "zen_learning",
      text: "In the beginner's mind there are many possibilities, but in the expert's there are few.",
      author: "Shunryu Suzuki",
      tradition: "Zen",
      category: "Learning",
      image: 'assets/images/zen.jpg',
    ),
    Quote(
      id: "zen_self_acceptance",
      text: "To be beautiful means to be yourself. You don't need to be accepted by others. You need to accept yourself.",
      author: "Thich Nhat Hanh",
      tradition: "Zen",
      category: "Self-Acceptance",
      image: 'assets/images/zen.jpg',
    ),
    Quote(
      id: "zen_mindfulness",
      text: "Smile, breathe and go slowly.",
      author: "Thich Nhat Hanh",
      tradition: "Zen",
      category: "Mindfulness",
      image: 'assets/images/zen.jpg',
    ),
    Quote(
      id: "zen_present_moment",
      text: "The present moment is filled with joy and happiness. If you are attentive, you will see it.",
      author: "Thich Nhat Hanh",
      tradition: "Zen",
      category: "Present Moment",
      image: 'assets/images/zen.jpg',
    ),
  ];

  static Quote getRandomQuote() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return _quotes[random % _quotes.length];
  }

  static Quote getQuoteByTradition(String tradition) {
    final filteredQuotes = _quotes.where((quote) => quote.tradition == tradition).toList();
    if (filteredQuotes.isEmpty) return getRandomQuote();
    
    final random = DateTime.now().millisecondsSinceEpoch;
    return filteredQuotes[random % filteredQuotes.length];
  }

  static Quote getQuoteByCategory(String category) {
    final filteredQuotes = _quotes.where((quote) => quote.category == category).toList();
    if (filteredQuotes.isEmpty) return getRandomQuote();
    
    final random = DateTime.now().millisecondsSinceEpoch;
    return filteredQuotes[random % filteredQuotes.length];
  }

  static List<String> getTraditions() {
    return _quotes.map((quote) => quote.tradition).toSet().toList();
  }

  static List<String> getCategories() {
    return _quotes.map((quote) => quote.category).toSet().toList();
  }
} 