import 'package:hive/hive.dart';
import '../lib/models/quote.dart';
import 'dart:io';

Future<void> main() async {
  print('🔍 Checking number of quotes in Hive (app data directory)...');

  // Use the app's Hive data directory on macOS
  final hiveDir = Platform.environment['HOME']! + '/Library/Containers/com.example.motiaiApp/Data/';
  Hive.init(hiveDir);

  // Register the Quote adapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(QuoteAdapter());
  }

  // Open the quotes box
  final quotesBox = await Hive.openBox<Quote>('quotes');

  // Count the quotes
  final count = quotesBox.length;
  print('📚 Number of quotes in Hive: $count');

  // Print all unique traditions and their counts
  final traditions = <String, int>{};
  for (var quote in quotesBox.values) {
    final t = quote.tradition.trim();
    traditions[t] = (traditions[t] ?? 0) + 1;
  }
  print('Traditions in Hive:');
  traditions.forEach((t, c) => print('  $t: $c'));

  print('✅ Done.');
  await quotesBox.close();
} 