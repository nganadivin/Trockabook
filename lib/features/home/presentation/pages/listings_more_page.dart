import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/config/app_colors.dart';
import 'package:trocabook_front/core/services/home_service.dart';
import 'package:trocabook_front/core/models/listing_model.dart';

class ListingsMorePage extends StatefulWidget {
  final String type; // 'echanges', 'ventes', 'besoins', 'dons'

  const ListingsMorePage({super.key, required this.type});

  @override
  State<ListingsMorePage> createState() => _ListingsMorePageState();
}

class _ListingsMorePageState extends State<ListingsMorePage> {
  final HomeService _homeService = HomeService();
  late Future<List<Listing>> _itemsFuture;
  // Local filter/search state
  String _searchQuery = '';
  // the transaction/listing model doesn't expose classe or matiere so those filters
  // are effectively ignored. we keep the fields for the dialog but they won't
  // actually affect the results.
  String? _filterClasse;
  String? _filterMatiere;
  double? _filterMaxDistance;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  Future<List<Listing>> _loadItems() async {
    switch (widget.type) {
      case 'echanges':
        return await _homeService.getEchanges();
      case 'ventes':
        return await _homeService.getVentes();
      case 'besoins':
        return await _homeService.getBesoins();
      case 'dons':
        return await _homeService.getDons();
      default:
        return <Listing>[];
    }
  }

  String _getTitle() {
    switch (widget.type) {
      case 'echanges':
        return 'Échanges';
      case 'ventes':
        return 'Ventes';
      case 'besoins':
        return 'Besoins';
      case 'dons':
        return 'Dons';
      default:
        return '';
    }
  }

  String _getEmptyText() {
    switch (widget.type) {
      case 'echanges':
        return 'Aucun échange disponible';
      case 'ventes':
        return 'Aucune vente disponible';
      case 'besoins':
        return 'Aucun besoin publicisé';
      case 'dons':
        return 'Aucun don disponible';
      default:
        return 'Aucun article trouvé';
    }
  }

  String _getButtonText() {
    switch (widget.type) {
      case 'echanges':
        return 'Démarrer un nouvel échange';
      case 'ventes':
        return 'Démarrer une nouvelle vente';
      case 'besoins':
        return 'Publier un besoin';
      case 'dons':
        return 'Proposer un don';
      default:
        return 'Ajouter un livre';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          if (widget.type == 'echanges')
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Démarrer un échange',
              onPressed: () => context.go('/exchange-flow'),
            ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? <Listing>[];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _getEmptyText(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 240,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        switch (widget.type) {
                          case 'echanges':
                            context.go('/exchange-flow');
                            break;
                          case 'ventes':
                            context.go('/add-sell');
                            break;
                          case 'besoins':
                            context.go('/add-need');
                            break;
                          case 'dons':
                            context.go('/add-donate');
                            break;
                          default:
                            context.go('/add-book-v2');
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: Text(_getButtonText()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // If we have items, allow searching and filtering locally using
          // the Listing model rather than raw maps.  Only the title and
          // description are available, so classe/matiere filters are effectively
          // no‑ops (the dialog still offers them but they don't change results).
          final filtered = items.where((item) {
            final title = item.titre.toLowerCase();
            if (_searchQuery.isNotEmpty &&
                !title.contains(_searchQuery.toLowerCase())) {
              return false;
            }
            // other filters ignored (not part of Listing)
            return true;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Rechercher...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () async {
                        final res = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (ctx) {
                            final classeCtrl = TextEditingController(
                              text: _filterClasse,
                            );
                            final matiereCtrl = TextEditingController(
                              text: _filterMatiere,
                            );
                            final distanceCtrl = TextEditingController(
                              text: _filterMaxDistance?.toString(),
                            );
                            return AlertDialog(
                              title: const Text('Filtres'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: classeCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Classe',
                                    ),
                                  ),
                                  TextField(
                                    controller: matiereCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Matière',
                                    ),
                                  ),
                                  TextField(
                                    controller: distanceCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Distance (km)',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop({
                                    'classe': classeCtrl.text,
                                    'matiere': matiereCtrl.text,
                                    'distance': distanceCtrl.text,
                                  }),
                                  child: const Text('Appliquer'),
                                ),
                              ],
                            );
                          },
                        );
                        if (res != null) {
                          setState(() {
                            _filterClasse =
                                (res['classe'] as String?)?.isEmpty ?? true
                                ? null
                                : res['classe'] as String?;
                            _filterMatiere =
                                (res['matiere'] as String?)?.isEmpty ?? true
                                ? null
                                : res['matiere'] as String?;
                            final d = (res['distance'] as String?);
                            _filterMaxDistance = (d == null || d.isEmpty)
                                ? null
                                : double.tryParse(d);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final title = item.titre.isNotEmpty
                        ? item.titre
                        : 'Untitled';
                    final desc = item.description;
                    final id = item.id;

                    return GestureDetector(
                      onTap: () => context.push('/book-details/$id'),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  color: AppColors.lightGray,
                                  image: () {
                                    final url = item.image;
                                    return url != null
                                        ? DecorationImage(
                                            image: NetworkImage(url),
                                            fit: BoxFit.cover,
                                          )
                                        : null;
                                  }(),
                                ),
                                child: item.image == null
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
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    desc,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
