import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

class ApiService {
  static const String _geoBaseUrl = 'https://geocoding-api.open-meteo.com/v1';
  static const String _weatherBaseUrl = 'https://api.open-meteo.com/v1';

  Future<List<LocationModel>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      '$_geoBaseUrl/search?name=${Uri.encodeComponent(query.trim())}&count=10&language=id&format=json',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return [];
        }
        return results
            .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Gagal mencari lokasi (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda.');
    } on http.ClientException {
      throw Exception('Gagal menghubungi server Open-Meteo.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<WeatherModel> getWeather(LocationModel location) async {
    final url = Uri.parse(
      '$_weatherBaseUrl/forecast?latitude=${location.latitude}&longitude=${location.longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return WeatherModel.fromJson(json: data, location: location);
      } else {
        throw Exception('Gagal memuat cuaca (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda.');
    } on http.ClientException {
      throw Exception('Gagal menghubungi server Open-Meteo.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}
