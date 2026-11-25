import 'package:flutter/material.dart';

class WeatherCondition {
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;

  const WeatherCondition({
    required this.description,
    required this.icon,
    required this.color,
    required this.gradientColors,
  });
}

class WeatherCodeHelper {
  static WeatherCondition getCondition(int code) {
    switch (code) {
      case 0:
        return const WeatherCondition(
          description: 'Cerah',
          icon: Icons.wb_sunny_rounded,
          color: Colors.amber,
          gradientColors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
        );
      case 1:
        return const WeatherCondition(
          description: 'Cerah Berawan',
          icon: Icons.wb_sunny_outlined,
          color: Colors.orangeAccent,
          gradientColors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
        );
      case 2:
        return const WeatherCondition(
          description: 'Sebagian Berawan',
          icon: Icons.cloud_queue_rounded,
          color: Colors.lightBlueAccent,
          gradientColors: [Color(0xFF3a7bd5), Color(0xFF3a6073)],
        );
      case 3:
        return const WeatherCondition(
          description: 'Mendung',
          icon: Icons.cloud_rounded,
          color: Colors.blueGrey,
          gradientColors: [Color(0xFF4b6cb7), Color(0xFF182848)],
        );
      case 45:
      case 48:
        return const WeatherCondition(
          description: 'Berkabut',
          icon: Icons.blur_on_rounded,
          color: Colors.blueGrey,
          gradientColors: [Color(0xFF606c88), Color(0xFF3f4c6b)],
        );
      case 51:
      case 53:
      case 55:
        return const WeatherCondition(
          description: 'Gerimis',
          icon: Icons.water_drop_outlined,
          color: Colors.cyanAccent,
          gradientColors: [Color(0xFF314755), Color(0xFF26a0da)],
        );
      case 61:
      case 63:
        return const WeatherCondition(
          description: 'Hujan',
          icon: Icons.water_drop_rounded,
          color: Colors.lightBlue,
          gradientColors: [Color(0xFF1f4037), Color(0xFF2d6a4f)],
        );
      case 65:
        return const WeatherCondition(
          description: 'Hujan Lebat',
          icon: Icons.thunderstorm_rounded,
          color: Colors.indigoAccent,
          gradientColors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        );
      case 80:
      case 81:
      case 82:
        return const WeatherCondition(
          description: 'Hujan Deras Sesaat',
          icon: Icons.grain_rounded,
          color: Colors.cyan,
          gradientColors: [Color(0xFF16222A), Color(0xFF3A6073)],
        );
      case 95:
      case 96:
      case 99:
        return const WeatherCondition(
          description: 'Badai Petir',
          icon: Icons.flash_on_rounded,
          color: Colors.yellowAccent,
          gradientColors: [Color(0xFF141E30), Color(0xFF243B55)],
        );
      default:
        return const WeatherCondition(
          description: 'Berawan',
          icon: Icons.cloud_rounded,
          color: Colors.blueAccent,
          gradientColors: [Color(0xFF396afc), Color(0xFF2948ff)],
        );
    }
  }
}
