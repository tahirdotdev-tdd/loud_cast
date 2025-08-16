import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBox extends StatelessWidget {
  final String status;
  const StatusBox({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to get the constraints of the parent widget,
    // making the component responsive.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate sizes based on the available width.
        final screenWidth = constraints.maxWidth;

        // Responsive font size, clamped to avoid becoming too small or large.
        final double fontSize = (screenWidth * 0.08).clamp(20.0, 28.0);

        // Responsive padding.
        final double horizontalPadding = (screenWidth * 0.1).clamp(30.0, 50.0);
        final double verticalPadding = (screenWidth * 0.03).clamp(8.0, 15.0);

        // Responsive shadow offset.
        final double shadowOffset = (screenWidth * 0.02).clamp(6.0, 10.0);
        final double borderWidth = (screenWidth * 0.01).clamp(3.0, 5.0);

        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(shadowOffset, shadowOffset),
              ),
            ],
          ),
          child: Text(
            status,
            textAlign:
                TextAlign.center, // Center text for better look on all sizes
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
