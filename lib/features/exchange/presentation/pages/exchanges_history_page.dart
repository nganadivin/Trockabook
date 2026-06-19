import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/services/transaction_service.dart';

class ExchangesHistoryPage extends StatefulWidget {
  const ExchangesHistoryPage({super.key});

  @override
  State<ExchangesHistoryPage> createState() => _ExchangesHistoryPage();
}

class _ExchangesHistoryPage extends State<ExchangesHistoryPage> {
  final TransactionService _transactionService = TransactionService();
  late Future<List<Map<String, dynamic>>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _transactionService.getMyTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exchange History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _transactionsFuture = _transactionService
                          .getMyTransactions();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final txs = snapshot.data ?? [];
          if (txs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  const Text('No exchanges yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: txs.length,
            itemBuilder: (context, index) {
              final tx = txs[index];
              final status = tx['status'] ?? 'unknown';
              final date = tx['updatedAt'] ?? tx['createdAt'] ?? '';

              String offered;
              final ob = tx['offeredBookTitle'] ?? tx['offeredBooks'];
              if (ob is List) {
                offered = ob.map((e) => e.toString()).join(', ');
              } else {
                offered = ob?.toString() ?? 'N/A';
              }
              String requested;
              final rq = tx['requestedBookTitle'] ?? tx['livreId'];
              if (rq is List) {
                requested = rq.map((e) => e.toString()).join(', ');
              } else {
                requested = rq?.toString() ?? 'N/A';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Colors.green),
                  title: Text('$offered → $requested'),
                  subtitle: Text('$status · $date'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () =>
                      context.go('/exchange-details/${tx['id'] ?? ''}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
