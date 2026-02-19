# TrocaBook Feature Implementation Guide

## Overview
This document outlines the comprehensive features added to TrocaBook including authentication, book categories, transaction management, and filtering.

---

## 1. Authentication System

### Files Created/Updated:
- `auth_service.dart` - Enhanced with profile management
- `login_page.dart` - Login functionality
- `register_page.dart` - Registration with parent info
- `edit_profile_page.dart` - Profile editing

### Key Methods:
```dart
// AuthService
Future<void> signInWithEmailAndPassword(String email, String password)
Future<void> registerWithEmailAndPassword(String email, String password, Map<String, dynamic> parentData)
Future<void> logout()
Future<Map<String, dynamic>> fetchUserProfile()
Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> updates)
```

---

## 2. Book Categories System

### Models
- **BookCategory Enum** (`book_category_enum.dart`):
  - `exchange` - Exchange books
  - `sell` - Selling books with price
  - `donate` - Free donation
  - `need` - Request for books

### Book Model Enhancement
```dart
Book {
  // Base fields
  id, titre, auteur, description, niveau, classe, matiere, etat, image
  
  // Category-specific fields
  category: BookCategory
  price: double? // For sell category
  desiredBooks: List<String>? // For exchange category
  needType: String? // 'buy', 'exchange', 'free' for need category
}
```

---

## 3. Book Creation with Categories

### New Add Book Page: `add_book_page_v2.dart`

```dart
// Category-specific UI rendering:
if (category == BookCategory.sell) {
  // Show price field
  CustomTextField(label: 'Prix (FCFA)')
}

if (category == BookCategory.exchange) {
  // Show desired books selector
  ListView of user's books with checkboxes
}

if (category == BookCategory.need) {
  // Show need type dropdown
  DropdownButtonFormField(['Achat', 'Échange', 'Gratuit'])
}

if (category == BookCategory.donate) {
  // No additional fields needed
}
```

---

## 4. Book Listing Pages by Category

### Pages Created: `category_listing_pages.dart`

1. **ExchangeBooksPage** - Browse books for exchange
2. **SellBooksPage** - Browse books for sale with prices
3. **DonateBooksPage** - Browse books available for donation (grid view)
4. **NeedBooksPage** - Browse requests for books

Each page includes:
- Search functionality
- Filter dialog (class, subject, condition)
- Category-specific display (e.g., price display for sell)

---

## 5. Transaction System with States

### Transaction Status Enum (`transaction_status_enum.dart`):
```dart
enum TransactionStatus {
  pending,      // Initial proposal
  accepted,     // Receiver accepted
  rejected,     // Receiver rejected
  negotiating,  // Counter-offers in progress
  completed,    // Exchange/Sale completed
  cancelled     // Either party cancelled
}
```

### Transaction Model (`transaction_model.dart`):
```dart
Transaction {
  id: String
  bookId: String
  proposedBy: String // Initiator user ID
  receiverId: String // Receiver user ID
  status: TransactionStatus
  proposedPrice: double? // For selling
  proposedBooks: List<String>? // For exchange
  message: String?
  counterMessage: String?
  history: List<Map>? // Negotiation history
  createdAt: DateTime
  updatedAt: DateTime?
  completedAt: DateTime?
}
```

---

## 6. Example Transaction Flows

### Exchange Flow
```
User A selects book X from User B
User A proposes: "I'll give you my book Y for book X"
User A sends optional message
↓
User B receives notification
User B can:
  - ACCEPT → Creates accepted transaction → Opens chat
  - REJECT → Transaction marked as rejected
  - COUNTER OFFER → Proposes different books → Status: negotiating
↓
If accepted: Chat opens, users can discuss details
↓
User confirms completion → Status: completed
```

### Sell Flow
```
User A lists book for sale (price: 5000 FCFA)
User B proposes to buy at asking price
↓
User A can:
  - ACCEPT → Transaction accepted → Opens chat
  - REJECT → Transaction rejected
  - COUNTER OFFER → Suggests different price → Status: negotiating
↓
If accepted: Chat opens for payment/delivery discussion
↓
Completion confirmed → Status: completed
```

### Need (Book Request) Flow
```
User A needs "SVT Manual" (exchange preferred)
User B has and offers "SVT Manual"
User B proposes exchange with one of their books
↓
User A:
  - ACCEPTS → Chat opens
  - REJECTS → Can continue searching
  - COUNTER OFFERS → Suggests different books
↓
Agreement reached → Complete transaction
```

---

## 7. Services Architecture

### ListingService (`listing_service.dart`)
Handles category-based book fetching:
```dart
Future<List<Map>> getExchangeBooks()
Future<List<Map>> getSellBooks()
Future<List<Map>> getDonateBooks()
Future<List<Map>> getNeedBooks()
Future<List<Map>> getBooksByDistance(lat, lng, maxDistance)
```

### BookService (Enhanced)
```dart
Future<List<Map>> getBooksByCategory(String category)
Future<List<Map>> searchWithFilters({
  String? query,
  String? classe,
  String? matiere,
  String? category,
  double? maxDistance,
  String? condition,
})
```

---

## 8. State Management

### Provider: `listing_provider.dart`
```dart
class ListingProvider extends ChangeNotifier {
  // Load methods
  Future<void> loadExchangeBooks()
  Future<void> loadSellBooks()
  Future<void> loadDonateBooks()
  Future<void> loadNeedBooks()
  
  // Filter methods
  void setClasseFilter(String? classe)
  void setMatiereFilter(String? matiere)
  void setConditionFilter(String? condition)
  void setMaxDistance(double? distance)
  
  // Search
  Future<List<Map>> searchWithFilters({String? query})
  
  // Pagination
  void nextPage()
  void previousPage()
  void resetFilters()
}
```

### Usage in Widgets:
```dart
Consumer<ListingProvider>(
  builder: (context, provider, _) {
    return ListView(
      children: provider.exchangeBooks.map((book) {
        return BookCard(
          title: book['titre'],
          onTap: () => _proposeExchange(book),
        );
      }).toList(),
    );
  },
)
```

---

## 9. Filtering Features

### Implemented Filters:
1. **By Class** (6e, 5e, 4e, 3e, 2nde, 1ère, Terminale)
2. **By Subject** (Mathématiques, Français, Anglais, SVT, Histoire-Géo, Physique-Chimie)
3. **By Condition** (Neuf, Très bon, Bon, Moyen, Usé)
4. **By Distance** (Query parameter: maxDistance in km)

### Filter Dialog Implementation:
```dart
// In category listing pages:
void _showFilterDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => FilterDialog(
      onApply: (filters) {
        provider.setClasseFilter(filters['classe']);
        provider.setMatiereFilter(filters['matiere']);
        provider.setConditionFilter(filters['condition']);
        provider.loadExchangeBooks();
        Navigator.pop(context);
      },
    ),
  );
}
```

---

## 10. Integration with Routes

### Updated `app_routes.dart`:
```dart
GoRoute(path: '/add-book-v2', builder: (_, __) => const AddBookPageV2()),
GoRoute(path: '/exchange-books', builder: (_, __) => const ExchangeBooksPage()),
GoRoute(path: '/sell-books', builder: (_, __) => const SellBooksPage()),
GoRoute(path: '/donate-books', builder: (_, __) => const DonateBooksPage()),
GoRoute(path: '/need-books', builder: (_, __) => const NeedBooksPage()),
```

---

## 11. Example: Complete Exchange Proposal Flow

```dart
// In ProposeExchangePage (updated logic)
class ProposeExchangePageEnhanced extends StatefulWidget {
  final String bookId;
  const ProposeExchangePageEnhanced({required this.bookId});

  @override
  State createState() => _ProposeExchangePageEnhancedState();
}

class _ProposeExchangePageEnhancedState extends State<ProposeExchangePageEnhanced> {
  late Future<Map<String, dynamic>> _bookFuture;
  final TransactionService _txService = TransactionService();
  final BookService _bookService = BookService();
  
  List<Map<String, dynamic>> _userBooks = [];
  String? _selectedOfferedBook;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bookFuture = _bookService.getBookById(widget.bookId);
    _loadUserBooks();
  }

  Future<void> _loadUserBooks() async {
    try {
      final books = await _bookService.getMyBooks();
      setState(() => _userBooks = books);
    } catch (e) {
      debugPrint('Failed to load user books: $e');
    }
  }

  Future<void> _proposeExchange() async {
    if (_selectedOfferedBook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a book to offer')),
      );
      return;
    }

    try {
      final tx = await _txService.createTransaction(
        livreId: widget.bookId,
        userId: _getTargetUserId(),
        message: _messageController.text,
        offeredBooks: [_selectedOfferedBook!],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proposal sent! Awaiting response...')),
        );
        context.push('/exchange-details/${tx['id']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _bookFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final targetBook = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('Propose Exchange')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book to Exchange:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: Text(targetBook['titre']),
                    subtitle: Text('${targetBook['classe']} - ${targetBook['matiere']}'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your Books:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ..._userBooks.map((book) {
                  final isSelected = _selectedOfferedBook == book['id'];
                  return RadioListTile(
                    title: Text(book['titre']),
                    subtitle: Text(book['matiere']),
                    value: book['id'],
                    groupValue: _selectedOfferedBook,
                    onChanged: (val) => setState(() => _selectedOfferedBook = val),
                  );
                }).toList(),
                const SizedBox(height: 24),
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Optional message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _proposeExchange,
                    child: const Text('Send Proposal'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

## 12. Chat Gating Implementation

Chat should only open AFTER transaction is accepted:

```dart
// In ChatPage or ConversationsPage
class ChatPage extends StatefulWidget {
  final String exchangeId;
  const ChatPage({required this.exchangeId});

  @override
  State createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Future<Map<String, dynamic>> _txFuture;

  @override
  void initState() {
    super.initState();
    _txFuture = TransactionService().getTransactionById(widget.exchangeId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _txFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final tx = snapshot.data!;
        final status = TransactionStatus.fromString(tx['status']);

        // Chat only available if accepted
        if (status != TransactionStatus.accepted &&
            status != TransactionStatus.negotiating &&
            status != TransactionStatus.completed) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Chat available after proposal acceptance'),
                  const SizedBox(height: 16),
                  Text('Status: ${status.displayName}'),
                ],
              ),
            ),
          );
        }

        // Render normal chat UI here
        return Scaffold(
          appBar: AppBar(title: const Text('Chat')),
          body: const ChatMessages(),
        );
      },
    );
  }
}
```

---

## 13. Riverpod Migration (Optional)

To use Riverpod instead of Provider:
1. Add to `pubspec.yaml`:
```yaml
dependencies:
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
```

2. Wrap app with `ProviderScope`:
```dart
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

3. Use providers as shown in `riverpod_providers.dart`

---

## 14. Key Files Summary

| File | Purpose |
|------|---------|
| `book_category_enum.dart` | Category definitions |
| `transaction_status_enum.dart` | Transaction states |
| `book_model.dart` | Enhanced Book model |
| `transaction_model.dart` | Transaction/Proposal model |
| `listing_service.dart` | Category-based book fetching |
| `listing_provider.dart` | Provider for state management |
| `add_book_page_v2.dart` | Book creation with categories |
| `category_listing_pages.dart` | Listing pages for each category |
| `riverpod_providers.dart` | Riverpod setup (optional) |

---

## 15. Next Steps for Implementation

1. ✅ Create models and enums
2. ✅ Create services
3. ✅ Create providers
4. ✅ Create UI pages
5. **TODO**: Update routes in `app_routes.dart`
6. **TODO**: Update navigation to use new pages
7. **TODO**: Enhance authentication pages (register, edit profile)
8. **TODO**: Add distance-based filtering (requires location service)
9. **TODO**: Implement real API endpoints
10. **TODO**: Add error handling and loading states

---

## Notes

- All files use the existing app color scheme (`AppColors`)
- Icons and UI follow Material Design
- Providers extend `ChangeNotifier` for easy integration
- Services use the existing `ApiClient` for HTTP requests
- Mock data included for testing without backend

