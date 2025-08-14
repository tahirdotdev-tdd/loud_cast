import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:loud_cast/colors/colors.dart';
import 'package:loud_cast/components/neobrutal_tabbar.dart';
import 'package:loud_cast/components/search_bar_custom.dart';
import 'package:loud_cast/components/shadow_container.dart';
import 'package:loud_cast/components/forecast_grid.dart';
import 'package:loud_cast/components/status_box.dart';
import 'package:loud_cast/components/loader.dart';

import '../models/weather_model.dart';
import '../providers/weather_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The provider now initializes itself, making this setup cleaner.
    return ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          final backgroundColor = _getBackgroundColor(provider.weatherData?.status);
          return Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              child: NeobrutalTabbar(
                tabs: const ['Weather', 'About'],
                tabViews: const [WeatherView(), AboutView()],
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
    if (lowerStatus.contains("sun") || lowerStatus.contains("clear")) return sunnyBackgroundColor;
    if (lowerStatus.contains("cloud")) return cloudBackgroundColor;
    return Colors.blueGrey;
  }
}

// -- The Weather View Widget --
class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    // REMOVED: The provider now fetches initial data automatically.
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  String _getLottieForStatus(String? status) {
    if (status == null) return 'lib/assets/animations/cloudy.json';
    String lowerStatus = status.toLowerCase();
    if (lowerStatus.contains("rain")) return 'lib/assets/animations/rainy.json';
    if (lowerStatus.contains("sun") || lowerStatus.contains("clear")) return 'lib/assets/animations/sunny.json';
    if (lowerStatus.contains("cloud")) return 'lib/assets/animations/cloudy.json';
    return 'lib/assets/animations/cloudy.json';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const ShadowContainer(),
              SearchBarCustom(
                  onCitySelected: (newCity) => provider.fetchWeatherForCity(newCity)),
              const SizedBox(height: 10),
              // Use the last searched city for the title for consistency.
              Text(
                provider.lastSearchedCity,
                style: GoogleFonts.bangers(
                    fontSize: 25,
                    color: Colors.black,
                    letterSpacing: 2.5,
                    shadows: [
                      Shadow(color: Colors.white.withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4),
                    ]),
              ),
              if (provider.isLoading)
                const Padding(padding: EdgeInsets.symmetric(vertical: 100.0), child: Loader())
              // NEW: Pass the provider to the error widget.
              else if (provider.error != null)
                _buildErrorWidget(provider.error!, provider)
              else if (provider.weatherData != null)
                  _buildWeatherDataWidget(provider.weatherData!)
            ],
          ),
        );
      },
    );
  }

  // NEW: The error widget is now actionable.
  Widget _buildErrorWidget(String error, WeatherProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
          const SizedBox(height: 10),
          Text(
            error,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Retry Button
          GestureDetector(
            onTap: () => provider.fetchWeatherForCity(provider.lastSearchedCity),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5))],
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.bangers(fontSize: 18, color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWeatherDataWidget(WeatherData data) {
    final lottieAsset = _getLottieForStatus(data.status);
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final lottieSize = (screenWidth * 0.4).clamp(120.0, 200.0);
        final tempFontSize = (screenWidth * 0.06).clamp(20.0, 28.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(lottieAsset, width: lottieSize, height: lottieSize, repeat: true, controller: _lottieController,
              onLoaded: (composition) {
                _lottieController
                  ..duration = composition.duration
                  ..repeat();
              },
            ),
            const SizedBox(height: 20),
            Text(data.temperature, style: GoogleFonts.bangers(fontSize: tempFontSize)),
            const SizedBox(height: 10),
            StatusBox(status: data.status),
            const SizedBox(height: 10),
            ForecastGrid(forecast: data.forecast.map((f) => f.toJson()).toList()),
          ],
        );
      },
    );
  }
}

// -- The About View Widget (Remains the same) --
class AboutView extends StatelessWidget {
  // ... no changes needed here ...
  const AboutView({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch via url_launcher';
      }
    } catch (e) {
      if (Platform.isAndroid) {
        await AndroidIntent(action: 'action_view', data: url).launch();
      } else {
        debugPrint('Could not launch $url: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using LayoutBuilder to make padding and font sizes responsive
    return LayoutBuilder(builder: (context, constraints) {
      final double padding = (constraints.maxWidth * 0.05).clamp(16.0, 32.0);
      final double titleSize = (constraints.maxWidth * 0.12).clamp(40.0, 60.0);
      final double questionSize = (constraints.maxWidth * 0.05).clamp(18.0, 24.0);
      final double answerSize = (constraints.maxWidth * 0.04).clamp(15.0, 20.0);

      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Text('About', style: GoogleFonts.bangers(fontSize: titleSize, color: Colors.black)),
              Text("Made with ❤️ by Tahir", style: GoogleFonts.kalam(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 24),
              // Re-using the original QA item structure but with responsive fonts
              _qaItem(
                  "What is LoudCast?",
                  Text("LoudCast is a Neo-Brutalist style weather application that gives you real-time weather updates in a bold, minimalistic, and fun design.", style: GoogleFonts.kalam(fontSize: answerSize, color: Colors.black)),
                  questionSize
              ),
              _qaItem(
                  "Developer",
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hi! I'm Tahir Hassan, a Flutter developer with a passion for creating bold, minimalistic apps in Neo-Brutalist style. I love experimenting with animations, Lottie integrations, and custom UI designs to make weather apps fun and interactive.", style: GoogleFonts.kalam(fontSize: answerSize, color: Colors.black)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _openUrl("https://github.com/tahirdotdev-tdd"),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FontAwesomeIcons.github, size: 20),
                            const SizedBox(width: 8),
                            Text("View my GitHub Profile", style: GoogleFonts.kalam(fontSize: answerSize, color: Colors.black, decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _openUrl("https://bit.ly/tahirhassan"),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FontAwesomeIcons.user, size: 20),
                            const SizedBox(width: 8),
                            Text("View my Portfolio", style: GoogleFonts.kalam(fontSize: answerSize, color: Colors.black, decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  questionSize
              ),
              // ... other qaItems ...
            ],
          ),
        ),
      );
    });
  }

  Widget _qaItem(String question, Widget answer, double questionSize) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(4, 4))],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(textAlign: TextAlign.start, question, style: GoogleFonts.bangers(fontSize: questionSize, color: Colors.black)),
          const SizedBox(height: 8),
          answer,
        ],
      ),
    );
  }
}