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
    'Taoism': 'assets/images/taoism.jpg',
    'Stoicism': 'assets/images/stoicism.jpg',
    'Indigenous Wisdom': 'assets/images/indigenous.jpg',
    'Mindful Tech': 'assets/images/tech.jpg',
    'Eco-Spirituality': 'assets/images/eco.jpg',
    'Poetic Sufism': 'assets/images/poetic_sufi.jpg',
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

    // Taoism Quotes
    Quote(
      id: "taoism_flow",
      text: "The journey of a thousand miles begins with one step.",
      author: "Lao Tzu",
      tradition: "Taoism",
      category: "Flow",
      image: 'assets/images/taoism.jpg',
    ),
    Quote(
      id: "taoism_wisdom",
      text: "Knowing others is intelligence; knowing yourself is true wisdom.",
      author: "Lao Tzu",
      tradition: "Taoism",
      category: "Wisdom",
      image: 'assets/images/taoism.jpg',
    ),
    Quote(
      id: "taoism_harmony",
      text: "Nature does not hurry, yet everything is accomplished.",
      author: "Lao Tzu",
      tradition: "Taoism",
      category: "Harmony",
      image: 'assets/images/taoism.jpg',
    ),
    Quote(
      id: "taoism_simplicity",
      text: "Simplicity, patience, compassion. These three are your greatest treasures.",
      author: "Lao Tzu",
      tradition: "Taoism",
      category: "Simplicity",
      image: 'assets/images/taoism.jpg',
    ),
    Quote(
      id: "taoism_balance",
      text: "When you are content to be simply yourself and don't compare or compete, everybody will respect you.",
      author: "Lao Tzu",
      tradition: "Taoism",
      category: "Balance",
      image: 'assets/images/taoism.jpg',
    ),

    // Stoicism Quotes
    Quote(
      id: "stoicism_control",
      text: "The happiness of your life depends upon the quality of your thoughts.",
      author: "Marcus Aurelius",
      tradition: "Stoicism",
      category: "Control",
      image: 'assets/images/stoicism.jpg',
    ),
    Quote(
      id: "stoicism_resilience",
      text: "The impediment to action advances action. What stands in the way becomes the way.",
      author: "Marcus Aurelius",
      tradition: "Stoicism",
      category: "Resilience",
      image: 'assets/images/stoicism.jpg',
    ),
    Quote(
      id: "stoicism_virtue",
      text: "Waste no more time arguing about what a good man should be. Be one.",
      author: "Marcus Aurelius",
      tradition: "Stoicism",
      category: "Virtue",
      image: 'assets/images/stoicism.jpg',
    ),
    Quote(
      id: "stoicism_present",
      text: "Do not disturb yourself by picturing your life as a whole. Live the present moment wisely and earnestly.",
      author: "Marcus Aurelius",
      tradition: "Stoicism",
      category: "Present",
      image: 'assets/images/stoicism.jpg',
    ),
    Quote(
      id: "stoicism_acceptance",
      text: "Accept the things to which fate binds you, and love the people with whom fate brings you together.",
      author: "Marcus Aurelius",
      tradition: "Stoicism",
      category: "Acceptance",
      image: 'assets/images/stoicism.jpg',
    ),

    // Indigenous Wisdom Quotes
    Quote(
      id: "indigenous_connection",
      text: "We do not inherit the Earth from our ancestors; we borrow it from our children.",
      author: "Native American Proverb",
      tradition: "Indigenous Wisdom",
      category: "Connection",
      image: 'assets/images/indigenous.jpg',
    ),
    Quote(
      id: "indigenous_community",
      text: "It takes a thousand voices to tell a single story.",
      author: "Native American Proverb",
      tradition: "Indigenous Wisdom",
      category: "Community",
      image: 'assets/images/indigenous.jpg',
    ),
    Quote(
      id: "indigenous_harmony",
      text: "Treat the Earth well. It was not given to you by your parents, it was loaned to you by your children.",
      author: "Native American Proverb",
      tradition: "Indigenous Wisdom",
      category: "Harmony",
      image: 'assets/images/indigenous.jpg',
    ),
    Quote(
      id: "indigenous_wisdom",
      text: "Listen to the wind, it talks. Listen to the silence, it speaks. Listen to your heart, it knows.",
      author: "Native American Proverb",
      tradition: "Indigenous Wisdom",
      category: "Wisdom",
      image: 'assets/images/indigenous.jpg',
    ),
    Quote(
      id: "indigenous_balance",
      text: "The greatest strength is gentleness.",
      author: "Native American Proverb",
      tradition: "Indigenous Wisdom",
      category: "Balance",
      image: 'assets/images/indigenous.jpg',
    ),

    // Mindful Tech Quotes
    Quote(
      id: "tech_mindfulness",
      text: "Technology is best when it brings people together.",
      author: "Matt Mullenweg",
      tradition: "Mindful Tech",
      category: "Mindfulness",
      image: 'assets/images/tech.jpg',
    ),
    Quote(
      id: "tech_balance",
      text: "The real problem is not whether machines think but whether men do.",
      author: "B.F. Skinner",
      tradition: "Mindful Tech",
      category: "Balance",
      image: 'assets/images/tech.jpg',
    ),
    Quote(
      id: "tech_connection",
      text: "The Internet is not just one thing, it's a collection of things – of numerous communications networks that all speak the same digital language.",
      author: "Tim Berners-Lee",
      tradition: "Mindful Tech",
      category: "Connection",
      image: 'assets/images/tech.jpg',
    ),
    Quote(
      id: "tech_presence",
      text: "The most important single ingredient in the formula of success is knowing how to get along with people.",
      author: "Theodore Roosevelt",
      tradition: "Mindful Tech",
      category: "Presence",
      image: 'assets/images/tech.jpg',
    ),
    Quote(
      id: "tech_awareness",
      text: "The advance of technology is based on making it fit in so that you don't really even notice it, so it's part of everyday life.",
      author: "Bill Gates",
      tradition: "Mindful Tech",
      category: "Awareness",
      image: 'assets/images/tech.jpg',
    ),

    // Eco-Spirituality Quotes
    Quote(
      id: "eco_interconnection",
      text: "The Earth does not belong to us. We belong to the Earth.",
      author: "Chief Seattle",
      tradition: "Eco-Spirituality",
      category: "Interconnection",
      image: 'assets/images/eco.jpg',
    ),
    Quote(
      id: "eco_reverence",
      text: "Look deep into nature, and then you will understand everything better.",
      author: "Albert Einstein",
      tradition: "Eco-Spirituality",
      category: "Reverence",
      image: 'assets/images/eco.jpg',
    ),
    Quote(
      id: "eco_harmony",
      text: "In nature, nothing is perfect and everything is perfect. Trees can be contorted, bent in weird ways, and they're still beautiful.",
      author: "Alice Walker",
      tradition: "Eco-Spirituality",
      category: "Harmony",
      image: 'assets/images/eco.jpg',
    ),
    Quote(
      id: "eco_consciousness",
      text: "The environment is where we all meet; where we all have a mutual interest; it is the one thing all of us share.",
      author: "Lady Bird Johnson",
      tradition: "Eco-Spirituality",
      category: "Consciousness",
      image: 'assets/images/eco.jpg',
    ),
    Quote(
      id: "eco_stewardship",
      text: "What we are doing to the forests of the world is but a mirror reflection of what we are doing to ourselves and to one another.",
      author: "Mahatma Gandhi",
      tradition: "Eco-Spirituality",
      category: "Stewardship",
      image: 'assets/images/eco.jpg',
    ),

    // Poetic Sufism Quotes
    Quote(
      id: "poetic_sufi_mystery",
      text: "The wound is the place where the Light enters you.",
      author: "Rumi",
      tradition: "Poetic Sufism",
      category: "Mystery",
      image: 'assets/images/poetic_sufi.jpg',
    ),
    Quote(
      id: "poetic_sufi_union",
      text: "Where there is ruin, there is hope for a treasure.",
      author: "Rumi",
      tradition: "Poetic Sufism",
      category: "Union",
      image: 'assets/images/poetic_sufi.jpg',
    ),
    Quote(
      id: "poetic_sufi_ecstasy",
      text: "When you do things from your soul, you feel a river moving in you, a joy.",
      author: "Rumi",
      tradition: "Poetic Sufism",
      category: "Ecstasy",
      image: 'assets/images/poetic_sufi.jpg',
    ),
    Quote(
      id: "poetic_sufi_divine",
      text: "Silence is the language of God, all else is poor translation.",
      author: "Rumi",
      tradition: "Poetic Sufism",
      category: "Divine",
      image: 'assets/images/poetic_sufi.jpg',
    ),
    Quote(
      id: "poetic_sufi_awakening",
      text: "What you seek is seeking you.",
      author: "Rumi",
      tradition: "Poetic Sufism",
      category: "Awakening",
      image: 'assets/images/poetic_sufi.jpg',
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