import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForecastGrid extends StatelessWidget {
  final List forecast;
  const ForecastGrid({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder provides parent constraints for creating a responsive UI.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerWidth = constraints.maxWidth;

        // --- Responsive Calculations ---
        // Calculate all UI dimensions proportionally based on the available width.
        // Use .clamp() to define sensible minimum and maximum sizes.
        final double margin = (containerWidth * 0.04).clamp(12.0, 20.0);
        final double padding = (containerWidth * 0.03).clamp(8.0, 15.0);
        final double mainBorderWidth = (containerWidth * 0.01).clamp(3.0, 5.0);
        final double mainShadowOffset = (containerWidth * 0.02).clamp(
          6.0,
          10.0,
        );

        // The container height is now proportional to its width to maintain aspect ratio.
        final double containerHeight = containerWidth * 0.55;

        // Calculate sizes for the inner grid boxes.
        final double boxWidth =
            (containerWidth - (padding * 2)) /
            3.5; // Adjust divisor for spacing
        final double boxHeight = (containerHeight - (padding * 2)) / 2.8;
        final double boxBorderWidth = (containerWidth * 0.01).clamp(2.0, 4.0);
        final double boxShadowOffset = (containerWidth * 0.01).clamp(3.0, 5.0);
        final double fontSize = (boxWidth * 0.20).clamp(14.0, 18.0);

        return Container(
          margin: EdgeInsets.all(margin),
          height: containerHeight,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: mainBorderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(mainShadowOffset, mainShadowOffset),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // --- Day Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (i) {
                  final dayText = forecast.length > i
                      ? "Day ${forecast[i]['day']}"
                      : "-";
                  return _gridBoxContent(
                    text: dayText,
                    width: boxWidth,
                    height: boxHeight,
                    borderWidth: boxBorderWidth,
                    shadowOffset: boxShadowOffset,
                    fontSize: fontSize,
                  );
                }),
              ),
              // --- Data Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (i) {
                  final contentText = forecast.length > i
                      ? "${forecast[i]['temperature']}\n${forecast[i]['wind']}" // Use \n for better wrapping
                      : "-";
                  return _gridBoxContent(
                    text: contentText,
                    width: boxWidth,
                    height: boxHeight,
                    borderWidth: boxBorderWidth,
                    shadowOffset: boxShadowOffset,
                    fontSize: fontSize,
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  // A reusable helper widget for the inner grid boxes.
  // It now accepts all styling properties to be responsive.
  Widget _gridBoxContent({
    required String text,
    required double width,
    required double height,
    required double borderWidth,
    required double shadowOffset,
    required double fontSize,
  }) {
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4), // Add a little padding for text
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
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.bangers(
          fontSize: fontSize,
          color: Colors.black,
          letterSpacing: 1.2,
        ),
        // Allows text to fit if it's too long
        softWrap: true,
      ),
    );
  }
}
