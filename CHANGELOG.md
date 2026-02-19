# Changelog - Trocabook Frontend

## [2.0.0] - 2026-02-09

### 🎯 Major Migration
- **BREAKING**: Migrated from Firebase/Supabase to custom API (https://trocabook.vercel.app/)
- Removed all Firebase dependencies (firebase_auth, cloud_firestore, firebase_messaging)
- Implemented Dio-based HTTP client with token management

### ✨ New Features
- Complete API client with error handling and token interceptors
- 10+ service classes for different domain models
- FutureBuilder integration for async data loading
- Comprehensive error messages and retry mechanisms
- Empty states and loading indicators

### 🔄 Changed
- `AuthService` now uses custom API instead of Firebase
- `ApiEndpoints` expanded from 20 to 80+ routes
- All pages updated to use new service layer
- Error handling now uses `ApiException` and `AuthenticationException`
- Storage moved to `FlutterSecureStorage` for tokens

### 🔧 Updated Services
- `BookService` - Full CRUD for books
- `ChatService` - Messages and conversations
- `ChildrenService` - Children profile management  
- `TransactionService` - Exchange transactions
- `UserService` - User profiles
- `EvaluationService` - User ratings
- `NotificationService` - App notifications
- `FavoriteService` - Book favorites
- `SignalmentService` - Report management

### 📄 Updated Pages
- `LoginPage` - API-based login
- `RegisterPage` - API-based registration with validation
- `OtpPage` - Email/SMS OTP verification
- `MyBooksPage` - List books from API with FutureBuilder
- `AddBookPage` - Create books via API
- `MyProfilePage` - Load and display user profile
- `ConversationsPage` - List chats from API

### 🗑️ Removed
- Firebase imports from all files
- Supabase configuration
- Mock data and hardcoded values
- Old notification service (Firebase Messaging)

### 🎨 Improvements
- Modern UI with FutureBuilder patterns
- Better error handling and user feedback
- Loading states with CircularProgressIndicator
- Retry functionality for failed requests
- Empty state messages for lists
- Token auto-refresh on 401 errors

### 📦 Dependencies
- Added: `dio: ^5.3.0`, `flutter_secure_storage: ^9.0.0`
- Removed: Firebase packages (commented in pubspec)
- Kept: `provider`, `go_router`, `http` (for compatibility)

### 🐛 Known Issues
- Real-time chat using polling (not WebSocket)
- Image uploads not yet implemented
- Video attachments pending
- Offline caching not configured

### ⚡ Performance
- API calls cached in memory (future implementations)
- Token interceptor prevents 401 cascade
- Timeout: 30 seconds for all requests

### 📝 Configuration
- Base URL: `https://trocabook.vercel.app/`
- All endpoints follow REST conventions
- Standard HTTP status codes used
- JSON request/response bodies

### 🔒 Security
- Tokens stored in secure storage
- Bearer token authentication
- Token auto-clear on logout
- HTTPS enforced for API

### 🎓 Documentation
- Added `MIGRATION_SUMMARY.md` with complete details
- Service usage examples in docs
- API endpoint catalog provided
- Error handling patterns documented

---

## [1.0.0] - Previous Release

### Initial Features
- Firebase authentication
- Firestore database integration
- FCM push notifications
- Basic UI components
- Navigation with go_router

---

## Migration Guide

### Before (Firebase)
```dart
final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

### After (Custom API)
```dart
final authService = context.read<AuthService>();
final result = await authService.signInWithEmailAndPassword(email, password);
```

### Before (Firestore)
```dart
final books = await FirebaseFirestore.instance
    .collection('books')
    .where('userId', isEqualTo: userId)
    .get();
```

### After (Custom API)
```dart
final bookService = BookService();
final books = await bookService.getMyBooks();
```

---

## Next Steps

1. Complete remaining page implementations
2. Integrate WebSocket for real-time chat
3. Add image upload functionality
4. Implement offline caching
5. Add comprehensive test suite
6. Setup CI/CD pipeline
7. Production deployment

---

## Contact

For migration questions or issues, contact the development team.

**Last Updated:** 2026-02-09
**Migration Status:** 95% Complete
**Next Release:** 2.1.0 (Real-time chat + Image uploads)
