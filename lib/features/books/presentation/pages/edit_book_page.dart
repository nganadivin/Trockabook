import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/widgets/buttons/primary_button.dart';
import 'package:trocabook_front/core/widgets/inputs/custom_text_field.dart';
import 'package:trocabook_front/core/services/book_service.dart';
import 'package:trocabook_front/core/errors/exceptions.dart';

class EditBookPage extends StatefulWidget {
  final String bookId;

  const EditBookPage({super.key, required this.bookId});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final BookService _bookService = BookService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingBook = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    try {
      final book = await _bookService.getBookById(widget.bookId);
      if (!mounted) return;
      setState(() {
        _titleController.text = (book['titre'] ?? '').toString();
        _descriptionController.text = (book['description'] ?? '').toString();
        _isLoadingBook = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoadingBook = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateBook() async {
    setState(() => _isLoading = true);
    try {
      await _bookService.updateBook(
        widget.bookId,
        titre: _titleController.text,
        description: _descriptionController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book updated successfully')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.message}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur inattendue: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBook() async {
    try {
      await _bookService.deleteBook(widget.bookId);
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Book deleted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete Book'),
                  content: const Text(
                    'Are you sure you want to delete this book?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _deleteBook();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoadingBook
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur: $_loadError'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _isLoadingBook = true);
                      _loadBook();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Edit Book Details',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _titleController,
                    label: 'Book Title',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle image picker
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Update Photos'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Update Book',
                    onPressed: _updateBook,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
    );
  }
}
