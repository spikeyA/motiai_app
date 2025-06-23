import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'lib/models/quote.dart';

void main() async {
  final hiveDir = '/Users/aparnashastry/Library/Containers/com.example.motiaiApp/Data/Documents';
  Hive.init(hiveDir);
  Hive.registerAdapter(QuoteAdapter());
  var box = await Hive.openBox<Quote>('quotes');
  print('All quotes in Hive:');
  for (var key in box.keys) {
    final quote = box.get(key) as Quote?;
    if (quote != null) {
      print('---');
      print('ID: ${quote.id}');
      print('Text: ${quote.text}');
      print('Author: ${quote.author}');
      print('Tradition: ${quote.tradition}');
      print('Category: ${quote.category}');
      print('Image URL: ${quote.imageUrl}');
    }
  }
  await box.close();
}