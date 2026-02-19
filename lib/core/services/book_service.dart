import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../errors/exceptions.dart';
import 'auth_service.dart';

class BookService {
  final ApiClient _apiClient = ApiClient();

  /// Get all books for the current user
  Future<List<Map<String, dynamic>>> getMyBooks() async {
    print("Appel API lancé...");
    try {
      final authService = AuthService();

        // Si null, on tente de recharger l'utilisateur avant d'échouer
      if (authService.currentUser == null) {
        print("CurrentUser est null, tentative de récupération...");
        await authService.initializeUser();
      }
      
      final userId =
          authService.currentUser?['userId']?.toString() ??
          authService.currentUser?['id']?.toString() ??
          authService.currentUser?['_id']?.toString();

      // If user not authenticated, return empty list
      if (userId == null) {
         print("UserId null...");
         print("DEBUG: Contenu de currentUser: ${authService.currentUser}");
        return [];
      }

      final response = await _apiClient.get('/livres/user/$userId');
      final List<dynamic> books = response.data is List ? response.data : [];
      if (books.isEmpty) {
        return _getMockBooks();
      }
      return List<Map<String, dynamic>>.from(
        books.map((book) => Map<String, dynamic>.from(book as Map)),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // 404 means no books, not an error - return empty list
        return [];
      }
      throw ApiException(e.message ?? 'Failed to fetch user books');
    }
  }

  /// Get all books (paginated)
  Future<Map<String, dynamic>> getAllBooks({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get('/livres?page=$page&limit=$limit');
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch books');
    }
  }

  /// Get a single book by ID
  Future<Map<String, dynamic>> getBookById(String bookId) async {
    try {
      final response = await _apiClient.get('/livres/$bookId');
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch book details');
    }
  }

  /// Search books
  Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    try {
      final response = await _apiClient.get('/livres/search?q=$query');
      final List<dynamic> books = response.data is List ? response.data : [];
      return List<Map<String, dynamic>>.from(
        books.map((book) => Map<String, dynamic>.from(book as Map)),
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to search books');
    }
  }

  /// Create a new book with all required backend fields
  Future<Map<String, dynamic>> createBook({
    required String titre,
    required String classe,
    required String ecole,
    required String langue,
    required String annee_scolaire,
    required String statut,
    required double localisation_lat,
    required double localisation_lng,
    required String enfant_id,
    String? description,
    String? matiere,
    String? etat,
    List<String>? images,
  }) async {
    try {
      final body = <String, dynamic>{
        'titre': titre,
        'classe': classe,
        'ecole': ecole,
        'langue': langue,
        'annee_scolaire': annee_scolaire,
        'statut': statut,
        'localisation_lat': localisation_lat,
        'localisation_lng': localisation_lng,
        'enfant_id': enfant_id,
        // Backend requires these fields
        'description': description ?? 'No description provided',
        'matiere': matiere ?? classe,
        'etat': etat ?? 'Bon',
        'images': images ?? [],
      };

      final response = await _apiClient.post('/livres', body);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to create book');
    }
  }

  /// Create a book with legacy parameters (for backward compatibility)
  @deprecated
  Future<Map<String, dynamic>> createBookLegacy({
    required String titre,
    required String auteur,
    required String description,
    required String niveau,
    required String matiere,
    required String etat,
    String? image,
  }) async {
    try {
      final response = await _apiClient.post('/livres', {
        'titre': titre,
        'auteur': auteur,
        'description': description,
        'niveau': niveau,
        'matiere': matiere,
        'etat': etat,
        if (image != null) 'image': image,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to create book');
    }
  }

  /// Update a book
  Future<Map<String, dynamic>> updateBook(
    String bookId, {
    String? titre,
    String? auteur,
    String? description,
    String? niveau,
    String? matiere,
    String? etat,
    String? image,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (titre != null) body['titre'] = titre;
      if (auteur != null) body['auteur'] = auteur;
      if (description != null) body['description'] = description;
      if (niveau != null) body['niveau'] = niveau;
      if (matiere != null) body['matiere'] = matiere;
      if (etat != null) body['etat'] = etat;
      if (image != null) body['image'] = image;

      final response = await _apiClient.post('/livres/$bookId', body);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to update book');
    }
  }

  /// Delete a book
  Future<void> deleteBook(String bookId) async {
    try {
      await _apiClient.delete('/livres/$bookId');
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to delete book');
    }
  }

  /// Update book status
  Future<Map<String, dynamic>> updateBookStatus(
    String bookId,
    String status,
  ) async {
    try {
      final response = await _apiClient.post('/livres/$bookId/statut', {
        'statut': status,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to update book status');
    }
  }

  /// Get books by user ID
  Future<List<Map<String, dynamic>>> getBooksByUserId(String userId) async {
    try {
      final response = await _apiClient.get('/livres/user/$userId');
      final List<dynamic> books = response.data is List ? response.data : [];
      return List<Map<String, dynamic>>.from(
        books.map((book) => Map<String, dynamic>.from(book as Map)),
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch user books');
    }
  }

  /// Get books by category
  Future<List<Map<String, dynamic>>> getBooksByCategory(String category) async {
    try {
      final response = await _apiClient.get('/livres?category=$category');
      final List<dynamic> books = response.data is List ? response.data : [];
      return List<Map<String, dynamic>>.from(
        books.map((book) => Map<String, dynamic>.from(book as Map)),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw ApiException(e.message ?? 'Failed to fetch books by category');
    }
  }

  /// Search and filter books
  Future<List<Map<String, dynamic>>> searchWithFilters({
    String? query,
    String? classe,
    String? matiere,
    String? category,
    double? maxDistance,
    String? condition,
  }) async {
    try {
      final params = <String, String>{};
      if (query != null && query.isNotEmpty) params['q'] = query;
      if (classe != null) params['classe'] = classe;
      if (matiere != null) params['matiere'] = matiere;
      if (category != null) params['category'] = category;
      if (maxDistance != null) params['maxDistance'] = maxDistance.toString();
      if (condition != null) params['etat'] = condition;

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final url = '/livres${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await _apiClient.get(url);
      final List<dynamic> books = response.data is List ? response.data : [];
      return List<Map<String, dynamic>>.from(
        books.map((book) => Map<String, dynamic>.from(book as Map)),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw ApiException(e.message ?? 'Failed to search books');
    }
  }

  // Mock data for testing
  List<Map<String, dynamic>> _getMockBooks() {
    return [
      {
        'id': 'book_1',
        'titre': 'Mathématiques 3ème',
        'auteur': 'Dupont',
        'description': 'Manuel complet de mathématiques pour la 3ème',
        'niveau': '3e',
        'matiere': 'Mathématiques',
        'etat': 'Très Bon',
        'image':
            'https://images.unsplash.com/photo-1633356714176-d60aefc0b62e?w=200&h=300&fit=crop',
      },
      {
        'id': 'book_2',
        'titre': 'Français Littérature',
        'auteur': 'Martin',
        'description': 'Anthologie de littérature française XVIIe-XXe siècles',
        'niveau': '2nde',
        'matiere': 'Français',
        'etat': 'Bon',
        'image':
            'https://images.unsplash.com/photo-1507842217343-583f20270319?w=200&h=300&fit=crop',
      },
      {
        'id': 'book_3',
        'titre': 'Histoire-Géographie 4ème',
        'auteur': 'Bernard',
        'description': 'Cours complet avec exercices',
        'niveau': '4e',
        'matiere': 'Histoire-Géo',
        'etat': 'Bon',
        'image':
            'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=200&h=300&fit=crop',
      },
      {
        'id': 'book_4',
        'titre': 'SVT Sciences de la Vie',
        'auteur': 'Leclerc',
        'description': 'Manuel SVT pour lycée',
        'niveau': '1ère',
        'matiere': 'SVT',
        'etat': 'Très Bon',
        'image': 'https://via.placeholder.com/150x200?text=SVT',
      },
    ];
  }
}
