import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class StorageService {
  static const String _keyFavorites = 'weather_favorites';
  static const String _keyLastLocation = 'weather_last_location';
  static const String _keyRecents = 'weather_recent_searches';

  // 1. Favorites Storage
  Future<List<LocationModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyFavorites) ?? [];
    return list.map((item) {
      final jsonMap = json.decode(item) as Map<String, dynamic>;
      return LocationModel.fromJson(jsonMap);
    }).toList();
  }

  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = favorites.map((loc) => json.encode(loc.toJson())).toList();
    await prefs.setStringList(_keyFavorites, stringList);
  }

  Future<bool> addFavorite(LocationModel location) async {
    final list = await getFavorites();
    if (!list.contains(location)) {
      list.add(location);
      await saveFavorites(list);
      return true;
    }
    return false;
  }

  Future<bool> removeFavorite(LocationModel location) async {
    final list = await getFavorites();
    list.removeWhere((item) => item == location);
    await saveFavorites(list);
    return true;
  }

  Future<bool> isFavorite(LocationModel location) async {
    final list = await getFavorites();
    return list.contains(location);
  }

  // 2. Last Viewed Location
  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastLocation, json.encode(location.toJson()));
  }

  Future<LocationModel?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLastLocation);
    if (raw == null) return null;
    try {
      final jsonMap = json.decode(raw) as Map<String, dynamic>;
      return LocationModel.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  // 3. Recent Search History
  Future<List<LocationModel>> getRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRecents) ?? [];
    return list.map((item) {
      final jsonMap = json.decode(item) as Map<String, dynamic>;
      return LocationModel.fromJson(jsonMap);
    }).toList();
  }

  Future<void> saveRecents(List<LocationModel> recents) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = recents.map((loc) => json.encode(loc.toJson())).toList();
    await prefs.setStringList(_keyRecents, stringList);
  }

  Future<void> addRecent(LocationModel location) async {
    final list = await getRecents();
    list.removeWhere((item) => item == location);
    list.insert(0, location);
    if (list.length > 10) {
      list.removeRange(10, list.length);
    }
    await saveRecents(list);
  }

  Future<void> removeRecent(LocationModel location) async {
    final list = await getRecents();
    list.removeWhere((item) => item == location);
    await saveRecents(list);
  }

  Future<void> clearRecents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRecents);
  }
}
