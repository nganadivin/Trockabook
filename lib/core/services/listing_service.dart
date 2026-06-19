import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../errors/exceptions.dart';

class ListingService {
  final ApiClient _apiClient = ApiClient();

  /// Get exchange books
  Future<List<Map<String, dynamic>>> getExchangeBooks({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/livres?category=exchange&page=$page&limit=$limit',
      );
      final List<dynamic> books = response.data is List ? response.data : [];
      return List<Map<String, dynamic>>.from(
        books.map((book) => Map<String, dynamic>.from(book as Map)),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _getMockExchangeBooks();
      }
      throw ApiException(e.message ?? 'Failed to fetch exchange books');
    }
  }

  /// Get sell books
  Future<List<Map<String, dynamic>>> getSellBooks({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/livres?category=sell&page=$page&limit=$limit',
      );
      final List<dynamic> books = response.data is List ? response.data : [];
      return List<Map<String, dynamic>>.from(
        books.map((book) => Map<String, dynamic>.from(book as Map)),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _getMockSellBooks();
      }
      throw ApiException(e.message ?? 'Failed to fetch sell books');
    }
  }

  /// Get donate books
  Future<List<Map<String, dynamic>>> getDonateBooks({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/livres?category=donate&page=$page&limit=$limit',
      );
      final List<dynamic> books = response.data is List ? response.data : [];
      return List<Map<String, dynamic>>.from(
        books.map((book) => Map<String, dynamic>.from(book as Map)),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _getMockDonateBooks();
      }
      throw ApiException(e.message ?? 'Failed to fetch donate books');
    }
  }

  /// Get need books
  Future<List<Map<String, dynamic>>> getNeedBooks({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/livres?category=need&page=$page&limit=$limit',
      );
      final List<dynamic> books = response.data is List ? response.data : [];
      return List<Map<String, dynamic>>.from(
        books.map((book) => Map<String, dynamic>.from(book as Map)),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _getMockNeedBooks();
      }
      throw ApiException(e.message ?? 'Failed to fetch need books');
    }
  }

  // Mock data
  List<Map<String, dynamic>> _getMockExchangeBooks() {
    return [
      {
        'id': 'ex_1',
        'titre': 'Mathématiques 3ème',
        'auteur': 'Dupont',
        'description': 'Manuel complet de mathématiques',
        'niveau': '3e',
        'matiere': 'Mathématiques',
        'etat': 'Bon',
        'category': 'exchange',
        'image':
            'https://images.unsplash.com/photo-1633356714176-d60aefc0b62e?w=200&h=300&fit=crop',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockSellBooks() {
    return [
      {
        'id': 'sell_1',
        'titre': 'Français Littérature',
        'auteur': 'Martin',
        'description': 'Anthologie de littérature française',
        'niveau': '2nde',
        'matiere': 'Français',
        'etat': 'Très Bon',
        'category': 'sell',
        'price': 5000,
        'image':
            'https://images.unsplash.com/photo-1507842217343-583f20270319?w=200&h=300&fit=crop',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockDonateBooks() {
    return [
      {
        'id': 'donate_1',
        'titre': 'Histoire-Géographie 4ème',
        'auteur': 'Bernard',
        'description': 'Cours complet avec exercices',
        'niveau': '4e',
        'matiere': 'Histoire-Géo',
        'etat': 'Moyen',
        'category': 'donate',
        'image':
            'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=200&h=300&fit=crop',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockNeedBooks() {
    return [
      {
        'id': 'need_1',
        'titre': 'SVT Sciences de la Vie',
        'auteur': 'Leclerc',
        'description': 'Cherche manuel SVT pour lycée',
        'niveau': '1ère',
        'matiere': 'SVT',
        'category': 'need',
        'needType': 'exchange',
        'image':
            'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=200&h=300&fit=crop',
      },
    ];
  }
}
