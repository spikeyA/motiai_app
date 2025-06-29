import 'package:hive/hive.dart';

part 'quote.g.dart';

@HiveType(typeId: 0)
class Quote {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String tradition;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String imageUrl;

  @HiveField(6)
  final String? affirmation;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.tradition,
    required this.category,
    this.imageUrl = '',
    this.affirmation,
  });

  // Convert to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'tradition': tradition,
      'category': category,
      'imageUrl': imageUrl,
      'affirmation': affirmation,
    };
  }

  // Create from Map for Hive retrieval
  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      author: map['author'] ?? '',
      tradition: map['tradition'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      affirmation: map['affirmation'],
    );
  }

  // Create a copy with updated affirmation
  Quote copyWith({String? affirmation}) {
    return Quote(
      id: id,
      text: text,
      author: author,
      tradition: tradition,
      category: category,
      imageUrl: imageUrl,
      affirmation: affirmation ?? this.affirmation,
    );
  }

  @override
  String toString() {
    return 'Quote(id: $id, text: $text, author: $author, tradition: $tradition, category: $category, affirmation: $affirmation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quote && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 