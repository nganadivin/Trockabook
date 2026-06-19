import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:trocabook_front/core/services/transaction_service.dart';
import 'package:trocabook_front/core/network/api_client.dart';

// A minimal fake that captures the last POST body
class DummyApiClient extends ApiClient {
  Map<String, dynamic>? lastBody;

  @override
  Future<Response> post(String endpoint, dynamic data) async {
    lastBody = data as Map<String, dynamic>?;
    // simulate successful response
    return Response(
      requestOptions: RequestOptions(path: endpoint),
      data: {'id': 'dummy'},
      statusCode: 200,
    );
  }
}

void main() {
  test('createTransaction sends price 0 for exchange', () async {
    final client = DummyApiClient();
    final service = TransactionService(client);

    final result = await service.createTransaction(
      livreId: 'L1',
      userId: 'U1',
      type: 'exchange',
    );

    expect(client.lastBody, isNotNull);
    expect(client.lastBody!['prix'], 0);
    expect(client.lastBody!['type'], 'exchange');
    expect(result['id'], 'dummy');
  });

  test('createTransaction includes provided price when non-null', () async {
    final client = DummyApiClient();
    final service = TransactionService(client);

    await service.createTransaction(
      livreId: 'L1',
      userId: 'U1',
      type: 'sell',
      prix: 42.5,
    );

    expect(client.lastBody!['prix'], 42.5);
    expect(client.lastBody!['type'], 'sell');
  });

  test('createTransaction does not send legacy fields', () async {
    final client = DummyApiClient();
    final service = TransactionService(client);

    await service.createTransaction(
      livreId: 'L1',
      userId: 'U1',
      type: 'exchange',
      message: 'hello',
      offeredBooks: ['B1'],
    );

    expect(client.lastBody!.containsKey('message'), isFalse);
    expect(client.lastBody!.containsKey('offeredBooks'), isFalse);
  });
}
