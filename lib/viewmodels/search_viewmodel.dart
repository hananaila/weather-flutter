import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../services/api_service.dart';

class SearchViewModel extends ChangeNotifier {
  final ApiService _apiService;

  SearchViewModel({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<LocationModel> _results = [];
  bool _isSearching = false;
  String? _errorMessage;
  String _currentQuery = '';

  List<LocationModel> get results => _results;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;

  Future<void> search(String query) async {
    _currentQuery = query.trim();
    if (_currentQuery.isEmpty) {
      _results = [];
      _errorMessage = null;
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _apiService.searchLocations(_currentQuery);
      _results = list;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _results = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clear() {
    _currentQuery = '';
    _results = [];
    _errorMessage = null;
    _isSearching = false;
    notifyListeners();
  }
}
