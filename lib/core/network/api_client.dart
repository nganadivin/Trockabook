import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
          if (kDebugMode) {
            debugPrint('[API REQUEST]');
            debugPrint('   URL: ${options.baseUrl}${options.path}');
            debugPrint('   Method: ${options.method}');
          }

          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          final token = await _storage.read(key: 'idToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            if (kDebugMode) {
              debugPrint(
                '   Token added: ${token.substring(0, math.min(20, token.length))}...',
              );
            }
          }

          if (kDebugMode) {
            debugPrint('   Headers: ${_safeHeaders(options.headers)}');
            if (options.data != null) {
              debugPrint('   Body: ${_safeBody(options.data)}');
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('[API RESPONSE] Status: ${response.statusCode}');
            debugPrint('   Data: ${_safeBody(response.data)}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (kDebugMode) {
            debugPrint('[API ERROR]');
            debugPrint('   Status: ${e.response?.statusCode}');
            debugPrint('   Message: ${e.message}');
            debugPrint(
              '   URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}',
            );
            debugPrint('   Response: ${_safeBody(e.response?.data)}');
          }

          if (e.response?.statusCode == 401) {
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

  Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry(key, 'Bearer ***');
      }
      return MapEntry(key, value);
    });
  }

  Object? _safeBody(Object? data) {
    if (data is! Map) return data;

    final redacted = Map<String, dynamic>.from(data);
    for (final key in ['password', 'otp', 'token', 'idToken', 'refreshToken']) {
      if (redacted.containsKey(key)) {
        redacted[key] = '***';
      }
    }
    return redacted;
  }
}
