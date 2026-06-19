import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trocabook_front/core/widgets/buttons/primary_button.dart';
import 'package:trocabook_front/core/widgets/inputs/custom_text_field.dart';
import 'package:trocabook_front/core/services/book_service.dart';
import 'package:trocabook_front/core/services/children_service.dart';
import 'package:trocabook_front/core/services/transaction_service.dart';
import 'package:trocabook_front/core/services/auth_service.dart';
import 'package:trocabook_front/core/errors/exceptions.dart';
import 'package:trocabook_front/core/models/book_category_enum.dart';
import 'package:trocabook_front/core/config/app_colors.dart';
import 'package:trocabook_front/core/widgets/app_snackbar.dart';

class NewTransactionPage extends StatefulWidget {
  final BookCategory? initialCategory;

  const NewTransactionPage({super.key, this.initialCategory});

  @override
  State<NewTransactionPage> createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _classeController = TextEditingController();
  final _ecoleController = TextEditingController();
  final _annee_scolaireController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _matiereController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedLangue;
  String? _selectedEtat;
  String? _selectedChildId;
  BookCategory _selectedCategory = BookCategory.exchange;
  String? _selectedNeedType;
  List<String> _selectedDesiredBooks = [];

  double _lat = 0.0;
  double _lng = 0.0;
  bool _isLoading = false;

  final BookService _bookService = BookService();
  final ChildrenService _childrenService = ChildrenService();
  final TransactionService _transactionService = TransactionService();

  List<Map<String, dynamic>> _children = [];
  List<Map<String, dynamic>> _availableBooks = [];
  bool _useExistingBook = true;
  bool _createNewBook = false;
  String? _selectedExistingBookId;

  bool _showTargetListings = false;
  String? _selectedTargetListingId;
  final List<String> _langues = ['Français', 'Anglais', 'Espagnol'];
  final List<String> _etats = ['Neuf', 'Très bon', 'Bon', 'Moyen', 'Usé'];
  final List<String> _needTypes = ['Achat', 'Échange', 'Gratuit'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? BookCategory.exchange;
    _loadChildren();
    _loadAvailableBooks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _classeController.dispose();
    _ecoleController.dispose();
    _annee_scolaireController.dispose();
    _descriptionController.dispose();
    _matiereController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    try {
      final list = await _childrenService.getMyChildren();
      if (mounted) {
        setState(() => _children = list);
      }
    } catch (e) {
      debugPrint('Failed to load children: $e');
    }
  }

  Future<void> _loadAvailableBooks() async {
    try {
      final list = await _bookService.getMyBooks();
      if (mounted) {
        setState(() => _availableBooks = list);
      }
    } catch (e) {
      debugPrint('Failed to load available books: $e');
    }
  }

  Future<void> _submitTransaction() async {
    // Validate step 2
    // if (!_openToProposals &&
    //     (_desiredBookTitle == null ||
    //         _desiredBookTitle!.isEmpty ||
    //         _desiredBookClasse == null ||
    //         _desiredBookClasse!.isEmpty ||
    //         _desiredBookMatiere == null ||
    //         _desiredBookMatiere!.isEmpty)) {
    //   AppSnackbar.show(
    //     context,
    //     'Veuillez spécifier le livre ou permettre les propositions',
    //   );
    //   return;
    // }

    setState(() => _isLoading = true);
    try {
      String offeredBookId = _selectedExistingBookId ?? '';

      // If adding new book, create it first
      if (!_useExistingBook) {
        final enfantId =
            _selectedChildId ??
            (_children.isNotEmpty
                ? _children.first['id']?.toString() ?? 'enfant_123'
                : 'enfant_123');
        final newBook = await _bookService.createBook(
          titre: _titleController.text,
          classe: _classeController.text,
          ecole: _ecoleController.text,
          langue: _selectedLangue ?? 'Français',
          annee_scolaire: DateTime.now().year.toString(),
          statut: 'Échange',
          localisation_lat: 0.0,
          localisation_lng: 0.0,
          enfant_id: enfantId,
          description: _descriptionController.text,
          matiere: _matiereController.text,
          etat: _selectedEtat ?? 'Bon',
        );
        offeredBookId =
            newBook['id']?.toString() ?? newBook['_id']?.toString() ?? '';
        if (offeredBookId.isEmpty) {
          throw ApiException('Impossible de créer le livre');
        }
      }

      // If targeting an existing listing, send proposal to it
      if (_showTargetListings && _selectedTargetListingId != null) {
        if (!mounted) return;
        final auth = Provider.of<AuthService>(context, listen: false);
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

        final res = await _transactionService.createTransaction(
          livreId: offeredBookId,
          userId: currentUserId,
          type: 'exchange',
          prix: 0,
        );

        if (mounted) {
          final txId = res['id'] ?? res['_id'];
          AppSnackbar.show(context, 'Proposition envoyée', error: false);
          if (txId != null) {
            context.go('/exchange-details/$txId');
          } else {
            context.go('/home');
          }
        }
      } else {
        // Create new exchange annonce without targeting specific listing
        if (!mounted) return;
        final auth = Provider.of<AuthService>(context, listen: false);
        if (auth.currentUser == null) {
          await auth.initializeUser();
        }

        final currentUserId =
            auth.currentUser?['id']?.toString() ??
            auth.currentUser?['_id']?.toString() ??
            auth.currentUser?['uid']?.toString();

        if (currentUserId == null) {
          throw ApiException(
            'User not authenticated currentUser: ${auth.currentUser}',
          );
        }

        String type;

        if (_selectedCategory == BookCategory.sell) {
          type = 'sell';
        } else if (_selectedCategory == BookCategory.donate) {
          type = 'donate';
        } else if (_selectedCategory == BookCategory.need) {
          if (_selectedNeedType == 'Gratuit') {
            type = 'need of free';
          } else if (_selectedNeedType == 'Echange') {
            type = 'need of exchange';
          } else if (_selectedNeedType == 'Don') {
            type = 'need of don';
          } else {
            type = 'need';
          }
        } else {
          type = 'unknown';
        }
        await _transactionService.createTransaction(
          livreId: offeredBookId,
          userId: currentUserId,
          type: type,
          prix: _selectedCategory == BookCategory.sell
              ? double.tryParse(_priceController.text) ?? 0.0
              : 0.0,
        );

        if (mounted) {
          AppSnackbar.show(context, 'Annonce crée avec succes', error: false);
          context.go('/home');
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Erreur: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Erreur inattendue: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_children.isNotEmpty && _selectedChildId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a child')));
      return;
    }

    if (_selectedCategory == BookCategory.exchange &&
        _selectedDesiredBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one desired book'),
        ),
      );
      return;
    }

    if (_selectedCategory == BookCategory.sell &&
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a price')));
      return;
    }

    if (_selectedCategory == BookCategory.need && _selectedNeedType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select need type')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // If using an existing book as the listing, update its status/category instead of creating a new book
      if (_useExistingBook && _selectedExistingBookId != null) {
        final existingId = _selectedExistingBookId!;
        // Map category to statut value expected by backend
        final statut = _selectedCategory == BookCategory.sell
            ? 'Vente'
            : _selectedCategory == BookCategory.exchange
            ? 'Échange'
            : _selectedCategory == BookCategory.donate
            ? 'Don'
            : 'Disponible';

        await _bookService.updateBookStatus(existingId, statut);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Listing mis à jour avec votre livre existant'),
            ),
          );
          context.go('/my-books');
        }
        return;
      }

      final enfantId =
          _selectedChildId ??
          (_children.isNotEmpty ? _children.first['id'] : 'enfant_123');

      final bookData = {
        'titre': _titleController.text,
        'classe': _classeController.text,
        'ecole': _ecoleController.text,
        'langue': _selectedLangue ?? 'Français',
        'annee_scolaire': _annee_scolaireController.text,
        'statut': 'Disponible',
        'localisation_lat': _lat,
        'localisation_lng': _lng,
        'enfant_id': enfantId,
        'description': _descriptionController.text,
        'matiere': _matiereController.text,
        'etat': _selectedEtat ?? 'Bon',
        'category': _selectedCategory.name,
      };

      // Add category-specific fields
      if (_selectedCategory == BookCategory.sell) {
        bookData['price'] = double.parse(_priceController.text);
      } else if (_selectedCategory == BookCategory.exchange) {
        bookData['desiredBooks'] = _selectedDesiredBooks;
      } else if (_selectedCategory == BookCategory.need) {
        bookData['needType'] = _selectedNeedType;
      }

      final newBook = await _bookService.createBook(
        titre: bookData['titre'],
        classe: bookData['classe'],
        ecole: bookData['ecole'],
        langue: bookData['langue'],
        annee_scolaire: bookData['annee_scolaire'],
        statut: bookData['statut'],
        localisation_lat: bookData['localisation_lat'],
        localisation_lng: bookData['localisation_lng'],
        enfant_id: bookData['enfant_id'],
        description: bookData['description'],
        matiere: bookData['matiere'],
        etat: bookData['etat'],
      );

      // For Sell/Donate/Need categories, create a transaction
      bool transactionFailed = false;
      if (_selectedCategory == BookCategory.sell ||
          _selectedCategory == BookCategory.donate ||
          _selectedCategory == BookCategory.need) {
        final bookId =
            newBook['id']?.toString() ?? newBook['_id']?.toString() ?? '';
        if (bookId.isNotEmpty) {
          try {
            // Map category to transaction type
            final transactionType = _selectedCategory == BookCategory.sell
                ? 'sell'
                : _selectedCategory == BookCategory.donate
                ? 'donate'
                : 'need';

            final auth = Provider.of<AuthService>(context, listen: false);
            if (auth.currentUser == null) {
              await auth.initializeUser();
            }
            final currentUserId =
                auth.currentUser?['id']?.toString() ??
                auth.currentUser?['_id']?.toString() ??
                auth.currentUser?['uid']?.toString();
            if (currentUserId != null) {
              await _transactionService.createTransaction(
                livreId: bookId,
                userId: currentUserId,
                type: transactionType,
                prix: 0,
              );
            } else {
              transactionFailed = true;
            }
          } catch (e) {
            debugPrint('Failed to create transaction: $e');
            transactionFailed = true;
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              transactionFailed
                  ? 'Livre ajouté, mais la publication de l\'annonce a échoué. Réessayez depuis "Mes livres".'
                  : 'Livre ajouté avec succès',
            ),
            backgroundColor: transactionFailed
                ? Theme.of(context).colorScheme.error
                : null,
          ),
        );
        context.go('/my-books');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.message}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur inattendue: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedCategory == BookCategory.exchange
              ? 'Démarrer un échange'
              : _selectedCategory == BookCategory.sell
              ? 'Vendre un livre'
              : _selectedCategory == BookCategory.donate
              ? 'Proposer un don'
              : _selectedCategory == BookCategory.need
              ? 'Publier un besoin'
              : 'Ajouter un livre',
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                _selectedCategory == BookCategory.exchange
                    ? 'Démarrer un échange'
                    : _selectedCategory == BookCategory.sell
                    ? 'Vendre un livre'
                    : _selectedCategory == BookCategory.donate
                    ? 'Proposer un don'
                    : _selectedCategory == BookCategory.need
                    ? 'Publier un besoin'
                    : 'Ajouter un livre',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Category Selection
              const Text(
                'Catégorie du livre *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: BookCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        category == BookCategory.need
                            ? {_createNewBook = true, _useExistingBook = false}
                            : _createNewBook = _createNewBook;

                        _selectedDesiredBooks.clear();
                        _selectedNeedType = null;
                        _priceController.clear();
                      });
                    },
                    backgroundColor: AppColors.lightGray,
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Child selection
              // if (_children.isNotEmpty) ...[
              //   const Text('Child'),
              //   const SizedBox(height: 8),
              //   DropdownButtonFormField<String>(
              //     value: _selectedChildId,
              //     items: _children
              //         .map(
              //           (c) => DropdownMenuItem(
              //             value: c['id']?.toString(),
              //             child: Text(c['prenom'] ?? 'Child'),
              //           ),
              //         )
              //         .toList(),
              //     onChanged: (v) => setState(() => _selectedChildId = v),
              //     decoration: InputDecoration(
              //       labelText: 'Enfant *',
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),
              //   ),
              //   const SizedBox(height: 16),
              // ],
              if (_selectedCategory != BookCategory.need ||
                  _availableBooks.isNotEmpty) ...[
                CheckboxListTile(
                  title: const Text(
                    'Utiliser un de mes livres existants comme annonce',
                  ),
                  value: _useExistingBook,
                  onChanged: (v) => setState(() {
                    _useExistingBook = v ?? false;
                    _createNewBook = !_useExistingBook;
                  }),
                ),
                const SizedBox(height: 16),
                if (_useExistingBook) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedExistingBookId,
                    items: _availableBooks
                        .map(
                          (b) => DropdownMenuItem(
                            value: b['id']?.toString(),
                            child: Text(b['titre'] ?? b['title'] ?? 'Livre'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedExistingBookId = v),
                    decoration: InputDecoration(
                      labelText: 'Choisir un de mes livres',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                CheckboxListTile(
                  title: _selectedCategory == BookCategory.need
                      ? const Text(
                          'Renseigner les carcteristiques du livre dont vous avez besoin',
                        )
                      : const Text('Ajouter un nouveau livre'),
                  value: _createNewBook,
                  onChanged: (v) => setState(() {
                    _createNewBook = v ?? false;
                    _useExistingBook = !_createNewBook;
                  }),
                ),
              ],

              const SizedBox(height: 16),

              if (_createNewBook) ...[
                // Title
                CustomTextField(
                  controller: _titleController,
                  label: 'Titre du livre *',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Le titre est requis';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Classe
                CustomTextField(
                  controller: _classeController,
                  label: 'Classe (ex: 3e, 2nde) *',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'La classe est requise';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // École
                CustomTextField(
                  controller: _ecoleController,
                  label: 'École *',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return "L'école est requise";
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Langue
                DropdownButtonFormField<String>(
                  value: _selectedLangue ?? 'Français',
                  items: _langues
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedLangue = value),
                  decoration: InputDecoration(
                    labelText: 'Langue *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Année scolaire
                CustomTextField(
                  controller: _annee_scolaireController,
                  label: 'Année scolaire (ex: 2024-2025) *',
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return 'L\'année scolaire est requise';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Description
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Matière
                CustomTextField(
                  controller: _matiereController,
                  label: 'Matière (ex: Mathématiques)',
                ),
                const SizedBox(height: 16),
                // État
                DropdownButtonFormField<String>(
                  value: _selectedEtat ?? 'Bon',
                  items: _etats
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedEtat = value),
                  decoration: InputDecoration(
                    labelText: 'État du livre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              // CONDITIONAL FIELDS BASED ON CATEGORY
              // Price field for SELL
              if (_selectedCategory == BookCategory.sell) ...[
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Prix de vente',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _priceController,
                  label: 'Prix (FCFA) *',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Le prix est requis';
                    if (double.tryParse(value!) == null) {
                      return 'Entrez un nombre valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],
              // Desired books for EXCHANGE
              if (_selectedCategory == BookCategory.exchange) ...[
                // Option to use an existing book as the listing
                CheckboxListTile(
                  title: const Text(
                    'Utiliser un de mes livres existants comme annonce',
                  ),
                  value: _useExistingBook,
                  onChanged: (v) =>
                      setState(() => _useExistingBook = v ?? false),
                ),
                if (_useExistingBook)
                  DropdownButtonFormField<String>(
                    value: _selectedExistingBookId,
                    items: _availableBooks
                        .map(
                          (b) => DropdownMenuItem(
                            value: b['id']?.toString(),
                            child: Text(b['titre'] ?? b['title'] ?? 'Livre'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedExistingBookId = v),
                    decoration: InputDecoration(
                      labelText: 'Choisir un de mes livres',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Livres souhaités en échange',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                if (!_useExistingBook && _availableBooks.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _availableBooks.length,
                    itemBuilder: (context, index) {
                      final book = _availableBooks[index];
                      final bookId = book['id']?.toString() ?? '';
                      final isSelected = _selectedDesiredBooks.contains(bookId);

                      return CheckboxListTile(
                        title: Text(book['titre'] ?? 'Unknown'),
                        subtitle: Text(
                          '${book['classe']} - ${book['matiere']}',
                        ),
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedDesiredBooks.add(bookId);
                            } else {
                              _selectedDesiredBooks.remove(bookId);
                            }
                          });
                        },
                      );
                    },
                  )
                else
                  const Text(
                    'Aucun livre disponible. Ajoutez un livre d\'abord.',
                    style: TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 24),
              ],
              // Need type for NEED
              if (_selectedCategory == BookCategory.need) ...[
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Type de besoin',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedNeedType,
                  items: _needTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedNeedType = value),
                  decoration: InputDecoration(
                    labelText: 'Vous cherchez à *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (_selectedCategory == BookCategory.need &&
                        (value?.isEmpty ?? true)) {
                      return 'Le type de besoin est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // If selected need type is "Échange", show book selection
                if (_selectedNeedType == 'Échange') ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Sélectionnez un livre à proposer en échange',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  // Checkbox to add new book or use existing
                  CheckboxListTile(
                    title: const Text('Ajouter un nouveau livre sur place'),
                    value: _useExistingBook == false,
                    onChanged: (v) => setState(() => _useExistingBook = false),
                  ),
                  const SizedBox(height: 8),
                  // Filter available books: only "Disponible" status
                  _availableBooks
                          .where(
                            (b) =>
                                b['statut'] == 'Disponible' ||
                                b['etat']?.toString().toLowerCase().contains(
                                      'disponible',
                                    ) ==
                                    true,
                          )
                          .isNotEmpty
                      ? CheckboxListTile(
                          title: const Text(
                            'Choisir parmi mes livres disponibles',
                          ),
                          value: _useExistingBook == true,
                          onChanged: (v) =>
                              setState(() => _useExistingBook = true),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 12),
                  // Show dropdown if using existing book
                  if (_useExistingBook &&
                      _availableBooks
                          .where(
                            (b) =>
                                b['statut'] == 'Disponible' ||
                                b['etat']?.toString().toLowerCase().contains(
                                      'disponible',
                                    ) ==
                                    true,
                          )
                          .isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _selectedExistingBookId,
                      hint: const Text('Sélectionnez un livre disponible'),
                      items: _availableBooks
                          .where(
                            (b) =>
                                b['statut'] == 'Disponible' ||
                                b['etat']?.toString().toLowerCase().contains(
                                      'disponible',
                                    ) ==
                                    true,
                          )
                          .map(
                            (b) => DropdownMenuItem(
                              value: b['id']?.toString(),
                              child: Text(
                                '${b['titre'] ?? 'Livre'} - ${b['classe']}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedExistingBookId = v),
                      decoration: InputDecoration(
                        labelText: 'Livre à proposer',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (_useExistingBook && (value?.isEmpty ?? true)) {
                          return 'Veuillez sélectionner un livre';
                        }
                        return null;
                      },
                    )
                  else if (_useExistingBook)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Aucun livre disponible. Ajoutez un livre d\'abord.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ],
              // Submit button
              PrimaryButton(
                text: _selectedCategory == BookCategory.sell
                    ? 'Mettre en vente'
                    : _selectedCategory == BookCategory.need
                    ? 'Publier le besoin'
                    : 'Proposer en Don',
                onPressed: _submitTransaction,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
