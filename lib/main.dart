import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/quote_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const envPath = '/Users/aparnashastry/Library/Containers/com.example.motiaiApp/Data/.env';
  print('Loading .env from: $envPath');
  try {
    final contents = await File(envPath).readAsString();
    print('Manual read succeeded:');
    print(contents);
  } catch (e) {
    print('Manual read failed: $e');
  }
  await dotenv.load(fileName: envPath);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotiAI - Wisdom Quotes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'System',
      ),
      home: const QuoteScreen(),
    );
  }
}
