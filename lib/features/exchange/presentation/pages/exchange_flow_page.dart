import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/config/app_colors.dart';
import 'package:trocabook_front/core/services/book_service.dart';
import 'package:trocabook_front/core/services/home_service.dart';
import 'package:trocabook_front/core/services/transaction_service.dart';
import 'package:trocabook_front/core/services/auth_service.dart';
import 'package:trocabook_front/core/errors/exceptions.dart';
import 'package:trocabook_front/core/widgets/app_snackbar.dart';
import 'package:trocabook_front/core/widgets/inputs/custom_text_field.dart';

class ExchangeFlowPage extends StatefulWidget {
  const ExchangeFlowPage({super.key});

  @override
  State<ExchangeFlowPage> createState() => _ExchangeFlowPageState();
}

class _ExchangeFlowPageState extends State<ExchangeFlowPage> {
  final BookService _bookService = BookService();
  final HomeService _homeService = HomeService();
  final TransactionService _transactionService = TransactionService();

  // Step 1: Choose offered book
  int _currentStep = 1;
  bool _useExistingBook = true;
  String? _selectedOfferedBookId;
  List<Map<String, dynamic>> _availableBooks = [];

  // New book form fields
  final _titleController = TextEditingController();
  final _classeController = TextEditingController();
  final _ecoleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _matiereController = TextEditingController();

  String? _selectedLangue = 'Français';
  String? _selectedEtat = 'Bon';
  String? _desiredBookTitle;
  String? _desiredBookClasse;
  String? _desiredBookMatiere;
  bool _openToProposals = false;

  // Optional step: Target existing listing instead of creating new annonce
  late Future<List<dynamic>> _exchangeListingsFuture;
  String? _selectedTargetListingId;
  bool _showTargetListings = false;

  // General state
  final List<String> _langues = ['Français', 'Anglais', 'Espagnol'];
  final List<String> _etats = ['Neuf', 'Très bon', 'Bon', 'Moyen', 'Usé'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableBooks();
    _exchangeListingsFuture = _homeService.getEchanges();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _classeController.dispose();
    _ecoleController.dispose();
    _descriptionController.dispose();
    _matiereController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableBooks() async {
    try {
      final list = await _bookService.getMyBooks();
      if (mounted) {
        setState(
          () => _availableBooks = list
              .where(
                (b) =>
                    b['statut'] == 'Disponible' ||
                    b['etat']?.toString().toLowerCase().contains(
                          'disponible',
                        ) ==
                        true,
              )
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('Failed to load available books: $e');
    }
  }

  void _proceedToStep2() {
    if (_useExistingBook &&
        (_selectedOfferedBookId == null || _selectedOfferedBookId!.isEmpty)) {
      AppSnackbar.show(context, 'Veuillez sélectionner un livre');
      return;
    }
    if (!_useExistingBook &&
        (_titleController.text.isEmpty ||
            _classeController.text.isEmpty ||
            _ecoleController.text.isEmpty)) {
      AppSnackbar.show(context, 'Veuillez remplir tous les champs requis');
      return;
    }
    setState(() => _currentStep = 2);
  }

  Future<void> _submitExchange() async {
    // Validate step 2
    if (!_openToProposals &&
        (_desiredBookTitle == null ||
            _desiredBookTitle!.isEmpty ||
            _desiredBookClasse == null ||
            _desiredBookClasse!.isEmpty ||
            _desiredBookMatiere == null ||
            _desiredBookMatiere!.isEmpty)) {
      AppSnackbar.show(
        context,
        'Veuillez spécifier le livre ou permettre les propositions',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      String offeredBookId = _selectedOfferedBookId ?? '';

      // If adding new book, create it first
      if (!_useExistingBook) {
        final newBook = await _bookService.createBook(
          titre: _titleController.text,
          classe: _classeController.text,
          ecole: _ecoleController.text,
          langue: _selectedLangue ?? 'Français',
          annee_scolaire: DateTime.now().year.toString(),
          statut: 'Échange',
          localisation_lat: 0.0,
          localisation_lng: 0.0,
          enfant_id: 'enfant_123',
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

        await _transactionService.createTransaction(
          livreId: offeredBookId,
          userId: currentUserId,
          type: 'exchange',
          prix: 0,
        );

        if (mounted) {
          AppSnackbar.show(context, 'Annonce créée', error: false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Démarrer un échange'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _currentStep == 1 ? _buildStep1() : _buildStep2(),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Étape 1: Choisissez le livre à proposer',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Option 1: Use existing book
          Card(
            child: CheckboxListTile(
              title: const Text('Choisir parmi mes livres disponibles'),
              subtitle: Text(
                _availableBooks.isEmpty
                    ? 'Aucun livre disponible'
                    : '${_availableBooks.length} livre(s)',
              ),
              value: _useExistingBook && _availableBooks.isNotEmpty,
              onChanged: _availableBooks.isNotEmpty
                  ? (v) => setState(() => _useExistingBook = v ?? false)
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // Show dropdown if using existing book
          if (_useExistingBook && _availableBooks.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              value: _selectedOfferedBookId,
              hint: const Text('Sélectionnez un livre...'),
              items: _availableBooks
                  .map(
                    (b) => DropdownMenuItem(
                      value: b['id']?.toString(),
                      child: Text('${b['titre'] ?? 'Livre'} - ${b['classe']}'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedOfferedBookId = v),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Option 2: Add new book
          Card(
            child: CheckboxListTile(
              title: const Text('Ajouter un nouveau livre'),
              subtitle: const Text(
                'Enregistrer un nouveau livre pour cet échange',
              ),
              value: !_useExistingBook,
              onChanged: (v) =>
                  setState(() => _useExistingBook = !(v ?? false)),
            ),
          ),
          const SizedBox(height: 24),

          // Show form if adding new book
          if (!_useExistingBook) ...[
            const Text(
              'Informations du livre',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _titleController,
              label: 'Titre du livre *',
              validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _classeController,
              label: 'Classe *',
              validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _ecoleController,
              label: 'École *',
              validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedLangue,
              items: _langues
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedLangue = v),
              decoration: InputDecoration(
                labelText: 'Langue',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(controller: _matiereController, label: 'Matière'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedEtat,
              items: _etats
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedEtat = v),
              decoration: InputDecoration(
                labelText: 'État',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
          ],

          // Next button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _proceedToStep2,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Continuer',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Étape 2: Définissez votre échange',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Option 1: Open to proposals
          Card(
            child: CheckboxListTile(
              title: const Text('Ouvert aux propositions'),
              subtitle: const Text('Laissez les gens faire leurs propositions'),
              value: _openToProposals,
              onChanged: (v) => setState(() => _openToProposals = v ?? false),
            ),
          ),
          const SizedBox(height: 16),

          // Option 2: Specify desired book
          if (!_openToProposals) ...[
            const Text(
              'Livre que vous cherchez',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => _desiredBookTitle = v),
              decoration: InputDecoration(
                labelText: 'Titre du livre *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => _desiredBookClasse = v),
              decoration: InputDecoration(
                labelText: 'Classe *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => _desiredBookMatiere = v),
              decoration: InputDecoration(
                labelText: 'Matière',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Option 3: Target an existing listing (optional)
          const Divider(),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Proposer pour une annonce existante'),
            subtitle: const Text(
              'Chercher parmi les besoins d\'autres utilisateurs',
            ),
            value: _showTargetListings,
            onChanged: (v) => setState(() => _showTargetListings = v ?? false),
          ),
          const SizedBox(height: 16),

          // Show exchange listings if enabled
          if (_showTargetListings) ...[
            const Text(
              'Annonces d\'échange disponibles',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<dynamic>>(
              future: _exchangeListingsFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: Text('Aucune annonce trouvée')),
                  );
                }

                return SizedBox(
                  height: 250,
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final id = (item is Map)
                          ? (item['id']?.toString() ??
                                item['_id']?.toString() ??
                                '')
                          : (item.id?.toString() ?? '');
                      final title = (item is Map)
                          ? (item['titre'] ?? item['title'] ?? '')
                          : (item.titre ?? '');
                      final description = (item is Map)
                          ? (item['description'] ?? '')
                          : (item.description ?? '');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: RadioListTile<String>(
                          value: id,
                          groupValue: _selectedTargetListingId,
                          onChanged: (v) =>
                              setState(() => _selectedTargetListingId = v),
                          title: Text(title),
                          subtitle: Text(description),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Submit buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 1),
                  child: const Text('Retour'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitExchange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : const Text(
                          'Créer l\'échange',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
