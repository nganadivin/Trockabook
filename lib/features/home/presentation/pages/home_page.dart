import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/services/home_service.dart';
import 'package:trocabook_front/core/models/category_model.dart';
import 'package:trocabook_front/core/models/listing_model.dart';
import 'package:trocabook_front/core/config/app_colors.dart';
import 'package:trocabook_front/core/services/user_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeService _homeService;
  late Future<Map<String, dynamic>> _userProfileFuture;
   final UserService _userService = UserService();
   Map<String, dynamic>? _user;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _homeService = HomeService();
    _userProfileFuture = _userService.getCurrentUser();
    _loadUser();
  }

Future<void> _loadUser() async {
  try {
    final data = await _userProfileFuture;
    setState(() {
      _user = data;
      _isLoadingUser = false;
    });
  } catch (e) {
    setState(() {
      _user = {};
      _isLoadingUser = false;
    });
  }
}
  @override
 Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        final user = snapshot.data ?? {};
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Scaffold(
          appBar: _buildAppBar(user, isLoading),
          body: _buildBody(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.go('/add-book'),
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(Map<String, dynamic> user, bool isLoading) {
    final pays = user['pays'] ?? user['town'] ?? '';
    final ville = user['ville'] ?? user['localisation'] ?? 'Unknown City';

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trocabook',
            style: TextStyle(
              color: AppColors.darkGray,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.mediumGray,
                ),
                const SizedBox(width: 4),
                Text(
                  '$ville, $pays',
                  style: const TextStyle(
                    color: AppColors.mediumGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
      actions: [
        // quick shortcut so users can start an exchange from anywhere
        IconButton(
          icon: const Icon(Icons.swap_horiz, color: AppColors.darkGray),
          tooltip: 'Démarrer un échange',
          onPressed: () => context.go('/exchange-flow'),
        ),
        IconButton(
          icon: const Icon(Icons.language, color: AppColors.darkGray),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.darkGray),
          onPressed: () => context.go('/notifications'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Catégories
          _buildFixedCategories(),
          const SizedBox(height: 24),
          // Echanges
          _buildListingSection(
            'Échanges',
            _homeService.getEchanges(),
            'echanges',
          ),
          const SizedBox(height: 20),
          // Ventes
          _buildListingSection('Ventes', _homeService.getVentes(), 'ventes'),
          const SizedBox(height: 20),
          // Besoins
          _buildListingSection('Besoins', _homeService.getBesoins(), 'besoins'),
          const SizedBox(height: 20),
          // Dons
          _buildListingSection('Dons', _homeService.getDons(), 'dons'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFixedCategories() {
    final List<Category> categories = [
      Category(
        id: 'manuels',
        nom: 'Manuels Scolaires',
        icone: '📚',
        couleur: '#2196F3',
      ),
      Category(id: 'bords', nom: 'Bords', icone: '📘', couleur: '#64B5F6'),
      Category(
        id: 'maternelle',
        nom: 'Maternelle',
        icone: '🎒',
        couleur: '#4FC3F7',
      ),
      Category(
        id: 'ecole',
        nom: 'Ecole primaire',
        icone: '🏫',
        couleur: '#29B6F6',
      ),
      Category(id: 'lycee', nom: 'Lycee', icone: '🎓', couleur: '#0288D1'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Catégories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            // TextButton(
            //   onPressed: () {},
            //   child: const Text(
            //     'Plus →',
            //     style: TextStyle(color: AppColors.primaryBlue),
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCategoryCard(category),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.lightShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/search?category=${category.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category.icone, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  category.nom,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGray,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingSection(
    String title,
    Future<List<Listing>> future,
    String type,
  ) {
    // Map type to route and button text
    String getButtonText() {
      switch (type) {
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

    return FutureBuilder<List<Listing>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        }
        final items = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                Row(
                  children: [
                    if (type == 'echanges')
                      IconButton(
                        icon: const Icon(
                          Icons.swap_horiz,
                          color: AppColors.primaryBlue,
                        ),
                        tooltip: 'Démarrer un échange',
                        onPressed: () => context.go('/exchange-flow'),
                      ),
                    TextButton(
                      onPressed: () => context.go('/listings-more/$type'),
                      child: const Text(
                        'Plus →',
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              // Show "Start new" button when no items
              SizedBox(
                height: 160,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.playlist_add,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun $title disponible',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 240,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            switch (type) {
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
                          label: Text(getButtonText()),
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
                ),
              )
            else
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildListingCard(items[index], type, _user ?? {}),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildListingCard(Listing item, String type, Map<String, dynamic> user) {
    // simple helper to make first letter uppercase
    String capitalize(String s) =>
        s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

    final badgeText = capitalize(type);
    final userId = user['id']?.toString() ?? '';
    return Container(
      width: 260,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.mediumShadow],
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                switch (type) {
                  case 'echanges':
                    context.push('/propose-exchange/${item.id}');
                    break;
                  default:
                    context.push('/exchange-details/${item.id}');
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 110,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      color: AppColors.lightGray,
                      image: item.image != null
                          ? DecorationImage(
                              image: NetworkImage(item.image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.image == null
                        ? const Icon(
                            Icons.image,
                            size: 40,
                            color: AppColors.mediumGray,
                          )
                        : null,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.titre,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGray,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (item.prix != null)
                                Text(
                                  '${item.prix!.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              const Spacer(),
                              if (item.localisation != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: AppColors.mediumGray,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.localisation!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.mediumGray,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // badge overlay
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          item.ownerId == userId ? Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Votre exchange',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ) : 
          Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
