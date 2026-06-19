import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/widgets/buttons/primary_button.dart';
import 'package:trocabook_front/core/services/user_service.dart';
import 'package:trocabook_front/core/services/additional_services.dart';

class PublicProfilePage extends StatefulWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  final UserService _userService = UserService();
  final EvaluationService _evaluationService = EvaluationService();
  late Future<Map<String, dynamic>> _userFuture;
  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUserById(widget.userId);
    _reviewsFuture = _evaluationService.getUserEvaluations(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final user = snapshot.data ?? {};
          final name =
              '${user['firstName'] ?? user['prenom'] ?? ''} ${user['lastName'] ?? user['nom'] ?? ''}'
                  .trim();
          final location =
              (user['ville'] ?? user['localisation'] ?? '').toString();
          final booksCount = user['booksCount'] ?? 0;
          final exchangesCount = user['exchangesCount'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  name.isEmpty ? 'Utilisateur' : name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    location,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildStatCard('Books Available', booksCount.toString()),
                const SizedBox(height: 16),
                _buildStatCard(
                  'Exchanges Completed',
                  exchangesCount.toString(),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Send Message',
                  onPressed: () => context.go('/conversations'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.go('/propose-exchange-new'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Propose Exchange'),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Recent Reviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _reviewsFuture,
                  builder: (context, reviewSnapshot) {
                    if (reviewSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      );
                    }
                    final reviews = reviewSnapshot.data ?? [];
                    if (reviews.isEmpty) {
                      return const Text('Aucune évaluation pour le moment');
                    }
                    return Column(
                      children: reviews
                          .map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildReviewCard(
                                (r['comment'] ?? r['commentaire'] ?? '')
                                    .toString(),
                                ((r['rating'] as num?) ?? 0).toString(),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(String review, String rating) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(rating),
            const SizedBox(width: 16),
            Expanded(child: Text(review)),
          ],
        ),
      ),
    );
  }
}
