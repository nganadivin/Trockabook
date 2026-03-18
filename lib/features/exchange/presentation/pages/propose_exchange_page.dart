import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trocabook_front/core/widgets/buttons/primary_button.dart';
import 'package:trocabook_front/core/services/book_service.dart';
import 'package:trocabook_front/core/services/transaction_service.dart';
import 'package:trocabook_front/core/services/auth_service.dart';
import 'package:trocabook_front/core/errors/exceptions.dart';
import 'package:go_router/go_router.dart';

class ProposeExchangePage extends StatefulWidget {
  final String bookId;

  const ProposeExchangePage({super.key, required this.bookId});

  @override
  State<ProposeExchangePage> createState() => _ProposeExchangePageState();
}

class _ProposeExchangePageState extends State<ProposeExchangePage> {
  final _messageController = TextEditingController();
  final List<String> _selectedBooks = [];
  bool _isLoading = false;
  String? _errorMessage;

  final BookService _bookService = BookService();
  final TransactionService _transactionService = TransactionService();

  Map<String, dynamic>? _targetBook;
  List<Map<String, dynamic>> _myBooks = [];
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final book = await _bookService.getBookById(widget.bookId);
      final myBooks = await _bookService.getMyBooks();
      if (mounted) {
        setState(() {
          _targetBook = book;
          _myBooks = myBooks;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _toggleBookSelection(String bookId) {
    setState(() {
      if (_selectedBooks.contains(bookId)) {
        _selectedBooks.remove(bookId);
      } else {
        _selectedBooks.add(bookId);
      }
    });
  }

  Future<void> _proposeExchange() async {
    if (_selectedBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one book')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_selectedBooks.isEmpty) {
        throw ApiException('Must select at least one book to offer');
      }

      final auth = Provider.of<AuthService>(context, listen: false);
      // ensure profile is loaded if not already
      if (auth.currentUser == null) {
        await auth.initializeUser();
      }
      final currentUserId =
          auth.currentUser?['id']?.toString() ??
          auth.currentUser?['_id']?.toString() ??
          auth.currentUser?['uid']?.toString();

      if (currentUserId == null) {
        throw ApiException('User not authenticated');
      }

      final response = await _transactionService.createTransaction(
        livreId: _selectedBooks.first,
        userId: currentUserId,
        type: 'exchange',
        prix: 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Exchange proposal sent')));
        final txId = response['id'] ?? response['_id'];
        if (txId != null) {
          Navigator.of(context).pop();
          context.go('/exchange-details/$txId');
        } else {
          Navigator.of(context).pop();
        }
      }
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Propose Exchange')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(child: Text('Failed to load data: $_loadError'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_targetBook != null) ...[
                    Text(
                      'Proposing for: ${_targetBook!['titre'] ?? _targetBook!['title'] ?? ''}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Select books to exchange',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (_myBooks.isEmpty)
                    const Text('You have no books to offer.'),
                  ..._myBooks.map(
                    (book) => Card(
                      child: CheckboxListTile(
                        title: Text(book['titre'] ?? book['title'] ?? ''),
                        subtitle: Text(
                          'Condition: ${book['etat'] ?? book['condition'] ?? ''}',
                        ),
                        value: _selectedBooks.contains(book['id']),
                        onChanged: (selected) =>
                            _toggleBookSelection(book['id'] ?? ''),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Add a message (optional)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Write a message to the book owner...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Send Proposal',
                    onPressed: _proposeExchange,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
    );
  }
}
