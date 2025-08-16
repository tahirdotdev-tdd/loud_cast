import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:loud_cast/components/neo_brutal_toggle.dart';
import '../providers/weather_provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double padding = (constraints.maxWidth * 0.05).clamp(16.0, 32.0);
        final double titleSize = (constraints.maxWidth * 0.12).clamp(
          40.0,
          60.0,
        );
        final double questionSize = (constraints.maxWidth * 0.05).clamp(
          18.0,
          24.0,
        );

        // --- WRAP THE WHOLE COLUMN IN THE CONSUMER ---
        // This makes it easy to add multiple settings without nesting consumers.
        return Consumer<WeatherProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Settings',
                      style: GoogleFonts.bangers(
                        fontSize: titleSize,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Setting 1: Temperature Units ---
                  _qaItem(
                    "Use Fahrenheit",
                    NeoBrutalToggle(
                      isOn: provider.isFahrenheit,
                      onToggle: (newValue) {
                        provider.toggleUnits(newValue);
                      },
                    ),
                    questionSize,
                  ),

                  // --- NEW Setting 2: Wind Speed Units ---
                  _qaItem(
                    "Use MPH for Wind",
                    NeoBrutalToggle(
                      // This assumes you created isMph and toggleWindSpeed in your provider
                      isOn: provider.isMph,
                      onToggle: (newValue) {
                        provider.toggleWindSpeed(newValue);
                      },
                    ),
                    questionSize,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Widget _qaItem(String heading, Widget widget, double questionSize) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      border: Border.all(color: Colors.black, width: 3),
      boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(4, 4))],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            textAlign: TextAlign.start,
            heading,
            style: GoogleFonts.bangers(
              fontSize: questionSize,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 10),
        widget,
      ],
    ),
  );
}
