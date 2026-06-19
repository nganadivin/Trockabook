import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trocabook_front/core/widgets/buttons/primary_button.dart';
import 'package:trocabook_front/core/services/book_service.dart';
import 'package:trocabook_front/core/services/auth_service.dart';

class BookDetailsPage extends StatefulWidget {
  final String bookId;

  const BookDetailsPage({super.key, required this.bookId});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final BookService _bookService = BookService();
  late Future<Map<String, dynamic>> _bookFuture;

  @override
  void initState() {
    super.initState();
    _bookFuture = _bookService.getBookById(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/edit-book/${widget.bookId}'),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bookFuture,
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
                      _bookFuture = _bookService.getBookById(widget.bookId);
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final book = snapshot.data ?? {};
          final title = book['titre'] ?? 'Unknown';
          final author = book['auteur'] ?? 'Unknown';
          final grade = book['niveau'] ?? 'N/A';
          final subject = book['matiere'] ?? 'N/A';
          final condition = book['etat'] ?? 'N/A';
          final location = book['localisation'] ?? 'N/A';
          final description = book['description'] ?? '';
          final imageUrl =
              book['image'] ?? 'https://via.placeholder.com/400x300';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Author: $author',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Grade', grade),
                      _buildDetailRow('Subject', subject),
                      _buildDetailRow('Condition', condition),
                      _buildDetailRow('Location', location),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(description),
                      const SizedBox(height: 32),
                      Builder(
                        builder: (context) {
                          final auth = Provider.of<AuthService>(
                            context,
                            listen: false,
                          );
                          if (auth.currentUser == null) {
                            // fire-and-forget load; UI will update once profile fetched
                            auth.initializeUser();
                          }
                          final currentId =
                              auth.currentUser?['id']?.toString() ??
                              auth.currentUser?['_id']?.toString() ??
                              auth.currentUser?['uid']?.toString();
                          final ownerId =
                              book['userId']?.toString() ??
                              book['ownerId']?.toString() ??
                              book['_ownerId']?.toString();
                          final isOwner =
                              currentId != null &&
                              ownerId != null &&
                              currentId == ownerId;

                          return Column(
                            children: [
                              PrimaryButton(
                                text: 'Propose Exchange',
                                onPressed: () => context.go(
                                  '/propose-exchange/${widget.bookId}',
                                ),
                              ),
                              if (!isOwner) ...[
                                const SizedBox(height: 16),
                                OutlinedButton(
                                  onPressed: () {
                                    final ownerId =
                                        book['userId'] ??
                                        book['ownerId'] ??
                                        book['_ownerId'];
                                    if (ownerId != null) {
                                      context.go('/public-profile/$ownerId');
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                  ),
                                  child: const Text('View Owner Profile'),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
