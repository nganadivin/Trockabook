import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trocabook_front/core/services/additional_services.dart';
import 'package:trocabook_front/core/services/user_service.dart';

class RatingsPage extends StatefulWidget {
  const RatingsPage({super.key});

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  final EvaluationService _evaluationService = EvaluationService();
  final UserService _userService = UserService();
  late Future<List<Map<String, dynamic>>> _ratingsFuture;

  @override
  void initState() {
    super.initState();
    _ratingsFuture = _loadRatings();
  }

  Future<List<Map<String, dynamic>>> _loadRatings() async {
    final user = await _userService.getCurrentUser();
    final userId = user['id']?.toString() ?? user['_id']?.toString();
    if (userId == null) return [];
    return _evaluationService.getUserEvaluations(userId);
  }

  void _refresh() {
    if (!mounted) return;
    setState(() => _ratingsFuture = _loadRatings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Ratings')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ratingsFuture,
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

          final ratings = snapshot.data ?? [];
          if (ratings.isEmpty) {
            return const Center(child: Text('Aucune évaluation pour le moment'));
          }

          return ListView.builder(
            itemCount: ratings.length,
            itemBuilder: (context, index) {
              final rating = ratings[index];
              final userName =
                  (rating['user'] ?? rating['userName'] ?? rating['auteur'] ?? 'Utilisateur')
                      .toString();
              final initial = userName.isNotEmpty
                  ? userName[0].toUpperCase()
                  : '?';
              final comment =
                  (rating['comment'] ?? rating['commentaire'] ?? '').toString();
              final date =
                  (rating['date'] ?? rating['createdAt'] ?? '').toString();
              final ratingValue =
                  (rating['rating'] as num?)?.toDouble() ??
                  (rating['note'] as num?)?.toDouble() ??
                  0.0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(child: Text(initial)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RatingBarIndicator(
                        rating: ratingValue,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 20.0,
                      ),
                      if (comment.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(comment),
                      ],
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
