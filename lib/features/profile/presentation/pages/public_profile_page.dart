import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trocabook_front/core/widgets/buttons/primary_button.dart';

class PublicProfilePage extends StatelessWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            Text(
              'Jane Smith',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Douala, Cameroon',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const Text('4.9 (25 reviews)'),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatCard('Books Available', '5'),
            const SizedBox(height: 16),
            _buildStatCard('Exchanges Completed', '15'),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Send Message',
              onPressed: () => context.go('/chat/exchange123'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.go('/propose-exchange/book123'),
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
            _buildReviewCard(
              'Great exchange! Book was in perfect condition.',
              '4.8',
            ),
            const SizedBox(height: 8),
            _buildReviewCard(
              'Very reliable parent. Highly recommended.',
              '5.0',
            ),
          ],
        ),
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
