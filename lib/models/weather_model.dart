// in weather_model.dart

class WeatherData {
  // ... (no changes needed in this class)
  final String cityName;
  final String temperature;
  final String status;
  final List<ForecastDay> forecast;
  final bool isDay;
  final DateTime dateTime;
  final double tempCelsius;
  final double windKmh;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.status,
    required this.forecast,
    required this.isDay,
    required this.dateTime,
    required this.tempCelsius,
    required this.windKmh,
  });
}

class ForecastDay {
  final int day;
  // --- MODIFIED: Store raw temperature value ---
  final double tempCelsius;
  final double windKmh;

  ForecastDay({
    required this.day,
    required this.tempCelsius, // Changed from 'temperature'
    required this.windKmh,
  });

  // This is no longer used for display but can be kept for other purposes if needed.
  Map<String, dynamic> toJson() {
    return {'day': day, 'temperature': tempCelsius, 'wind': windKmh};
  }
}
