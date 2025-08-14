class WeatherData {
  final String cityName;
  final String temperature;
  final String status;
  final List<ForecastDay> forecast;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.status,
    required this.forecast,
  });
}

class ForecastDay {
  final int day;
  final String temperature;
  final String wind;

  ForecastDay({
    required this.day,
    required this.temperature,
    required this.wind,
  });

  // Helper to convert to the format your ForecastGrid expects
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'temperature': temperature,
      'wind': wind,
    };
  }
}