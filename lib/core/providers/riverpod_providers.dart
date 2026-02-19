// Riverpod Providers for Book Listing and Filtering
//
// Note: Add riverpod to pubspec.yaml:
// dependencies:
//   riverpod: ^2.4.0
//   flutter_riverpod: ^2.4.0

// Example providers (commented out - add riverpod dependency first):
/*
import 'package:riverpod/riverpod.dart';
import '../services/listing_service.dart';
import '../services/book_service.dart';
import '../models/book_category_enum.dart';

final listingServiceProvider = Provider((ref) => ListingService());
final bookServiceProvider = Provider((ref) => BookService());

// Category-based listing providers
final exchangeBooksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(listingServiceProvider);
  return service.getExchangeBooks();
});

final sellBooksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(listingServiceProvider);
  return service.getSellBooks();
});

final donateBooksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(listingServiceProvider);
  return service.getDonateBooks();
});

final needBooksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(listingServiceProvider);
  return service.getNeedBooks();
});

// Search and filter provider
final searchBooksProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, filters) async {
  final service = ref.watch(bookServiceProvider);
  return service.searchWithFilters(
    query: filters['query'],
    classe: filters['classe'],
    matiere: filters['matiere'],
    category: filters['category'],
    maxDistance: filters['maxDistance'],
    condition: filters['condition'],
  );
});

// User's books provider
final userBooksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(bookServiceProvider);
  return service.getMyBooks();
});
*/

// For now, using Provider package instead (already in project):
// See provider_setup.dart for Provider-based alternatives
