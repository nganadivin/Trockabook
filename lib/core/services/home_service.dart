import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../errors/exceptions.dart';
import '../models/category_model.dart';
import '../models/panier_surprise_model.dart';
import '../models/promotion_model.dart';
import '../models/listing_model.dart';

class HomeService {
  final ApiClient _apiClient = ApiClient();

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

      return items.map((i) {
        // Convert transaction or book to Listing
        final map = i as Map<String, dynamic>;
        return Listing.fromJson(map);
      }).toList();
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
  List<Category> _getMockCategories() {
    return [
      Category(id: '1', nom: 'Animaux', icone: '🐾', couleur: '#FF6B6B'),
      Category(id: '2', nom: 'Entretien', icone: '🧼', couleur: '#4ECDC4'),
      Category(id: '3', nom: 'Parapharm', icone: '💊', couleur: '#FFE66D'),
      Category(id: '4', nom: 'Maison', icone: '🏠', couleur: '#95E1D3'),
      Category(id: '5', nom: 'Beauté', icone: '💄', couleur: '#F38181'),
    ];
  }

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
        image: null,
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

  List<Listing> _getMockEchanges() {
    return [
      Listing(
        id: 'echange_1',
        titre: 'Mathématiques 3ème',
        description: 'Manuel Maths en bon état, cherche Français',
        prix: null,
        image: null,
        localisation: 'Etoudi',
        date: DateTime.now(),
      ),
      Listing(
        id: 'echange_2',
        titre: 'SVT Lycée',
        description:
            'Livre SVT complet avec exercices, troquer contre Physique',
        prix: null,
        image: null,
        localisation: 'Ekounou',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Listing(
        id: 'echange_3',
        titre: 'Espagnol Lycée',
        description:
            'Livre SVT complet avec exercices, troquer contre Physique',
        prix: null,
        image: 'https://via.placeholder.com/300x200?text=Espagnol',
        localisation: 'Lyon',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Listing(
        id: 'echange_4',
        titre: 'Chimie Lycée',
        description:
            'Livre SVT complet avec exercices, troquer contre Physique',
        prix: null,
        image: 'https://via.placeholder.com/300x200?text=Chimie',
        localisation: 'Bonnamoussadi',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<Listing> _getMockVentes() {
    return [
      Listing(
        id: 'vente_1',
        titre: 'Harry Potter Tome 1',
        description: 'Édition jeunesse excellent état, jamais lu',
        prix: 8.5,
        image: 'https://via.placeholder.com/300x200?text=Harry+Potter',
        localisation: 'Marseille',
        date: DateTime.now(),
      ),
      Listing(
        id: 'vente_2',
        titre: 'Dictionnaire Larousse',
        description: 'Dictionnaire complet édition 2023',
        prix: 15.0,
        image: null,
        localisation: 'Toulouse',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Listing(
        id: 'vente_3',
        titre: 'Cahiers de révisions Bac',
        description: 'Lot 5 cahiers résumés avec fiches',
        prix: 20.0,
        image: null,
        localisation: 'Bordeaux',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Listing(
        id: 'vente_4',
        titre: 'Cahiers de révisions CEP',
        description: '9 Fiches de revisions pour le CEP',
        prix: 20.0,
        image: 'https://via.placeholder.com/300x200?text=CEP',
        localisation: 'Bordeaux',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Listing(
        id: 'vente_5',
        titre: 'Livre de chimie',
        description: 'Lot 7 cahiers résumés avec fiches',
        prix: 20.0,
        image: 'https://via.placeholder.com/300x200?text=Chimie+Livre',
        localisation: 'Bordeaux',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  List<Listing> _getMockBesoins() {
    return [
      Listing(
        id: 'besoin_1',
        titre: 'Cherche Français 4ème',
        description: 'Manuel Français niveau 4ème urgent',
        prix: null,
        image: null,
        localisation: 'Paris 15e',
        date: DateTime.now(),
      ),
      Listing(
        id: 'besoin_2',
        titre: 'Besoin livres histoire-géo',
        description: 'Manuels histoire-géo 2nde pour révisions',
        prix: null,
        image: null,
        localisation: 'Lille',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Listing(
        id: 'besoin_3',
        titre: 'Besoin livres physique',
        description: 'Manuels histoire-géo 2nde pour révisions',
        prix: null,
        image: 'https://via.placeholder.com/300x200?text=Physique',
        localisation: 'Yaounde | bastos',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Listing(
        id: 'besoin_4',
        titre: 'Besoin Cahier de revision en chimie',
        description: 'Manuels de revision en chimie',
        prix: null,
        image: null,
        localisation: 'douala',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Listing(
        id: 'besoin_5',
        titre: 'Besoin livres histoire-géo',
        description: 'Manuels histoire-géo 2nde pour révisions',
        prix: null,
        image: null,
        localisation: 'Lille',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Listing(
        id: 'besoin_6',
        titre: 'Besoin livres histoire-géo',
        description: 'Manuels histoire-géo 2nde pour révisions',
        prix: null,
        image: 'https://via.placeholder.com/300x200?text=HistoireGeo3',
        localisation: 'Lille',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  List<Listing> _getMockDons() {
    return [
      Listing(
        id: 'don_1',
        titre: 'Lot 10 livres enfants',
        description: 'Albums jeunesse, histoires courtes gratuits à récupérer',
        prix: null,
        image: null,
        localisation: 'Nantes',
        date: DateTime.now(),
      ),
      Listing(
        id: 'don_2',
        titre: 'Encyclopédie jeunesse',
        description: 'Encyclopédie complète 5 tomes à donner',
        prix: null,
        image: null,
        localisation: 'Strasbourg',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Listing(
        id: 'don_3',
        titre: ' Amour et passion',
        description: 'Roman sur des histoires amoureuses',
        prix: null,
        image: null,
        localisation: 'Bonamoussadi',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
