import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:servease/splash_screen.dart';
import 'package:servease/screens/categories_page.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF0C7210),// Dark Green
          secondary: const Color(0xFF989696),
          tertiary:  Color(0xFFB5E0BD),
          primaryContainer: const Color(0xFF388E3C),
          background: Colors.white,
          surface: const Color(0xFFF5F5F5),
          onPrimary: Colors.white,
          onBackground: const Color(0xFF212121),
          error: const Color(0xFFD32F2F),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF212121)),
          titleTextStyle: TextStyle(
            color: Color(0xFF212121),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        fontFamily: 'Poppins',
      ),
      home: SplashScreen(),
      routes: {
        '/categories': (context) => CategoriesPage(),
      },
    );
  }
}
