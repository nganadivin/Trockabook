import 'package:flutter/material.dart';
import '../services/listing_service.dart';

/// Provider for managing listing state with filtering and pagination
class ListingProvider extends ChangeNotifier {
  final ListingService _listingService = ListingService();

  // State variables
  List<Map<String, dynamic>> _exchangeBooks = [];
  List<Map<String, dynamic>> _sellBooks = [];
  List<Map<String, dynamic>> _donateBooks = [];
  List<Map<String, dynamic>> _needBooks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter state
  String? _selectedClasse;
  String? _selectedMatiere;
  String? _selectedCondition;
  double? _maxDistance;

  // Pagination
  int _currentPage = 1;
  int _pageLimit = 10;

  // Getters
  List<Map<String, dynamic>> get exchangeBooks => _exchangeBooks;
  List<Map<String, dynamic>> get sellBooks => _sellBooks;
  List<Map<String, dynamic>> get donateBooks => _donateBooks;
  List<Map<String, dynamic>> get needBooks => _needBooks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedClasse => _selectedClasse;
  String? get selectedMatiere => _selectedMatiere;
  String? get selectedCondition => _selectedCondition;
  double? get maxDistance => _maxDistance;

  // Load exchange books
  Future<void> loadExchangeBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _exchangeBooks = await _listingService.getExchangeBooks(
        page: _currentPage,
        limit: _pageLimit,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load sell books
  Future<void> loadSellBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sellBooks = await _listingService.getSellBooks(
        page: _currentPage,
        limit: _pageLimit,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load donate books
  Future<void> loadDonateBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _donateBooks = await _listingService.getDonateBooks(
        page: _currentPage,
        limit: _pageLimit,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load need books
  Future<void> loadNeedBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _needBooks = await _listingService.getNeedBooks(
        page: _currentPage,
        limit: _pageLimit,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter setters
  void setClasseFilter(String? classe) {
    _selectedClasse = classe;
    notifyListeners();
  }

  void setMatiereFilter(String? matiere) {
    _selectedMatiere = matiere;
    notifyListeners();
  }

  void setConditionFilter(String? condition) {
    _selectedCondition = condition;
    notifyListeners();
  }

  void setMaxDistance(double? distance) {
    _maxDistance = distance;
    notifyListeners();
  }

  // Pagination
  void nextPage() {
    _currentPage++;
    notifyListeners();
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  void resetFilters() {
    _selectedClasse = null;
    _selectedMatiere = null;
    _selectedCondition = null;
    _maxDistance = null;
    _currentPage = 1;
    notifyListeners();
  }
}
