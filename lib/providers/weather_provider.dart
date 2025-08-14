import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_model.dart';

class WeatherProvider with ChangeNotifier {
  WeatherData? _weatherData;
  WeatherData? get weatherData => _weatherData;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Stores the last city that was searched for, successful or not.
  String _lastSearchedCity = "Berlin";
  String get lastSearchedCity => _lastSearchedCity;

  // NEW: Initializes the provider by loading the last saved city.
  WeatherProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('lastCity');
    // If a city was saved, use it; otherwise, default to Berlin.
    await fetchWeatherForCity(savedCity ?? 'Berlin');
  }

  Future<void> fetchWeatherForCity(String city) async {
    if (city.isEmpty) return;

    _isLoading = true;
    _error = null;
    _lastSearchedCity = city; // Store the city being searched for.
    notifyListeners();

    // 1. Check for Internet Connection
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _error = "No Internet connection. Please check your network.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 2. Proceed with API Calls
    try {
      final geocodingUrl = Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1');
      final geocodingResponse = await http.get(geocodingUrl).timeout(const Duration(seconds: 10));

      if (geocodingResponse.statusCode != 200) {
        throw Exception('Failed to get location data from the server.');
      }

      final geocodingData = json.decode(geocodingResponse.body);
      if (geocodingData['results'] == null || geocodingData['results'].isEmpty) {
        // NEW: Specific error for city not found.
        throw Exception('City not found. Please try another city.');
      }

      final latitude = geocodingData['results'][0]['latitude'];
      final longitude = geocodingData['results'][0]['longitude'];

      final weatherUrl = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=weathercode,temperature_2m_max,windspeed_10m_max&current_weather=true&timezone=auto&forecast_days=3');
      final weatherResponse = await http.get(weatherUrl).timeout(const Duration(seconds: 10));

      if (weatherResponse.statusCode != 200) {
        throw Exception('Failed to load weather forecast.');
      }

      final weatherData = json.decode(weatherResponse.body);

      final List<ForecastDay> processedForecast = [];
      final dailyData = weatherData['daily'];
      for (int i = 0; i < dailyData['time'].length; i++) {
        processedForecast.add(ForecastDay(
          day: i + 1,
          temperature: '${dailyData['temperature_2m_max'][i]}°C',
          wind: '${dailyData['windspeed_10m_max'][i]} km/h',
        ));
      }

      _weatherData = WeatherData(
        cityName: city,
        temperature: "${weatherData['current_weather']['temperature']}°C",
        status: _getWeatherStatusFromCode(weatherData['current_weather']['weathercode']),
        forecast: processedForecast,
      );

      // NEW: On success, save the city to SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastCity', city);

    } on SocketException {
      _error = "Network Error. Could not connect to the server.";
    } on TimeoutException {
      _error = "Request timed out. Please check your connection and try again.";
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getWeatherStatusFromCode(int code) {
    if (code == 0 || code == 1) return "Clear sky / Sunny";
    if (code == 2 || code == 3) return "Cloudy";
    if (code >= 51 && code <= 67 || code >= 80 && code <= 82) return "Rainy";
    return "Cloudy";
  }
}