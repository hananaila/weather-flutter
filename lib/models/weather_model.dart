import 'location_model.dart';

class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final String time;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      time: json['time'] as String? ?? '',
    );
  }
}

class DailyForecast {
  final String date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final int precipitationProbability;

  DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationProbability,
  });
}

class WeatherModel {
  final LocationModel location;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  WeatherModel({
    required this.location,
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson({
    required Map<String, dynamic> json,
    required LocationModel location,
  }) {
    final current = CurrentWeather.fromJson(
        json['current'] as Map<String, dynamic>? ?? {});

    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};
    final times = (dailyJson['time'] as List<dynamic>?) ?? [];
    final weatherCodes = (dailyJson['weather_code'] as List<dynamic>?) ?? [];
    final maxTemps = (dailyJson['temperature_2m_max'] as List<dynamic>?) ?? [];
    final minTemps = (dailyJson['temperature_2m_min'] as List<dynamic>?) ?? [];
    final rainProbabilities =
        (dailyJson['precipitation_probability_max'] as List<dynamic>?) ?? [];

    final List<DailyForecast> dailyList = [];
    for (int i = 0; i < times.length; i++) {
      dailyList.add(
        DailyForecast(
          date: times[i].toString(),
          weatherCode: i < weatherCodes.length
              ? (weatherCodes[i] as num).toInt()
              : current.weatherCode,
          maxTemp: i < maxTemps.length
              ? (maxTemps[i] as num).toDouble()
              : current.temperature,
          minTemp: i < minTemps.length
              ? (minTemps[i] as num).toDouble()
              : current.temperature,
          precipitationProbability: i < rainProbabilities.length
              ? (rainProbabilities[i] as num).toInt()
              : 0,
        ),
      );
    }

    return WeatherModel(
      location: location,
      current: current,
      daily: dailyList,
    );
  }
}
