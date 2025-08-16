import 'package:flutter/material.dart';
import 'package:loud_cast/views/settings_view.dart';
import 'package:provider/provider.dart';
import 'package:loud_cast/colors/colors.dart';
import 'package:loud_cast/components/neobrutal_tabbar.dart';
import '../providers/weather_provider.dart';
import '../views/about_view.dart';
import '../views/weather_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The provider now initializes itself, making this setup cleaner.
    return ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          final backgroundColor = _getBackgroundColor(
            provider.weatherData?.status,
          );
          return Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              child: NeobrutalTabbar(
                tabs: const ['Weather', 'About', 'Settings'],
                tabViews: const [WeatherView(), AboutView(), SettingsView()],
                backgroundColor: backgroundColor,
                unselectedColor: backgroundColor,
                selectedColor: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getBackgroundColor(String? status) {
    if (status == null) return Colors.blueGrey;
    String lowerStatus = status.toLowerCase();
    if (lowerStatus.contains("rain")) return rainBackgroundColor;
    if (lowerStatus.contains("sun") || lowerStatus.contains("clear")) {
      return sunnyBackgroundColor;
    }
    if (lowerStatus.contains("cloud")) return cloudBackgroundColor;
    return Colors.blueGrey;
  }
}
