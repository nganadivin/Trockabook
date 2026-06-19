import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/services/home_service.dart';
import 'package:trocabook_front/core/models/listing_model.dart';

class NeedsPage extends StatefulWidget {
  const NeedsPage({super.key});

  @override
  State<NeedsPage> createState() => _NeedsPageState();
}

class _NeedsPageState extends State<NeedsPage> {
  final HomeService _homeService = HomeService();
  late Future<List<Listing>> _needsFuture;

  @override
  void initState() {
    super.initState();
    _needsFuture = _homeService.getBesoins();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() => _needsFuture = _homeService.getBesoins());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Needs')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Listing>>(
              future: _needsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Erreur: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final needs = snapshot.data ?? [];
                if (needs.isEmpty) {
                  return const Center(child: Text('Aucun besoin publié'));
                }

                return ListView.builder(
                  itemCount: needs.length,
                  itemBuilder: (context, index) {
                    final need = needs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          need.titre.isNotEmpty ? need.titre : 'Sans titre',
                        ),
                        subtitle: Text(need.description),
                        onTap: () => context.push('/book-details/${need.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => context.go('/add-need'),
              child: const Text('Post a Need'),
            ),
          ),
        ],
      ),
    );
  }
}
