import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingsPage extends StatelessWidget {
  const RatingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock ratings data
    final ratings = [
      {
        'user': 'John Doe',
        'rating': 5.0,
        'comment': 'Great exchange! Book was in excellent condition.',
        'date': '2 days ago',
        'book': 'Harry Potter',
      },
      {
        'user': 'Jane Smith',
        'rating': 4.5,
        'comment': 'Good communication, book arrived on time.',
        'date': '1 week ago',
        'book': 'The Lord of the Rings',
      },
      {
        'user': 'Michael Johnson',
        'rating': 3.0,
        'comment': 'Book was okay, but had some wear and tear.',
        'date': '2 weeks ago',
        'book': '1984',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Ratings')),
      body: ListView.builder(
        itemCount: ratings.length,
        itemBuilder: (context, index) {
          final rating = ratings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(child: Text((rating['user'] as String)[0])),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rating['user'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Book: ${rating['book']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        rating['date'] as String,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RatingBarIndicator(
                    rating: rating['rating'] as double,
                    itemBuilder: (context, index) =>
                        const Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 20.0,
                  ),
                  const SizedBox(height: 8),
                  Text(rating['comment'] as String),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
