import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../components/forecast_grid.dart';
import '../components/loader.dart';
import '../components/search_bar_custom.dart';
import '../components/status_box.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  String _getLottieForStatus(String? status, bool isDay) {
    if (status == null) return 'lib/assets/animations/cloudy.json';
    String lowerStatus = status.toLowerCase();
    if (lowerStatus.contains("rain")) return 'lib/assets/animations/rainy.json';
    if (lowerStatus.contains("sun") || lowerStatus.contains("clear")) {
      return isDay
          ? 'lib/assets/animations/sunny.json'
          : 'lib/assets/animations/night.json';
    }
    if (lowerStatus.contains("cloud")) {
      return 'lib/assets/animations/cloudy.json';
    }
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
              SearchBarCustom(
                onCitySelected: (newCity) =>
                    provider.fetchWeatherForCity(newCity),
              ),
              const SizedBox(height: 10),
              Text(
                provider.lastSearchedCity,
                style: GoogleFonts.bangers(
                  fontSize: 25,
                  color: Colors.black,
                  letterSpacing: 2.5,
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 100.0),
                  child: Loader(),
                )
              else if (provider.error != null)
                _buildErrorWidget(provider.error!, provider)
              else if (provider.weatherData != null)
                _buildWeatherDataWidget(provider.weatherData!, provider),
            ],
          ),
        );
      },
    );
  }

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
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () =>
                provider.fetchWeatherForCity(provider.lastSearchedCity),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(5, 5)),
                ],
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.bangers(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDataWidget(WeatherData data, WeatherProvider provider) {
    final lottieAsset = _getLottieForStatus(data.status, data.isDay);
    const double boxHeight = 110.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final lottieSize = (screenWidth * 0.4).clamp(120.0, 200.0);
        final tempFontSize = (screenWidth * 0.08).clamp(28.0, 40.0);
        final dateFontSize = (screenWidth * 0.04).clamp(14.0, 18.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              lottieAsset,
              width: lottieSize,
              height: lottieSize,
              repeat: true,
              controller: _lottieController,
              onLoaded: (composition) {
                _lottieController
                  ..duration = composition.duration
                  ..repeat();
              },
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                ],
              ),
              child: Text(
                DateFormat('E, d MMM yyyy • hh:mm a').format(data.dateTime),
                style: GoogleFonts.kalam(
                  fontSize: dateFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              provider.formatTemperature(data.tempCelsius),
              style: GoogleFonts.bangers(fontSize: tempFontSize),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: boxHeight,
                      child: StatusBox(status: data.status),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: SizedBox(
                      height: boxHeight,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(5, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              data.isDay
                                  ? 'lib/assets/animations/sunny.json'
                                  : 'lib/assets/animations/night.json',
                              width: 50,
                              height: 40,
                              repeat: true,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              data.isDay ? 'Day' : 'Night',
                              style: GoogleFonts.bangers(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- FINAL MODIFICATION: Format both temp and wind for the grid ---
            ForecastGrid(
              forecast: data.forecast.map((f) {
                return {
                  'day': f.day,
                  // Format the temperature for the forecast day
                  'temperature': provider.formatTemperature(f.tempCelsius),
                  // Format the wind speed for the forecast day
                  'wind': provider.formatWindSpeed(f.windKmh),
                };
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
