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

  String _lastSearchedCity = "Berlin";
  String get lastSearchedCity => _lastSearchedCity;

  // --- Temperature unit state ---
  bool _isFahrenheit = false;
  bool get isFahrenheit => _isFahrenheit;

  // --- NEW: Wind speed unit state ---
  bool _isMph = false;
  bool get isMph => _isMph;

  WeatherProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('lastCity');

    // Restore both temperature and wind speed preferences
    _isFahrenheit = prefs.getBool('isFahrenheit') ?? false;
    _isMph = prefs.getBool('isMph') ?? false; // NEW

    await fetchWeatherForCity(savedCity ?? 'Berlin');
  }

  Future<void> fetchWeatherForCity(String city) async {
    if (city.isEmpty) return;

    _isLoading = true;
    _error = null;
    _lastSearchedCity = city;
    notifyListeners();

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _error = "No Internet connection. Please check your network.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final geocodingUrl = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1',
      );
      final geocodingResponse = await http
          .get(geocodingUrl)
          .timeout(const Duration(seconds: 10));

      if (geocodingResponse.statusCode != 200) {
        throw Exception('Failed to get location data from the server.');
      }

      final geocodingData = json.decode(geocodingResponse.body);
      if (geocodingData['results'] == null ||
          geocodingData['results'].isEmpty) {
        throw Exception('City not found. Please try another city.');
      }

      final latitude = geocodingData['results'][0]['latitude'];
      final longitude = geocodingData['results'][0]['longitude'];

      // API URL remains the same, as we get the raw data from it
      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=weathercode,temperature_2m_max,windspeed_10m_max&current_weather=true&timezone=auto&forecast_days=3',
      );
      final weatherResponse = await http
          .get(weatherUrl)
          .timeout(const Duration(seconds: 10));

      if (weatherResponse.statusCode != 200) {
        throw Exception('Failed to load weather forecast.');
      }

      final weatherJson = json.decode(weatherResponse.body);
      final currentWeather = weatherJson['current_weather'];

      // --- MODIFIED: Parse raw wind speed for forecast ---
      final List<ForecastDay> processedForecast = [];
      final dailyData = weatherJson['daily'];
      for (int i = 0; i < dailyData['time'].length; i++) {
        processedForecast.add(
          ForecastDay(
            day: i + 1,
            // --- MODIFIED: Parse the raw temperature value ---
            tempCelsius: (dailyData['temperature_2m_max'][i] as num).toDouble(),
            windKmh: (dailyData['windspeed_10m_max'][i] as num).toDouble(),
          ),
        );
      }

      // Store raw numeric values
      final double tempCelsius = (currentWeather['temperature'] as num)
          .toDouble();
      final double windKmh = (currentWeather['windspeed'] as num)
          .toDouble(); // NEW

      // --- MODIFIED: Pass the new windKmh value to the constructor ---
      _weatherData = WeatherData(
        cityName: city,
        temperature: "$tempCelsius°C",
        status: _getWeatherStatusFromCode(currentWeather['weathercode']),
        forecast: processedForecast,
        isDay: currentWeather['is_day'] == 1,
        dateTime: DateTime.parse(currentWeather['time']),
        tempCelsius: tempCelsius,
        windKmh: windKmh, // NEW
      );

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

  void toggleUnits(bool value) async {
    _isFahrenheit = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFahrenheit', _isFahrenheit);
    notifyListeners();
  }

  String formatTemperature(double tempCelsius) {
    if (_isFahrenheit) {
      final f = (tempCelsius * 9 / 5) + 32;
      return "${f.toStringAsFixed(1)} °F";
    } else {
      return "${tempCelsius.toStringAsFixed(1)} °C";
    }
  }

  // --- NEW: Method to toggle wind speed units ---
  void toggleWindSpeed(bool value) async {
    _isMph = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMph', _isMph);
    notifyListeners();
  }

  // --- NEW: Method to format wind speed based on user preference ---
  String formatWindSpeed(double windKmh) {
    if (_isMph) {
      // Conversion factor from km/h to mph
      final mph = windKmh * 0.621371;
      return "${mph.toStringAsFixed(1)} mph";
    } else {
      return "${windKmh.toStringAsFixed(1)} km/h";
    }
  }
}
