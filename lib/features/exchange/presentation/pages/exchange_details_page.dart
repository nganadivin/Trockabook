import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trocabook_front/core/widgets/buttons/primary_button.dart';
import 'package:trocabook_front/core/services/transaction_service.dart';
import 'package:trocabook_front/core/services/book_service.dart';
import 'package:trocabook_front/core/services/auth_service.dart';

class ExchangeDetailsPage extends StatefulWidget {
  final String exchangeId;

  const ExchangeDetailsPage({super.key, required this.exchangeId});

  @override
  State<ExchangeDetailsPage> createState() => _ExchangeDetailsPageState();
}

class _ExchangeDetailsPageState extends State<ExchangeDetailsPage> {
  final TransactionService _transactionService = TransactionService();
  final BookService _bookService = BookService();
  String? _currentUserId;
  late Future<Map<String, dynamic>> _transactionFuture;

  @override
  void initState() {
    super.initState();
    _transactionFuture = _transactionService.getTransactionById(
      widget.exchangeId,
    );
    // current user id will be obtained in didChangeDependencies where
    // the Provider-based AuthService is available from context.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentUserId == null) {
      final auth = Provider.of<AuthService>(context, listen: false);
      if (auth.currentUser == null) {
        // initializeUser may be async; load and set state when done
        auth
            .initializeUser()
            .then((_) {
              if (mounted) {
                setState(() {
                  _currentUserId =
                      auth.currentUser?['id']?.toString() ??
                      auth.currentUser?['_id']?.toString();
                });
              }
            })
            .catchError((_) {});
      } else {
        _currentUserId =
            auth.currentUser?['id']?.toString() ??
            auth.currentUser?['_id']?.toString();
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'negotiating':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _transactionFuture,
          builder: (ctx, snap) {
            if (!snap.hasData) return const Text('Details');
            final type = snap.data?['type']?.toString() ?? 'transaction';
            String capitalize(String s) =>
                s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
            return Text('${capitalize(type)} Details');
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _transactionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final tx = snapshot.data ?? {};
          final status = tx['status']?.toString() ?? 'unknown';
          final txType = tx['type']?.toString() ?? 'transaction';
          String capitalize(String s) =>
              s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
          final fromId =
              tx['fromUserId']?.toString() ?? tx['fromUser']?.toString();
          final toId = tx['toUserId']?.toString() ?? tx['toUser']?.toString();
          final isInitiator =
              _currentUserId != null && fromId == _currentUserId;
          final isRecipient = _currentUserId != null && toId == _currentUserId;

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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${capitalize(txType)} Status: $status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _statusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildBookSection(
                  'Book Offered',
                  offered.toString(),
                  tx['fromUserName'] ?? tx['fromUser'] ?? 'You',
                ),
                const SizedBox(height: 16),
                _buildBookSection(
                  'Book Requested',
                  requested.toString(),
                  tx['toUserName'] ?? tx['toUser'] ?? 'Other',
                ),
                const SizedBox(height: 24),
                if (tx['message'] != null &&
                    tx['message'].toString().isNotEmpty) ...[
                  Text('Message: ${tx['message']}'),
                  const SizedBox(height: 16),
                ],
                if ((status == 'pending' || status == 'negotiating') &&
                    isRecipient) ...[
                  PrimaryButton(
                    text: 'Accept',
                    onPressed: () async {
                      await _updateStatus('accepted');
                    },
                  ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    text: 'Reject',
                    onPressed: () async {
                      await _updateStatus('rejected');
                    },
                    isLoading: false,
                  ),
                  const SizedBox(height: 8),
                ],
                if (status == 'pending' || status == 'negotiating') ...[
                  PrimaryButton(
                    text: 'Negotiate',
                    onPressed: _showNegotiationDialog,
                  ),
                ],
                if ((status == 'pending' || status == 'negotiating') &&
                    isInitiator) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      await _updateStatus('cancelled');
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Cancel Exchange'),
                  ),
                ],
                if (status == 'accepted') ...[
                  PrimaryButton(
                    text: 'Chat',
                    onPressed: () => context.go('/chat/${widget.exchangeId}'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      await _updateStatus('completed');
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Mark as Completed'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      if (newStatus == 'accepted') {
        await _transactionService.acceptTransaction(widget.exchangeId);
      } else {
        await _transactionService.updateTransaction(
          widget.exchangeId,
          status: newStatus,
        );
      }
      setState(() {
        _transactionFuture = _transactionService.getTransactionById(
          widget.exchangeId,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildBookSection(String title, String bookTitle, String owner) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(bookTitle),
            Text('Owner: $owner', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Future<void> _showNegotiationDialog() async {
    // load the user's own books
    List<Map<String, dynamic>> myBooks = [];
    try {
      myBooks = await _bookService.getMyBooks();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load your books: $e')));
      return;
    }

    List<String> selected = [];
    TextEditingController msgCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Negotiate – select books'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView(
                        children: myBooks.map((book) {
                          final id = book['id']?.toString() ?? '';
                          final title = book['titre'] ?? book['title'] ?? '';
                          return CheckboxListTile(
                            title: Text(title),
                            value: selected.contains(id),
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  selected.add(id);
                                } else {
                                  selected.remove(id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: msgCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Optional message',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Send'),
                  onPressed: () async {
                    if (selected.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Select at least one book'),
                        ),
                      );
                      return;
                    }
                    try {
                      Navigator.of(context).pop();
                      await _transactionService.negotiateTransaction(
                        widget.exchangeId,
                        proposedBooks: selected,
                        message: msgCtrl.text.isEmpty ? null : msgCtrl.text,
                      );
                      setState(() {
                        _transactionFuture = _transactionService
                            .getTransactionById(widget.exchangeId);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Counteroffer sent')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Negotiation failed: $e')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
