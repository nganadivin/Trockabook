import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../errors/exceptions.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/users/me');
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch user profile');
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId');
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch user');
    }
  }

  /// Update current user profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profileImage,
    String? ville,
    double? latitude,
    double? longitude,
    int? age,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (email != null) body['email'] = email;
      if (phone != null) body['telephone'] = phone;
      if (profileImage != null) body['profileImage'] = profileImage;
      if (ville != null) body['ville'] = ville;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (age != null) body['age'] = age;

      final response = await _apiClient.patch('/users/me', body);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to update profile');
    }
  }

  /// Update user status
  Future<Map<String, dynamic>> updateUserStatus(
    String userId, {
    required String status,
  }) async {
    try {
      final response = await _apiClient.post('/users/$userId/status', {
        'status': status,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to update user status');
    }
  }

  /// Get all users (admin only)
  Future<List<Map<String, dynamic>>> getAllUsers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get('/users?page=$page&limit=$limit');
      final List<dynamic> users = response.data is List
          ? response.data
          : response.data['users'] ?? [];
      return List<Map<String, dynamic>>.from(
        users.map((user) => Map<String, dynamic>.from(user as Map)),
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch users');
    }
  }
}
