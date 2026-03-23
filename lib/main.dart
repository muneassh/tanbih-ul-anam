import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'models/salat_model.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive with appropriate directory based on platform
  if (kIsWeb) {
    // For web, use a different approach - Hive web uses IndexedDB
    await Hive.initFlutter();
  } else {
    // For mobile, use application documents directory
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }
  
  Hive.registerAdapter(SalatModelAdapter());
  await Hive.openBox<SalatModel>('salawat');
  await Hive.openBox('settings');
  await Hive.openBox('bookmarks');
  
  // Initialize ads only on mobile
  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      print('Ads initialization failed: $e');
    }
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تنبيه الأنام',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoArabic',
        primaryColor: const Color(0xFF0A5C36),
        scaffoldBackgroundColor: const Color(0xFFF5E8C7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A5C36), 
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}