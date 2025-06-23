import 'package:hive/hive.dart';
import '../lib/models/quote.dart';
import 'dart:io';

Future<void> main() async {
  print('🔄 Re-populating Hive with initial quotes (app data directory)...');

  // Use the app's Hive data directory on macOS
  final hiveDir = Platform.environment['HOME']! + '/Library/Containers/com.example.motiaiApp/Data/';
  Hive.init(hiveDir);

  // Register the Quote adapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(QuoteAdapter());
  }

  // Open the quotes box
  final quotesBox = await Hive.openBox<Quote>('quotes');

  // Clear existing quotes
  await quotesBox.clear();

  // Initial quotes (copied from HiveQuoteService)
  final initialQuotes = [
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
      text: "In the beginner's mind there are many possibilities, but in the expert's there are few.",
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

  for (final quote in initialQuotes) {
    await quotesBox.put(quote.id, quote);
  }

  print('✅ Re-populated Hive with [32m${initialQuotes.length}[0m initial quotes.');
  await quotesBox.close();
  print('✅ Done.');
} 