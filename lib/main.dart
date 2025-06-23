import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/quote_screen.dart';
import 'services/hive_quote_service.dart';
import 'models/quote.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(QuoteAdapter());
  
  // Initialize HiveQuoteService
  await HiveQuoteService.initialize();
  
  // Load environment variables
  try {
    await dotenv.load();
    print('Loading .env from: ${dotenv.env['DEEP_AI_API_KEY'] != null ? 'loaded' : 'not found'}');
  } catch (e) {
    print('No .env file found, continuing without environment variables');
  }
  
  // Request audio permissions only on mobile platforms
  if (Platform.isAndroid || Platform.isIOS) {
    await Permission.microphone.request();
  }
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(MotiAIApp());
}

class MotiAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotiAI',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        fontFamily: 'Inter',
      ),
      home: QuoteScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
