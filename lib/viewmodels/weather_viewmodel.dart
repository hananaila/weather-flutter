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
  List<LocationModel> _recents = [];
  final Map<String, WeatherModel> _favoriteWeathers = {};

  // Getters
  WeatherModel? get weather => _weather;
  LocationModel get currentLocation => _currentLocation ?? defaultLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFavorite => _isFavorite;
  List<LocationModel> get favorites => _favorites;
  List<LocationModel> get recents => _recents;

  String _locKey(LocationModel loc) => '${loc.latitude.toStringAsFixed(3)}_${loc.longitude.toStringAsFixed(3)}';

  WeatherModel? getFavoriteWeather(LocationModel location) {
    if (location == _currentLocation && _weather != null) {
      return _weather;
    }
    return _favoriteWeathers[_locKey(location)];
  }

  Future<void> init() async {
    await loadFavorites();
    await loadRecents();
    final savedLocation = await _storageService.getLastLocation();
    // Jika lokasi tersimpan sebelumnya adalah Toronto (dari bekas uji coba awal), reset ke Purwokerto
    if (savedLocation != null && savedLocation.name == 'Toronto') {
      await _storageService.saveLastLocation(defaultLocation);
      await fetchWeather(defaultLocation);
    } else {
      await fetchWeather(savedLocation ?? defaultLocation);
    }
  }

  Future<void> loadFavorites() async {
    _favorites = await _storageService.getFavorites();
    if (_currentLocation != null) {
      _isFavorite = _favorites.contains(_currentLocation);
    }
    notifyListeners();
  }

  Future<void> fetchFavoriteWeathers() async {
    for (final fav in _favorites) {
      final key = _locKey(fav);
      if (!_favoriteWeathers.containsKey(key)) {
        try {
          final w = await _apiService.getWeather(fav);
          _favoriteWeathers[key] = w;
          notifyListeners();
        } catch (_) {}
      }
    }
  }

  Future<void> loadRecents() async {
    _recents = await _storageService.getRecents();
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
      _favoriteWeathers[_locKey(location)] = result;
      await _storageService.saveLastLocation(location);
      await _storageService.addRecent(location);
      _recents = await _storageService.getRecents();
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
      try {
        final w = await _apiService.getWeather(target);
        _favoriteWeathers[_locKey(target)] = w;
      } catch (_) {}
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

  Future<void> removeRecent(LocationModel location) async {
    await _storageService.removeRecent(location);
    _recents = await _storageService.getRecents();
    notifyListeners();
  }

  Future<void> clearRecents() async {
    await _storageService.clearRecents();
    _recents = [];
    notifyListeners();
  }
}
