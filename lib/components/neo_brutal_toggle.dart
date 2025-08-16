import 'package:flutter/material.dart';

class NeoBrutalToggle extends StatelessWidget {
  // 1. Add properties to receive state and a callback function
  final bool isOn;
  final ValueChanged<bool> onToggle;

  // 2. Add them to the constructor as required parameters
  const NeoBrutalToggle({
    super.key,
    required this.isOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 3. When tapped, call the callback with the NEW value
      onTap: () => onToggle(!isOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 40,
        decoration: BoxDecoration(
          // 4. Use the 'isOn' property that was passed in
          color: isOn ? Colors.yellow : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.black,
            width: 3, // bold outline
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4), // offset shadow
              blurRadius: 0, // hard shadow (neo-brutal)
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              // Use the 'isOn' property
              left: isOn ? 31 : 5,
              top: 1.5,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  // Use the 'isOn' property
                  color: isOn ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
