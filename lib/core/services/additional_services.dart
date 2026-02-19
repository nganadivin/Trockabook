import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../errors/exceptions.dart';

class EvaluationService {
  final ApiClient _apiClient = ApiClient();

  /// Get evaluations for a user
  Future<List<Map<String, dynamic>>> getUserEvaluations(String userId) async {
    try {
      final response = await _apiClient.get('/evaluations/user/$userId');
      final List<dynamic> evaluations = response.data is List
          ? response.data
          : response.data['evaluations'] ?? [];
      return List<Map<String, dynamic>>.from(
        evaluations.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch evaluations');
    }
  }

  /// Create an evaluation
  Future<Map<String, dynamic>> createEvaluation({
    required String userId,
    required int rating,
    String? commentaire,
  }) async {
    try {
      final response = await _apiClient.post('/evaluations', {
        'userId': userId,
        'rating': rating,
        if (commentaire != null) 'commentaire': commentaire,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to create evaluation');
    }
  }
}

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  /// Get all notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _apiClient.get('/notifications');
      final List<dynamic> notifications = response.data is List
          ? response.data
          : response.data['notifications'] ?? [];
      return List<Map<String, dynamic>>.from(
        notifications.map((n) => Map<String, dynamic>.from(n as Map)),
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch notifications');
    }
  }

  /// Mark a notification as read
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.patch(
        '/notifications/$notificationId/read',
        {},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to mark notification as read');
    }
  }
}

class FavoriteService {
  final ApiClient _apiClient = ApiClient();

  /// Get user's favorite books
  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final response = await _apiClient.get('/favoris');
      final List<dynamic> favorites = response.data is List
          ? response.data
          : response.data['favoris'] ?? [];
      return List<Map<String, dynamic>>.from(
        favorites.map((f) => Map<String, dynamic>.from(f as Map)),
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch favorites');
    }
  }

  /// Add a book to favorites
  Future<Map<String, dynamic>> addFavorite(String bookId) async {
    try {
      final response = await _apiClient.post('/favoris', {'livreId': bookId});
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to add favorite');
    }
  }

  /// Remove a book from favorites
  Future<void> removeFavorite(String favoriteId) async {
    try {
      await _apiClient.delete('/favoris/$favoriteId');
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to remove favorite');
    }
  }
}

class SignalmentService {
  final ApiClient _apiClient = ApiClient();

  /// Get all signalements (reports)
  Future<List<Map<String, dynamic>>> getSignalements() async {
    try {
      final response = await _apiClient.get('/signalements');
      final List<dynamic> signalements = response.data is List
          ? response.data
          : response.data['signalements'] ?? [];
      return List<Map<String, dynamic>>.from(
        signalements.map((s) => Map<String, dynamic>.from(s as Map)),
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch signalements');
    }
  }

  /// Create a signalement (report)
  Future<Map<String, dynamic>> createSignalement({
    required String reason,
    required String userId,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post('/signalements', {
        'reason': reason,
        'userId': userId,
        if (description != null) 'description': description,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to create signalement');
    }
  }

  /// Submit moderation for a signalement
  Future<Map<String, dynamic>> moderateSignalement({
    required String signalementId,
    required String action,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post('/signalements/moderation', {
        'signalementId': signalementId,
        'action': action,
        if (notes != null) 'notes': notes,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to moderate signalement');
    }
  }
}
