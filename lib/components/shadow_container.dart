import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ShadowContainer extends StatelessWidget {
  const ShadowContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // The date formatting logic remains the same.
    final String currentDate = DateFormat('d MMMM y').format(DateTime.now());

    // LayoutBuilder provides the constraints of the parent widget,
    // which we use to make our UI responsive.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic sizes based on the available width.
        final double containerWidth = constraints.maxWidth;

        // Scale font size, padding, and other properties proportionally.
        // Use .clamp() to set sensible min and max limits.
        final double fontSize = (containerWidth * 0.05).clamp(14.0, 20.0);
        final double horizontalPadding = (containerWidth * 0.1).clamp(20.0, 40.0);
        final double verticalPadding = (containerWidth * 0.03).clamp(8.0, 15.0);
        final double borderWidth = (containerWidth * 0.01).clamp(3.0, 5.0);
        final double shadowOffset = (containerWidth * 0.02).clamp(6.0, 10.0);

        return Container(
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
              )
            ],
          ),
          child: Text(
            currentDate,
            textAlign: TextAlign.center, // Ensures text is centered nicely.
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