import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class WeatherViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  WeatherViewModel({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  // Default location: Purwokerto (Kampus Unsoed)
  static final LocationModel defaultLocation = LocationModel(
    name: 'Purwokerto',
    latitude: -7.4244,
    longitude: 109.2303,
    country: 'Indonesia',
    admin1: 'Jawa Tengah',
  );

  WeatherModel? _weather;
  LocationModel? _currentLocation;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFavorite = false;
  List<LocationModel> _favorites = [];

  // Getters
  WeatherModel? get weather => _weather;
  LocationModel get currentLocation => _currentLocation ?? defaultLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFavorite => _isFavorite;
  List<LocationModel> get favorites => _favorites;

  Future<void> init() async {
    await loadFavorites();
    final savedLocation = await _storageService.getLastLocation();
    await fetchWeather(savedLocation ?? defaultLocation);
  }

  Future<void> loadFavorites() async {
    _favorites = await _storageService.getFavorites();
    if (_currentLocation != null) {
      _isFavorite = _favorites.contains(_currentLocation);
    }
    notifyListeners();
  }

  Future<void> fetchWeather(LocationModel location) async {
    _isLoading = true;
    _errorMessage = null;
    _currentLocation = location;
    _isFavorite = _favorites.contains(location);
    notifyListeners();

    try {
      final result = await _apiService.getWeather(location);
      _weather = result;
      await _storageService.saveLastLocation(location);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_currentLocation != null) {
      await fetchWeather(_currentLocation!);
    } else {
      await init();
    }
  }

  Future<void> toggleFavorite({LocationModel? targetLocation}) async {
    final target = targetLocation ?? _currentLocation;
    if (target == null) return;

    if (_favorites.contains(target)) {
      await _storageService.removeFavorite(target);
    } else {
      await _storageService.addFavorite(target);
    }

    _favorites = await _storageService.getFavorites();
    if (_currentLocation != null) {
      _isFavorite = _favorites.contains(_currentLocation);
    }
    notifyListeners();
  }

  Future<void> removeFavorite(LocationModel location) async {
    await _storageService.removeFavorite(location);
    _favorites = await _storageService.getFavorites();
    if (_currentLocation != null) {
      _isFavorite = _favorites.contains(_currentLocation);
    }
    notifyListeners();
  }
}
