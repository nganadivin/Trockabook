import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trocabook_front/core/services/auth_service.dart';
import 'package:trocabook_front/core/services/home_service.dart';
import 'package:trocabook_front/core/models/category_model.dart';
import 'package:trocabook_front/core/models/panier_surprise_model.dart';
import 'package:trocabook_front/core/models/promotion_model.dart';
import 'package:trocabook_front/core/models/listing_model.dart';
import 'package:trocabook_front/core/config/app_colors.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeService _homeService;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _homeService = HomeService();
  }

  Future<void> _logout() async {
    try {
      final authService = context.read<AuthService>();
      await authService.logout();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('logout failed: $e')));
      }
    }
  }

  void _onNavBarTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        // Home - déjà sur la page
        break;
      case 1:
        context.go('/search'); // Promotion
        break;
      case 2:
        // Panier Surprise - reste à implémenter
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Panier Surprise - Coming Soon')),
        );
        break;
      case 3:
        // Commandes - reste à implémenter
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commandes - Coming Soon')),
        );
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-book'),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.mediumGray,
              ),
              const SizedBox(width: 4),
              const Text(
                'Yaounde, Cameroun',
                style: TextStyle(color: AppColors.mediumGray, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
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
            TextButton(
              onPressed: () {},
              child: const Text(
                'Plus →',
                style: TextStyle(color: AppColors.primaryBlue),
              ),
            ),
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
                TextButton(
                  onPressed: () => context.go('/listings-more/$type'),
                  child: const Text(
                    'Plus →',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
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
                    child: _buildListingCard(items[index], type),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildListingCard(Listing item, String type) {
    return Container(
      width: 260,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.mediumShadow],
      ),
      child: Material(
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
    );
  }

  Widget _buildCategoriesSection() {
    return FutureBuilder<List<Category>>(
      future: _homeService.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 120,
            child: Center(child: Text('Erreur: ${snapshot.error}')),
          );
        }

        final categories = snapshot.data ?? [];

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
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Plus →',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ),
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
      },
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

  Widget _buildPanierSurpriseSection() {
    return FutureBuilder<List<PanierSurprise>>(
      future: _homeService.getPaniersSurprise(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        }

        final paniers = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Panier Surprise',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Plus →',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (paniers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucun panier disponible'),
                ),
              )
            else
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: paniers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildPanierCard(paniers[index]),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPanierCard(PanierSurprise panier) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.mediumShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: AppColors.lightGray,
                  image: panier.image != null
                      ? DecorationImage(
                          image: NetworkImage(panier.image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: panier.image == null
                    ? const Center(
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: AppColors.mediumGray,
                        ),
                      )
                    : null,
              ),
              // Contenu
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      panier.titre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      panier.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${panier.quantiteRestante} restants',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (panier.dateCollecte != null)
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'dd MMM',
                              'fr_FR',
                            ).format(panier.dateCollecte!),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(
                      '${panier.prix.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionsSection() {
    return FutureBuilder<List<Promotion>>(
      future: _homeService.getPromotions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        }

        final promotions = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Promotion Récente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Plus →',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (promotions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucune promotion disponible'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPromotionCard(promotions[index]),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildPromotionCard(Promotion promotion) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.lightShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.lightGray,
                    image: promotion.image != null
                        ? DecorationImage(
                            image: NetworkImage(promotion.image!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: promotion.image == null
                      ? const Center(
                          child: Icon(
                            Icons.image,
                            size: 30,
                            color: AppColors.mediumGray,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promotion.titre,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promotion.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (promotion.code != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            promotion.code!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (promotion.remise != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '-${promotion.remise!.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
