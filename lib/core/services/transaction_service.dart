import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../errors/exceptions.dart';

class TransactionService {
  final ApiClient _apiClient;

  /// Allows passing a custom [ApiClient] for testing or configuration.
  TransactionService([ApiClient? apiClient])
    : _apiClient = apiClient ?? ApiClient();

  /// Get all transactions for current user
  Future<List<Map<String, dynamic>>> getMyTransactions() async {
    try {
      final response = await _apiClient.get('/transactions');
      final List<dynamic> transactions = response.data is List
          ? response.data
          : response.data['transactions'] ?? [];
      return List<Map<String, dynamic>>.from(
        transactions.map((t) => Map<String, dynamic>.from(t as Map)),
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch transactions');
    }
  }

  /// Get all transactions for all user
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    try {
      final response = await _apiClient.get('/transactions');
      final List<dynamic> transactions = response.data is List
          ? response.data
          : response.data['transactions'] ?? [];
      return List<Map<String, dynamic>>.from(
        transactions.map((t) => Map<String, dynamic>.from(t as Map)),
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch transactions');
    }
  }

  /// Get a specific transaction by ID
  Future<Map<String, dynamic>> getTransactionById(String transactionId) async {
    try {
      final response = await _apiClient.get('/transactions/$transactionId');
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch transaction');
    }
  }

  /// Create a new transaction
  ///
  /// Parameters:
  /// - `livreId`: The book ID (livre_id)
  /// - `userId`: The user ID offering the book (parent_offreur_id)
  /// - `type`: Transaction type: 'exchange', 'sell', 'donate', 'need'
  /// - `message`: Optional message (not sent to backend if provided based on error)
  /// - `offeredBooks`: Not used in new backend format
  Future<Map<String, dynamic>> createTransaction({
    required String livreId,
    required String userId,
    required String type,
    double? prix,
    String? message,
    List<String>? offeredBooks,
  }) async {
    try {
      final body = <String, dynamic>{
        'livre_id': livreId,
        'parent_offreur_id': userId,
        'type': type,
      };

      // older fields kept for reference; they are ignored by backend
      if (message != null && message.isNotEmpty) {
        body['message'] = message;
      }
      if (offeredBooks != null && offeredBooks.isNotEmpty) {
        body['offeredBooks'] = offeredBooks;
      }

      // price is mandatory for the new backend contract; default to 0
      // for exchanges and allow override for sells/donations/needs.
      body['prix'] = prix ?? (type == 'exchange' ? 0 : 0);

      // log final body before sending so reproduction is straightforward
      if (kDebugMode) {
        print('    -> Transaction payload: $body');
      }

      final response = await _apiClient.post('/transactions', body);
      return response.data;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final respData = e.response?.data;
      final errMsg = StringBuffer();
      errMsg.write(e.message ?? 'Failed to create transaction');
      if (status != null) errMsg.write(' (status $status)');
      if (respData != null) errMsg.write(' → $respData');
      throw ApiException(errMsg.toString());
    }
  }

  /// Update a transaction
  Future<Map<String, dynamic>> updateTransaction(
    String transactionId, {
    String? status,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status;
      if (notes != null) body['notes'] = notes;

      final response = await _apiClient.patch(
        '/transactions/$transactionId',
        body,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to update transaction');
    }
  }

  /// Negotiate a transaction by proposing new books.
  ///
  /// `proposedBooks` may be a comma-separated list or array depending on backend.
  Future<Map<String, dynamic>> negotiateTransaction(
    String transactionId, {
    required List<String> proposedBooks,
    String? message,
  }) async {
    try {
      final body = <String, dynamic>{'proposedBooks': proposedBooks};
      if (message != null && message.isNotEmpty) {
        body['message'] = message;
      }
      final response = await _apiClient.patch(
        '/transactions/$transactionId/negotiate',
        body,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to negotiate transaction');
    }
  }

  /// Accept a transaction
  Future<Map<String, dynamic>> acceptTransaction(String transactionId) async {
    try {
      final response = await _apiClient.patch(
        '/transactions/$transactionId/accept',
        {},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to accept transaction');
    }
  }
}
