import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../config/api_endpoints.dart';

class ApiClient {
  final Dio dio = Dio();
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    dio.options.baseUrl = ApiEndpoints.apibaseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Log de la requête
          if (kDebugMode) {
            print('📡 [API REQUEST]');
            print('   URL: ${options.baseUrl}${options.path}');
            print('   Method: ${options.method}');
          }

          // Définir les en-têtes par défaut
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          // Ajoute automatiquement le token s'il existe
          final token = await _storage.read(key: 'idToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            if (kDebugMode)
              print(
                '   ✅ Token added: ${token.substring(0, math.min(20, token.length))}...',
              );
          }

          if (kDebugMode) {
            print('   Headers: ${options.headers}');
            if (options.data != null) {
              print('   Body: ${options.data}');
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ [API RESPONSE] Status: ${response.statusCode}');
            print('   Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (kDebugMode) {
            print('❌ [API ERROR]');
            print('   Status: ${e.response?.statusCode}');
            print('   Message: ${e.message}');
            print(
              '   URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}',
            );
            print('   Response: ${e.response?.data}');
            if (e.response != null) {
              print('   Full Response Body: ${e.response!.toString()}');
            }
          }

          if (e.response?.statusCode == 401) {
            // Token expiré - à améliorer avec token refresh
            await _storage.deleteAll();
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String endpoint) async {
    try {
      return await dio.get(endpoint);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(String endpoint, dynamic data) async {
    try {
      return await dio.post(endpoint, data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> put(String endpoint, dynamic data) async {
    try {
      return await dio.put(endpoint, data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> patch(String endpoint, dynamic data) async {
    try {
      return await dio.patch(endpoint, data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> delete(String endpoint) async {
    try {
      return await dio.delete(endpoint);
    } on DioException {
      rethrow;
    }
  }
}
