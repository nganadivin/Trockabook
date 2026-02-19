class AppConstants {
  static const String appName = 'Trocabook';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = 'https://api.trocabook.com';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String booksCollection = 'books';
  static const String exchangesCollection = 'exchanges';
  static const String messagesCollection = 'messages';

  // Storage
  static const String booksImagesPath = 'books/';
  static const String avatarsPath = 'avatars/';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxBookTitleLength = 100;
  static const int maxDescriptionLength = 500;

  // Pagination
  static const int booksPerPage = 20;
  static const int messagesPerPage = 50;

  // Map
  static const double defaultLatitude = 3.8480; // Yaoundé
  static const double defaultLongitude = 11.5021;
  static const double defaultZoom = 12.0;
}
