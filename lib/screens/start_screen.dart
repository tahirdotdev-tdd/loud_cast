import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueNotifier for more efficient state management
    final isPressed = ValueNotifier<bool>(false);

    void navigateToHome() {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, animation, __) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0), // from left
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: const HomeScreen(),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Making UI elements responsive based on screen width
            final screenWidth = constraints.maxWidth;
            final double fontSize = screenWidth * 0.08; // Responsive font size
            final double horizontalPadding = screenWidth * 0.05;
            final double verticalPadding = screenWidth * 0.025;

            return GestureDetector(
              onTapDown: (_) => isPressed.value = true,
              onTapUp: (_) {
                isPressed.value = false;
                Future.delayed(const Duration(milliseconds: 150), navigateToHome);
              },
              onTapCancel: () => isPressed.value = false,
              child: ValueListenableBuilder<bool>(
                valueListenable: isPressed,
                builder: (context, pressed, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    transform: Matrix4.identity()..scale(pressed ? 0.96 : 1.0),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: pressed
                              ? const Offset(0, 0)
                              : const Offset(8, 8),
                        )
                      ],
                    ),
                    child: child,
                  );
                },
                child: Text(
                  'Start Casting',
                  style: GoogleFonts.bangers(
                    fontSize: fontSize.clamp(25, 50), // Set min and max font size
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}