import 'package:flutter/material.dart';

import 'package:loud_cast/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoudCast',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
