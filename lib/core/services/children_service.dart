import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../errors/exceptions.dart';
import 'auth_service.dart';

class ChildrenService {
  final ApiClient _apiClient = ApiClient();

  /// Get children for current user
  Future<List<Map<String, dynamic>>> getMyChildren() async {
    try {
      final authService = AuthService();
      final userId =
          authService.currentUser?['userId']?.toString() ??
          authService.currentUser?['id']?.toString() ??
          authService.currentUser?['_id']?.toString();

      // If user not authenticated, return empty list
      if (userId == null) {
        return [];
      }

      final response = await _apiClient.get('/enfants/parent/$userId');
      final List<dynamic> children = response.data is List ? response.data : [];
      return List<Map<String, dynamic>>.from(
        children.map((child) => Map<String, dynamic>.from(child as Map)),
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch children');
    }
  }

  /// Get children for a specific parent
  Future<List<Map<String, dynamic>>> getChildrenByParentId(
    String parentId,
  ) async {
    try {
      final response = await _apiClient.get('/enfants/parent/$parentId');
      final List<dynamic> children = response.data is List ? response.data : [];
      return List<Map<String, dynamic>>.from(
        children.map((child) => Map<String, dynamic>.from(child as Map)),
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch children');
    }
  }

  /// Get a specific child by ID
  Future<Map<String, dynamic>> getChildById(String childId) async {
    try {
      final response = await _apiClient.get('/enfants/$childId');
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch child');
    }
  }

  /// Create a new child
  Future<Map<String, dynamic>> createChild({
    required String prenom,
    required String nom,
    required int age,
    String? dateNaissance,
  }) async {
    try {
      final response = await _apiClient.post('/enfants', {
        'prenom': prenom,
        'nom': nom,
        'age': age,
        if (dateNaissance != null) 'dateNaissance': dateNaissance,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to create child');
    }
  }

  /// Update a child
  Future<Map<String, dynamic>> updateChild(
    String childId, {
    String? prenom,
    String? nom,
    int? age,
    String? dateNaissance,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (prenom != null) body['prenom'] = prenom;
      if (nom != null) body['nom'] = nom;
      if (age != null) body['age'] = age;
      if (dateNaissance != null) body['dateNaissance'] = dateNaissance;

      final response = await _apiClient.patch('/enfants/$childId', body);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to update child');
    }
  }

  /// Delete a child
  Future<void> deleteChild(String childId) async {
    try {
      await _apiClient.delete('/enfants/$childId');
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to delete child');
    }
  }
}
