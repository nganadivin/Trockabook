import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/widgets/cards/book_card.dart';
import 'package:trocabook_front/core/services/book_service.dart';
import 'package:trocabook_front/core/config/app_colors.dart';

class MyBooksPage extends StatefulWidget {
  const MyBooksPage({super.key});

  @override
  State<MyBooksPage> createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  late Future<List<Map<String, dynamic>>> _booksFuture;
  final BookService _bookService = BookService();

  @override
  void initState() {
    super.initState();
    _refreshBooks();
  }

  void _refreshBooks() {
    setState(() {
      _booksFuture = _bookService.getMyBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes livres'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navigate to add-book and refresh when returning
              await context.push('/add-book');
              _refreshBooks();
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshBooks),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _booksFuture = _bookService.getMyBooks();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No books yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/add-book'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your First Book'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BookCard(
                  title: book['titre'] ?? 'Unknown',
                  author: book['auteur'] ?? 'Unknown',
                  imageUrl: ((book['image'] as String?)?.isNotEmpty == true)
                      ? book['image'] as String
                      : 'https://via.placeholder.com/150',
                  grade: book['niveau'] ?? 'N/A',
                  subject: book['matiere'] ?? 'N/A',
                  condition: book['etat'] ?? 'N/A',
                  onTap: () =>
                      context.go('/book-details/${book['id'] ?? index}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
