import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../errors/exceptions.dart';
import '../models/category_model.dart';
import '../models/panier_surprise_model.dart';
import '../models/promotion_model.dart';
import '../models/listing_model.dart';
import 'book_service.dart';

class HomeService {
  final ApiClient _apiClient = ApiClient();
  final BookService _bookService = BookService();

  /// Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      final List<dynamic> categories = response.data is List
          ? response.data
          : [];
      return categories
          .map((cat) => Category.fromJson(cat as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // If endpoint doesn't exist, return a default curated list
      if (e.response?.statusCode == 404) {
        return _getDefaultCategories();
      }
      throw ApiException(e.message ?? 'Failed to fetch categories');
    }
  }

  /// Get panier surprise listings
  Future<List<PanierSurprise>> getPaniersSurprise({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/panier-surprise?page=$page&limit=$limit',
      );
      final List<dynamic> paniers = response.data is List ? response.data : [];
      return paniers
          .map(
            (panier) => PanierSurprise.fromJson(panier as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _getMockPaniers();
      }
      throw ApiException(e.message ?? 'Failed to fetch paniers');
    }
  }

  /// Get active promotions
  Future<List<Promotion>> getPromotions() async {
    try {
      final response = await _apiClient.get('/promotions');
      final List<dynamic> promotions = response.data is List
          ? response.data
          : [];
      return promotions
          .map((promo) => Promotion.fromJson(promo as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _getMockPromotions();
      }
      throw ApiException(e.message ?? 'Failed to fetch promotions');
    }
  }

  /// Fetch transactions by type from transactions endpoint
  /// Types: "exchange", "sell", "donate", "need"
  Future<List<Listing>> _getTransactionsByType(
    String type, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/transactions?type=$type&page=$page&limit=$limit',
      );

      // Handle both list and paginated responses
      final data = response.data;
      List<dynamic> items = [];

      if (data is List) {
        items = data;
      } else if (data is Map && data['data'] is List) {
        items = data['data']; // Paginated response format
      } else if (data is Map && data['transactions'] is List) {
        items = data['transactions']; // Alternative response format
      }

      // filter items client‑side as a safety net; server should
      // already have applied the ?type= query parameter but occasionally
      // the backend returns mixed types.  This ensures each section of the
      // home page contains only the requested transaction class.
      final filteredItems = items.where((raw) {
        if (raw is! Map) return false;
        final map = Map<String, dynamic>.from(raw);
        final t = map['type']?.toString();
        return t != null && t.toLowerCase() == type.toLowerCase();
      }).toList();

      if (kDebugMode) {
        print(
          '   homeService: requested "$type" got ${items.length} '
          'items, filtered to ${filteredItems.length}',
        );
      }

      return await Future.wait(
        filteredItems.map((i) async {
          try {
            if (i is! Map) {
              return Listing(
                id: '',
                titre: 'Unknown',
                description: '',
                ownerId: '',
              );
            }

            final map = Map<String, dynamic>.from(i);

            final hasTitle =
                map.containsKey('titre') || map.containsKey('title');

            if (!hasTitle) {
              final statut = map['statut']?.toString() ?? '';
              final prixDouble = (map['prix'] as num?)?.toDouble();

              Map<String, dynamic>? book;

              try {
                book = await _bookService.getBookCached(
                  map['livre_id']?.toString() ?? '',
                );
              } catch (e) {
                debugPrint('Erreur recuperation livre: $e');
              }

              DateTime? date;
              if (map['date'] is String) {
                date = DateTime.tryParse(map['date']);
              } else if (map['date_creation'] is String) {
                date = DateTime.tryParse(map['date_creation']);
              }

              return Listing(
                id: map['id']?.toString() ?? '',
                titre: book?['titre'] ?? 'Unknown',
                description: statut.isNotEmpty ? 'Statut : $statut' : '',
                prix: prixDouble,
                image:
                    'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=200&h=300&fit=crop',
                localisation: map['localisation'] as String?,
                date: date,
                ownerId:
                    map['parent_offreur_id']?.toString() ??
                    map['user_id']?.toString() ??
                    '',
              );
            }

            return Listing.fromJson(map);
          } catch (e) {
            debugPrint('Erreur item: $e');

            // 🔥 IMPORTANT : toujours retourner quelque chose
            return Listing(
              id: '',
              titre: 'Erreur',
              description: '',
              ownerId: '',
            );
          }
        }).toList(),
      );
    } on DioException catch (e) {
      // Return empty list on 404 (no more filtering by old paths)
      if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        return <Listing>[];
      }
      // Also return empty on connection errors (graceful degradation)
      return <Listing>[];
    } catch (e) {
      // Silent failure - return empty list
      return <Listing>[];
    }
  }

  /// Get exchange transactions
  Future<List<Listing>> getEchanges({int page = 1, int limit = 10}) {
    return _getTransactionsByType('exchange', page: page, limit: limit);
  }

  /// Get sell transactions
  Future<List<Listing>> getVentes({int page = 1, int limit = 10}) {
    return _getTransactionsByType('sell', page: page, limit: limit);
  }

  /// Get donation requests
  Future<List<Listing>> getBesoins({int page = 1, int limit = 10}) {
    return _getTransactionsByType('need', page: page, limit: limit);
  }

  /// Get donation offers
  Future<List<Listing>> getDons({int page = 1, int limit = 10}) {
    return _getTransactionsByType('donate', page: page, limit: limit);
  }

  // Mock data methods for development
  List<Category> _getDefaultCategories() {
    return [
      Category(
        id: 'manuels',
        nom: 'Manuels Scolaires',
        icone: '📚',
        couleur: '#2196F3',
      ),
      Category(id: 'bords', nom: 'Bords', icone: '📘', couleur: '#64B5F6'),
      Category(
        id: 'maternelle',
        nom: 'Maternelle',
        icone: '🎒',
        couleur: '#4FC3F7',
      ),
      Category(
        id: 'ecole',
        nom: 'Ecole primaire',
        icone: '🏫',
        couleur: '#29B6F6',
      ),
      Category(id: 'lycee', nom: 'Lycee', icone: '🎓', couleur: '#0288D1'),
    ];
  }

  List<PanierSurprise> _getMockPaniers() {
    return [
      PanierSurprise(
        id: '1',
        titre: 'Panier surprise',
        description: 'Panier surprise Panier su...',
        prix: 1500.0,
        quantiteRestante: 50,
        image:
            'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=200&h=300&fit=crop',
        dateCollecte: DateTime.now().add(const Duration(days: 1)),
        localisation: 'Paris',
      ),
    ];
  }

  List<Promotion> _getMockPromotions() {
    return [
      Promotion(
        id: '1',
        titre: 'Promotion Flash',
        description: 'Pas de promotion flash',
        image: null,
        remise: null,
      ),
      Promotion(
        id: '2',
        titre: 'ACHETER x et recevoir Y gratuitement',
        description: 'Promotion récente',
        image: 'https://via.placeholder.com/300x200?text=Promotion+Recente',
        remise: 20,
        code: 'KMBI',
      ),
    ];
  }
}
