import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

import 'package:loud_cast/screens/start_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // NEW: A CurvedAnimation to make the repeating animation feel more natural.
  late final Animation<double> _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 500,
      ), // Slightly longer duration for a smoother feel
    );

    // Apply an easing curve to the controller's animation.
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.repeat(
      reverse: true,
    ); // Creates the seamless back-and-forth animation

    _initializeApp();
  }

  // This function handles the app's startup logic (unchanged).
  Future<void> _initializeApp() async {
    await Future.wait([
      _precacheAssets(),
      Future.delayed(const Duration(seconds: 3)),
    ]);
    if (mounted) {
      _navigateToHome();
    }
  }

  // Pre-loads essential assets (unchanged).
  Future<void> _precacheAssets() async {
    await Future.wait(
      [
        'lib/assets/animations/sunny.json',
        'lib/assets/animations/rainy.json',
        'lib/assets/animations/cloudy.json',
      ].map((asset) => rootBundle.load(asset)),
    );
  }

  // Navigation logic (unchanged).
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (_, animation, __) {
          return FadeTransition(opacity: animation, child: const StartScreen());
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // --- Responsive Calculations (unchanged) ---
            final screenWidth = constraints.maxWidth;
            final fontSize = (screenWidth * 0.09).clamp(30.0, 50.0);
            final horizontalPadding = (screenWidth * 0.1).clamp(20.0, 60.0);
            final verticalPadding = (screenWidth * 0.05).clamp(10.0, 30.0);
            final borderWidth = (screenWidth * 0.01).clamp(3.0, 5.0);
            final shadowOffset = (screenWidth * 0.02).clamp(6.0, 10.0);

            // NEW: Define a Tween to animate the shadow's offset smoothly.
            final offsetTween = Tween<Offset>(
              begin: Offset.zero,
              end: Offset(shadowOffset, shadowOffset),
            );

            // Use the curved animation for a smoother effect.
            return AnimatedBuilder(
              animation: _curvedAnimation,
              builder: (context, child) {
                // The animation value (0.0 to 1.0) drives both opacity and offset.
                final animationValue = _curvedAnimation.value;
                final shadowColor = isDark ? Colors.white : Colors.black;

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    border: Border.all(
                      color: isDark ? Colors.white : Colors.black,
                      width: borderWidth,
                    ),
                    // The shadow is now always present but its properties are animated.
                    boxShadow: [
                      BoxShadow(
                        // Animate opacity by tying it to the animation value.
                        color: shadowColor.withOpacity(animationValue),
                        // Animate the offset using the tween.
                        offset: offsetTween.evaluate(_curvedAnimation),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Text(
                'LoudCast',
                style: GoogleFonts.bangers(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
