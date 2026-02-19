import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/widgets/buttons/primary_button.dart';
import 'package:trocabook_front/core/widgets/inputs/custom_text_field.dart';
import 'package:trocabook_front/core/services/book_service.dart';
import 'package:trocabook_front/core/services/children_service.dart';
import 'package:trocabook_front/core/errors/exceptions.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _classeController = TextEditingController();
  final _ecoleController = TextEditingController();
  final _annee_scolaireController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _matiereController = TextEditingController();
  String? _selectedLangue;
  String? _selectedStatut;
  String? _selectedEtat;
  String? _selectedChildId; // ID of the child for whom the book is being added
  double _lat = 0.0;
  double _lng = 0.0;
  bool _isLoading = false;

  final BookService _bookService = BookService();
  final ChildrenService _childrenService = ChildrenService();

  List<Map<String, dynamic>> _children = [];

  final List<String> _statuts = ['Disponible', 'Échange', 'Vendu', 'Réservé'];
  final List<String> _langues = ['Français', 'Anglais', 'Espagnol'];
  final List<String> _etats = ['Neuf', 'Très bon', 'Bon', 'Moyen', 'Usé'];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _classeController.dispose();
    _ecoleController.dispose();
    _annee_scolaireController.dispose();
    _descriptionController.dispose();
    _matiereController.dispose();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    try {
      final list = await _childrenService.getMyChildren();
      if (mounted) {
        setState(() => _children = list);
      }
    } catch (e) {
      // if fetching children fails we just log; book creation will still work with mock id
      debugPrint('Failed to load children: $e');
    }
  }

  Future<void> _addBook() async {
    if (!_formKey.currentState!.validate()) return;

    if (_children.isNotEmpty && _selectedChildId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a child')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // obtain enfant id either from dropdown or fallback to first child or a mock
      final enfantId =
          _selectedChildId ??
          (_children.isNotEmpty ? _children.first['id'] : 'enfant_123');

      await _bookService.createBook(
        titre: _titleController.text,
        classe: _classeController.text,
        ecole: _ecoleController.text,
        langue: _selectedLangue ?? 'Français',
        annee_scolaire: _annee_scolaireController.text,
        statut: _selectedStatut ?? 'Disponible',
        localisation_lat: _lat,
        localisation_lng: _lng,
        enfant_id: enfantId,
        description: _descriptionController.text,
        matiere: _matiereController.text,
        etat: _selectedEtat ?? 'Bon',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Livre ajouté avec succès')),
        );
        context.pop(); // Return to my-books, triggering refresh
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
        title: const Text('Ajouter un livre'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/my-books'),
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
                'Ajouter un livre à échanger',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Select child if available
              if (_children.isNotEmpty) ...[
                const Text('Child'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedChildId,
                  items: _children
                      .map(
                        (c) => DropdownMenuItem(
                          value: c['id']?.toString(),
                          child: Text(c['prenom'] ?? 'Child'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedChildId = v),
                  decoration: InputDecoration(
                    labelText: 'Enfant *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                const Text(
                  'No child registered. The book will be added with a placeholder child.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
              ],
              // Titre
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
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Ajouter le livre',
                onPressed: _addBook,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
