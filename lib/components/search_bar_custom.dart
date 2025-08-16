import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class SearchBarCustom extends StatefulWidget {
  final Function(String) onCitySelected;

  const SearchBarCustom({super.key, required this.onCitySelected});

  @override
  State<SearchBarCustom> createState() => _SearchBarCustomState();
}

class _SearchBarCustomState extends State<SearchBarCustom> {
  // Controller is now part of the state, ensuring it persists across rebuilds.
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // Properly dispose of the controller to prevent memory leaks.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder provides the parent's constraints for responsive sizing.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerWidth = constraints.maxWidth;

        // Calculate all UI dimensions proportionally based on the available width.
        // Use .clamp() to define sensible minimum and maximum sizes.
        final double margin = (containerWidth * 0.05).clamp(15.0, 30.0);
        final double horizontalPadding = (containerWidth * 0.04).clamp(
          12.0,
          25.0,
        );
        final double verticalPadding = (containerWidth * 0.005).clamp(1.0, 4.0);
        final double fontSize = (containerWidth * 0.04).clamp(15.0, 20.0);
        final double iconSize = (containerWidth * 0.07).clamp(26.0, 32.0);
        final double borderWidth = (containerWidth * 0.01).clamp(3.0, 5.0);
        final double shadowOffset = (containerWidth * 0.02).clamp(6.0, 10.0);

        return Container(
          margin: EdgeInsets.all(margin),
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: GoogleFonts.bangers(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search City',
                    hintStyle: GoogleFonts.bangers(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      color: Colors.black.withOpacity(0.5),
                      letterSpacing: 1.5,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    // Logic remains unchanged.
                    if (value.trim().isNotEmpty) {
                      widget.onCitySelected(value.trim());
                    }
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Logic remains unchanged.
                  if (_controller.text.trim().isNotEmpty) {
                    widget.onCitySelected(_controller.text.trim());
                    // Hide keyboard after search
                    FocusScope.of(context).unfocus();
                  }
                },
                child: Icon(Icons.search, color: Colors.black, size: iconSize),
              ),
            ],
          ),
        );
      },
    );
  }
}
