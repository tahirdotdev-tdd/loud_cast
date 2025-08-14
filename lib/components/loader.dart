import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Loader extends StatefulWidget {
  const Loader({super.key});

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // NEW: A CurvedAnimation makes the repeating effect feel more natural.
  late final Animation<double> _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Duration set as requested.
    );

    // Apply an easing curve to the controller's animation for a smoother feel.
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.repeat(reverse: true); // Creates the seamless back-and-forth animation.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // --- Responsive Calculations (unchanged) ---
        final double containerWidth = constraints.maxWidth;
        final double fontSize = (containerWidth * 0.1).clamp(28.0, 36.0);
        final double horizontalPadding = (containerWidth * 0.05).clamp(15.0, 25.0);
        final double verticalPadding = (containerWidth * 0.025).clamp(8.0, 15.0);
        final double borderWidth = (containerWidth * 0.01).clamp(3.0, 5.0);
        final double shadowOffset = (containerWidth * 0.02).clamp(6.0, 10.0);

        // NEW: A Tween to animate the shadow's offset smoothly from hidden to visible.
        final offsetTween = Tween<Offset>(
          begin: Offset.zero,
          end: Offset(shadowOffset, shadowOffset),
        );

        // AnimatedBuilder efficiently rebuilds only what's necessary for the animation.
        return AnimatedBuilder(
          animation: _curvedAnimation,
          builder: (context, child) {
            // The animation value (from 0.0 to 1.0) now drives the shadow's properties.
            final animationValue = _curvedAnimation.value;

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: borderWidth),
                // The shadow is now always present, but its properties are animated.
                boxShadow: [
                  BoxShadow(
                    // Animate the shadow's opacity by tying it to the animation value.
                    color: Colors.black.withOpacity(animationValue),
                    // Animate the offset using the tween and the curved animation.
                    offset: offsetTween.evaluate(_curvedAnimation),
                  )
                ],
              ),
              child: child, // The static Text widget is passed as the child.
            );
          },
          child: Text(
            'LOUDCASTING . . .', // Updated text
            style: GoogleFonts.bangers(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 1.5,
            ),
          ),
        );
      },
    );
  }
}