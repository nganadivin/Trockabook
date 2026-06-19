import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/widgets/cards/book_card.dart';
import 'package:trocabook_front/core/services/book_service.dart';
import 'filters_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final BookService _bookService = BookService();
  String? _selectedCategory = 'All';

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _books = [];

  String _selectedGrade = 'All';
  String _selectedSubject = 'All';

  final List<String> _grades = [
    'All',
    '6e',
    '5e',
    '4e',
    '3e',
    '2nde',
    '1ère',
    'Terminale',
  ];
  final List<String> _subjects = [
    'All',
    'Mathématiques',
    'Français',
    'SVT',
    'Histoire-Géo',
    'Anglais',
    'Physique-Chimie',
  ];
  final List<String> _Categories = [
    'All',
    'bords',
    'manuels',
    'ecole',
    'maternelle',
    'lycee'
  ];

  @override
  void initState() {
   super.initState();
  }

   
bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final uri = GoRouterState.of(context).uri;
      _selectedCategory = uri.queryParameters['category'];

      _searchBooks();

      _isInitialized = true;
    }
  }

  //  void _performSearch({String? category}) {
  //   // Check if category is present before searching
  //   if (category != null && category.isNotEmpty) {
  //     // Implement your search logic here, filtering by category
  //     // e.g., call a service to fetch results based on category
  //     print('Searching with category: $category');
  //   } else {
  //     // Handle case where no category is provided (e.g., general search)
  //     print('No category specified, performing general search');
  //   }
  // }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final query = _searchController.text.trim();
      List<Map<String, dynamic>> results;
      if (query.isEmpty) {
        results = await _bookService.searchBooks("");
      } else {
        results = await _bookService.searchBooks(query);
      }
       if (_selectedCategory != null && _selectedCategory != 'All') {
        results = results.where((b) {
          final category = b['category']?.toString() ?? '';
          return category.contains(_selectedCategory.toString());
        }).toList();
      }
      // apply filters locally
      if (_selectedGrade != 'All') {
        results = results.where((b) {
          final grade = b['niveau']?.toString() ?? '';
          return grade.contains(_selectedGrade);
        }).toList();
      }
      if (_selectedSubject != 'All') {
        results = results.where((b) {
          final subj = b['matiere']?.toString() ?? '';
          return subj.contains(_selectedSubject);
        }).toList();
      }
      if (!mounted) return;
      setState(() {
        _books = results;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters(Map<String, String?> filters) {
    if (filters['grade'] != null) _selectedGrade = filters['grade']!;
    if (filters['subject'] != null) _selectedSubject = filters['subject']!;
    _searchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedCategory != null
            ? Text('Categorie : ${_selectedCategory!}')
            : const Text('Recherche'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final result = await Navigator.of(context)
                  .push<Map<String, String?>>(
                    MaterialPageRoute(builder: (_) => const FiltersPage()),
                  );
              if (result != null && mounted) {
                _applyFilters(result);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Faites une recherche...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (_) => _searchBooks(),
                ),
                const SizedBox(height: 16),
                // if (_selectedCategory != null) {
                //   Text('Search in ${_selectedCategory!}'),
                // } else {
                  
                // },
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory == null ? 'All' : _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: _Categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => {
                          setState(() => _selectedCategory = value!),
                          _searchBooks(),
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        decoration: const InputDecoration(
                          labelText: 'Grade',
                          border: OutlineInputBorder(),
                        ),
                        items: _grades
                            .map(
                              (grade) => DropdownMenuItem(
                                value: grade,
                                child: Text(grade),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => {
                            setState(() => _selectedGrade = value!),
                            _searchBooks(),
                      },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(),
                        ),
                        items: _subjects
                            .map(
                              (subject) => DropdownMenuItem(
                                value: subject,
                                child: Text(subject),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>{
                            setState(() => _selectedSubject = value!),
                            _searchBooks()
                            },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: $_errorMessage'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _searchBooks,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _books.isEmpty
                ? Column(
                    children: [
                      const SizedBox(height: 60),
                      const Text('Aucun resultat, veuillez essayer une autre recherche'),
                      // const SizedBox(height: 16),
                      // Expanded(
                      //   child: ListView.builder(
                      //     padding: const EdgeInsets.symmetric(horizontal: 16),
                      //     itemCount: 3,
                      //     itemBuilder: (context, index) {
                      //       return Padding(
                      //         padding: const EdgeInsets.only(bottom: 16),
                      //         child: BookCard(
                      //           title: 'Sample Book ${index + 1}',
                      //           author: 'Author ${index + 1}',
                      //           imageUrl: 'https://via.placeholder.com/150',
                      //           grade: '5e',
                      //           subject: 'Mathématiques',
                      //           condition: 'Bon état',
                      //           onTap: () {},
                      //         ),
                      //       );
                      //     },
                      //   ),
                      // ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      final book = _books[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BookCard(
                          title: book['titre'] ?? 'Unknown',
                          author: book['auteur'] ?? 'Unknown',
                          imageUrl:
                              book['image'] ??
                              'https://via.placeholder.com/150',
                          grade: book['niveau'] ?? 'N/A',
                          subject: book['matiere'] ?? 'N/A',
                          condition: book['etat'] ?? 'N/A',
                          onTap: () =>
                              context.go('/book-details/${book['id'] ?? ''}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
