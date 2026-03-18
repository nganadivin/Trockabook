import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/services/home_service.dart';
import 'package:trocabook_front/core/services/book_service.dart';
import 'package:trocabook_front/core/services/transaction_service.dart';
import 'package:trocabook_front/core/services/auth_service.dart';
import 'package:trocabook_front/core/errors/exceptions.dart';

class ProposeExchangeNewPage extends StatefulWidget {
  const ProposeExchangeNewPage({super.key});

  @override
  State<ProposeExchangeNewPage> createState() => _ProposeExchangeNewPageState();
}

class _ProposeExchangeNewPageState extends State<ProposeExchangeNewPage> {
  final HomeService _homeService = HomeService();
  final BookService _bookService = BookService();
  final TransactionService _transactionService = TransactionService();

  late Future<List<dynamic>> _listingsFuture;
  late Future<List<Map<String, dynamic>>> _myBooksFuture;

  String? _selectedListingId;
  final List<String> _selectedOfferedBooks = [];
  final _messageCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _listingsFuture = _homeService.getEchanges();
    _myBooksFuture = _bookService.getMyBooks();
  }

  void _toggleOffer(String id) {
    setState(() {
      if (_selectedOfferedBooks.contains(id))
        _selectedOfferedBooks.remove(id);
      else
        _selectedOfferedBooks.add(id);
    });
  }

  Future<void> _submitProposal() async {
    if (_selectedListingId == null || _selectedOfferedBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner une annonce et au moins un de vos livres',
          ),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Create transaction with the book we're offering
      final res = await _transaction_service_create(
        _selectedOfferedBooks.first,
      );
      final txId = res['id'] ?? res['_id'];
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Proposition envoyée')));
        if (txId != null)
          context.go('/exchange-details/$txId');
        else
          Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur inattendue: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>> _transaction_service_create(
    String livreId,
  ) async {
    // use provider to get the authenticated user instead of creating a new
    // AuthService instance which won't have the profile loaded
    final auth = Provider.of<AuthService>(context, listen: false);
    final currentUserId =
        auth.currentUser?['id']?.toString() ??
        auth.currentUser?['_id']?.toString() ??
        auth.currentUser?['uid']?.toString();
    if (currentUserId == null) {
      throw ApiException('User not authenticated');
    }

    return await _transactionService.createTransaction(
      livreId: livreId,
      userId: currentUserId,
      type: 'exchange',
      prix: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proposer un échange')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _listingsFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  final items = snap.data ?? [];
                  if (items.isEmpty)
                    return const Center(
                      child: Text('Aucune annonce d\'échange trouvée'),
                    );
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final it = items[i];
                      String id = '';
                      String title = '';
                      String subtitle = '';
                      if (it is Map) {
                        id =
                            (it['id']?.toString() ??
                            it['_id']?.toString() ??
                            '');
                        title = (it['titre'] ?? it['title'] ?? '').toString();
                        subtitle = (it['description'] ?? '').toString();
                      } else {
                        // Fallback for Listing model instances
                        final dyn = it as dynamic;
                        id = (dyn.id?.toString() ?? dyn._id?.toString() ?? '');
                        title = (dyn.titre ?? dyn.title ?? '').toString();
                        subtitle = (dyn.description ?? '').toString();
                      }

                      return RadioListTile<String>(
                        value: id,
                        groupValue: _selectedListingId,
                        onChanged: (v) =>
                            setState(() => _selectedListingId = v),
                        title: Text(title),
                        subtitle: Text(subtitle),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _myBooksFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting)
                  return const SizedBox();
                final my = snap.data ?? [];
                if (my.isEmpty)
                  return const Text('Vous n\'avez pas de livres à proposer');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sélectionnez les livres que vous proposez'),
                    ...my.map(
                      (b) => CheckboxListTile(
                        title: Text(b['titre'] ?? b['title'] ?? ''),
                        value: _selectedOfferedBooks.contains(b['id']),
                        onChanged: (_) =>
                            _toggleOffer(b['id']?.toString() ?? ''),
                      ),
                    ),
                  ],
                );
              },
            ),
            TextField(
              controller: _messageCtrl,
              decoration: const InputDecoration(
                hintText: 'Message (optionnel)',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitProposal,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Envoyer la proposition'),
            ),
          ],
        ),
      ),
    );
  }
}
