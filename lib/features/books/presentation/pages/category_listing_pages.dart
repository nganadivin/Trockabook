import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trocabook_front/core/config/app_colors.dart';
import 'package:trocabook_front/core/widgets/cards/book_card.dart';
import 'package:trocabook_front/core/providers/listing_provider.dart';

class ExchangeBooksPage extends StatefulWidget {
  const ExchangeBooksPage({super.key});

  @override
  State<ExchangeBooksPage> createState() => _ExchangeBooksPageState();
}

class _ExchangeBooksPageState extends State<ExchangeBooksPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingProvider>().loadExchangeBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livres à échanger'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un livre...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _searchController.clear();
                        }),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: Consumer<ListingProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final books = provider.exchangeBooks;
                if (books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun livre à échanger',
                          style: TextStyle(color: Colors.grey[600]),
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
                        imageUrl:
                            book['image'] ?? 'https://via.placeholder.com/150',
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
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        onApply: (filters) {
          context.read<ListingProvider>().setClasseFilter(filters['classe']);
          context.read<ListingProvider>().setMatiereFilter(filters['matiere']);
          context.read<ListingProvider>().setConditionFilter(
            filters['condition'],
          );
          context.read<ListingProvider>().loadExchangeBooks();
          Navigator.pop(context);
        },
      ),
    );
  }
}

class SellBooksPage extends StatefulWidget {
  const SellBooksPage({super.key});

  @override
  State<SellBooksPage> createState() => _SellBooksPageState();
}

class _SellBooksPageState extends State<SellBooksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingProvider>().loadSellBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livres à vendre'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Consumer<ListingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = provider.sellBooks;
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun livre à vendre',
                    style: TextStyle(color: Colors.grey[600]),
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
              final price = book['price'] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    leading: SizedBox(
                      width: 60,
                      height: 80,
                      child: Image.network(
                        book['image'] ?? 'https://via.placeholder.com/60x80',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.book),
                      ),
                    ),
                    title: Text(book['titre'] ?? 'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${book['classe']} - ${book['matiere']}'),
                        Text(
                          '$price FCFA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () =>
                          context.go('/book-details/${book['id']}'),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DonateBooksPage extends StatefulWidget {
  const DonateBooksPage({super.key});

  @override
  State<DonateBooksPage> createState() => _DonateBooksPageState();
}

class _DonateBooksPageState extends State<DonateBooksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingProvider>().loadDonateBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livres à donner'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Consumer<ListingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = provider.donateBooks;
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun livre à donner',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return GestureDetector(
                onTap: () => context.go('/book-details/${book['id']}'),
                child: Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            image: book['image'] != null
                                ? DecorationImage(
                                    image: NetworkImage(book['image']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: book['image'] == null
                              ? const Icon(Icons.image, size: 40)
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book['titre'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book['classe'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NeedBooksPage extends StatefulWidget {
  const NeedBooksPage({super.key});

  @override
  State<NeedBooksPage> createState() => _NeedBooksPageState();
}

class _NeedBooksPageState extends State<NeedBooksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingProvider>().loadNeedBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Besoins de livres'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Consumer<ListingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = provider.needBooks;
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun besoin actuellement',
                    style: TextStyle(color: Colors.grey[600]),
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
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text('Besoin: ${book['titre']}'),
                    subtitle: Text(
                      '${book['classe']} - ${book['matiere']}\nType: ${book['needType'] ?? 'Non spécifié'}',
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => context.go('/book-details/${book['id']}'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final Function(Map<String, String?>) onApply;

  const FilterDialog({super.key, required this.onApply});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _selectedClasse;
  String? _selectedMatiere;
  String? _selectedCondition;

  final List<String> classes = [
    '6e',
    '5e',
    '4e',
    '3e',
    '2nde',
    '1ère',
    'Terminale',
  ];
  final List<String> matieres = [
    'Mathématiques',
    'Français',
    'Anglais',
    'SVT',
    'Histoire-Géo',
    'Physique-Chimie',
  ];
  final List<String> conditions = ['Neuf', 'Très bon', 'Bon', 'Moyen', 'Usé'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtrer les livres'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Classe'),
              value: _selectedClasse,
              onChanged: (value) => setState(() => _selectedClasse = value),
              items: classes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Matière'),
              value: _selectedMatiere,
              onChanged: (value) => setState(() => _selectedMatiere = value),
              items: matieres
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('État'),
              value: _selectedCondition,
              onChanged: (value) => setState(() => _selectedCondition = value),
              items: conditions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => widget.onApply({
            'classe': _selectedClasse,
            'matiere': _selectedMatiere,
            'condition': _selectedCondition,
          }),
          child: const Text('Appliquer'),
        ),
      ],
    );
  }
}
