# Corrections - Format des Transactions Backend

## Problème identifié
L'API backend attendait un format différent pour les transactions :
- **Attendu** : `livre_id`, `parent_offreur_id`, `type`
- **Envoyé** : `livreId`, `userId`, `message`, `offeredBooks`

**Erreur reçue** :
```json
{
    "property livreId should not exist",
    "property userId should not exist",
    "property message should not exist",
    "property offeredBooks should not exist",
    "parent_offreur_id must be a string",
    "livre_id must be a string",
    "type must be a string"
}
```

## Solutions appliquées

### 1️⃣ TransactionService.createTransaction()
**Fichier** : `lib/core/services/transaction_service.dart`

Signature mise à jour :
```dart
Future<Map<String, dynamic>> createTransaction({
  required String livreId,        // → livre_id
  required String userId,         // → parent_offreur_id
  required String type,           // NEW: exchange|sell|donate|need
  String? message,                // REMOVED (not accepted)
  List<String>? offeredBooks,     // REMOVED (not accepted)
})
```

Body envoyé au backend :
```dart
final body = {
  'livre_id': livreId,
  'parent_offreur_id': userId,
  'type': type,
};
```

---

### 2️⃣ ExchangeFlowPage
**Fichier** : `lib/features/exchange/presentation/pages/exchange_flow_page.dart`

#### Appel 1 - Proposition à annonce existante (ligne 162)
```dart
// AVANT :
createTransaction(
  livreId: _selectedTargetListingId!,
  userId: ownerId,
  message: null,
  offeredBooks: [offeredBookId],
)

// APRÈS :
createTransaction(
  livreId: offeredBookId,      // Le livre qu'on propose
  userId: 'current_user',
  type: 'exchange',
)
```

#### Appel 2 - Création annonce d'échange (ligne 181)
```dart
// AVANT :
createTransaction(
  livreId: offeredBookId,
  userId: 'current_user',
  message: _openToProposals ? '...' : '...',
  offeredBooks: [offeredBookId],
)

// APRÈS :
createTransaction(
  livreId: offeredBookId,
  userId: 'current_user',
  type: 'exchange',
)
```

---

### 3️⃣ AddBookPageV2 (Sell/Donate/Need)
**Fichier** : `lib/features/books/presentation/pages/add_book_page_v2.dart`

Après création d'un livre (Sell/Donate/Need), création automatique de la transaction :

```dart
// Mapping de la catégorie au type de transaction
final transactionType = _selectedCategory == BookCategory.sell
    ? 'sell'
    : _selectedCategory == BookCategory.donate
    ? 'donate'
    : 'need';

createTransaction(
  livreId: bookId,
  userId: 'current_user',
  type: transactionType,
)
```

---

### 4️⃣ ProposeExchangePage
**Fichier** : `lib/features/exchange/presentation/pages/propose_exchange_page.dart`

```dart
// AVANT :
createTransaction(
  livreId: widget.bookId,
  userId: ownerId.toString(),
  message: _messageController.text.isEmpty ? null : _messageController.text,
  offeredBooks: _selectedBooks,
)

// APRÈS :
createTransaction(
  livreId: _selectedBooks.first,  // Le livre qu'on propose
  userId: 'current_user',
  type: 'exchange',
)
```

---

### 5️⃣ ProposeExchangeNewPage
**Fichier** : `lib/features/exchange/presentation/pages/propose_exchange_new_page.dart`

Signature simplifiée de la méthode helper :
```dart
// AVANT :
Future<Map<String, dynamic>> _transaction_service_create(
  String livreId,
  String ownerId,
) async {
  return await _transactionService.createTransaction(
    livreId: livreId,
    userId: ownerId,
    message: _messageCtrl.text.isEmpty ? null : _messageCtrl.text,
    offeredBooks: _selectedOfferedBooks,
  );
}

// APRÈS :
Future<Map<String, dynamic>> _transaction_service_create(
  String livreId,
) async {
  return await _transactionService.createTransaction(
    livreId: livreId,
    userId: 'current_user',
    type: 'exchange',
  );
}
```

Et l'appel :
```dart
// AVANT :
final res = await _transaction_service_create(listingId, ownerId);

// APRÈS :
final res = await _transaction_service_create(_selectedOfferedBooks.first);
```

---

## Résumé des changements

| Fichier | Modification | Paramètres corrigés |
|---------|--------------|-------------------|
| `transaction_service.dart` | Signature + body | `livre_id`, `parent_offreur_id`, `type` |
| `exchange_flow_page.dart` | 2 appels corrigés | `type: 'exchange'` |
| `add_book_page_v2.dart` | Création auto transactions | `type: 'sell'|'donate'|'need'` |
| `propose_exchange_page.dart` | 1 appel corrigé | `type: 'exchange'` |
| `propose_exchange_new_page.dart` | Signature + 1 appel | `type: 'exchange'` |

---

## Validation
✅ `flutter analyze` : **143 issues** (infos/warnings uniquement)  
✅ Aucune erreur de compilation  
✅ Tous les appels utilisent les bons paramètres
