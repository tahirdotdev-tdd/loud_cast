import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeobrutalTabbar extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> tabViews;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final double borderWidth;

  const NeobrutalTabbar({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.selectedColor = Colors.white,
    this.unselectedColor = const Color(0xFFE0E0E0),
    this.borderWidth = 3,
  });

  @override
  State<NeobrutalTabbar> createState() => _NeobrutalTabbarState();
}

class _NeobrutalTabbarState extends State<NeobrutalTabbar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  // Handle cases where the number of tabs might change.
  @override
  void didUpdateWidget(NeobrutalTabbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != _tabController.length) {
      _tabController.dispose();
      _tabController = TabController(length: widget.tabs.length, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // The helper widget for building a single tab.
  // It now takes responsive values as parameters.
  Widget _neoBrutalTab({
    required String text,
    required bool isSelected,
    required double fontSize,
    required EdgeInsets padding,
    required double shadowOffset,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding,
      decoration: BoxDecoration(
        color: isSelected ? widget.selectedColor : widget.unselectedColor,
        border: Border.all(color: Colors.black, width: widget.borderWidth),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: Colors.black,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
          )
        ]
            : [],
      ),
      child: Text(
        text,
        style: GoogleFonts.bangers(fontSize: fontSize, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to create a responsive UI based on parent constraints.
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Calculate responsive sizes, clamping them to reasonable min/max values.
        final double verticalSpacing = (screenWidth * 0.05).clamp(15.0, 25.0);
        final double horizontalPadding = (screenWidth * 0.02).clamp(6.0, 10.0);
        final double tabFontSize = (screenWidth * 0.04).clamp(15.0, 18.0);
        final double shadowOffset = (screenWidth * 0.01).clamp(3.0, 5.0);
        final EdgeInsets tabPadding = EdgeInsets.symmetric(
          horizontal: (screenWidth * 0.03).clamp(8.0, 15.0),
          vertical: (screenWidth * 0.02).clamp(6.0, 12.0),
        );

        return Column(
          children: [
            SizedBox(height: verticalSpacing),
            // AnimatedBuilder efficiently rebuilds only the tabs when the index changes.
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.tabs.length,
                        (index) => GestureDetector(
                      onTap: () => _tabController.animateTo(index),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _neoBrutalTab(
                          text: widget.tabs[index],
                          isSelected: _tabController.index == index,
                          fontSize: tabFontSize,
                          padding: tabPadding,
                          shadowOffset: shadowOffset,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: verticalSpacing),
            // The Tab content remains unchanged.
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: widget.tabViews,
              ),
            ),
          ],
        );
      },
    );
  }
}