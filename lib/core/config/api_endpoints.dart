class ApiEndpoints {
  static const String baseUrl = 'https://trocabook.vercel.app';
  static const String apibaseUrl = 'https://trocabook.vercel.app';
  static const String apiPath = '/api';

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String register = '/users/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String refreshAuth = '/auth/refresh-auth';
  static const String googleAuth = '/auth/google';
  static const String phoneAuth = '/auth/phone';

  // Users
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String userMe = '/users/me';
  static const String updateProfile = '/users/me';
  static const String userStatus = '/users/{id}/status';

  // Books/Livres
  static const String books = '/livres';
  static const String myBooks = '/livres/user/{userId}';
  static const String bookDetails = '/livres/{id}';
  static const String searchBooks = '/livres/search';
  static const String createBook = '/livres';
  static const String updateBook = '/livres/{id}';
  static const String deleteBook = '/livres/{id}';
  static const String updateBookStatus = '/livres/{id}/statut';

  // Children/Enfants
  static const String children = '/enfants';
  static const String childrenByParent = '/enfants/parent/{parentId}';
  static const String childDetails = '/enfants/{id}';
  static const String createChild = '/enfants';
  static const String updateChild = '/enfants/{id}';
  static const String deleteChild = '/enfants/{id}';

  // Exchanges/Transactions
  static const String transactions = '/transactions';
  static const String transactionDetails = '/transactions/{id}';
  static const String createTransaction = '/transactions';
  static const String updateTransaction = '/transactions/{id}';
  static const String negotiateTransaction = '/transactions/{id}/negotiate';
  static const String acceptTransaction = '/transactions/{id}/accept';

  // Chats
  static const String chats = '/chats';
  static const String chatDetails = '/chats/{id}';
  static const String createChat = '/chats';
  static const String chatMessages = '/chats/{id}/messages';
  static const String sendMessage = '/chats/{id}/messages';

  // Evaluations/Ratings
  static const String evaluations = '/evaluations';
  static const String evaluationsByUser = '/evaluations/user/{userId}';
  static const String createEvaluation = '/evaluations';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/{id}/read';

  // Signalements/Reports
  static const String signalements = '/signalements';
  static const String createSignalement = '/signalements';
  static const String moderateSignalement = '/signalements/moderation';

  // Favoris/Favorites
  static const String favorites = '/favoris';
  static const String addFavorite = '/favoris';
  static const String removeFavorite = '/favoris/{id}';

  // Backoffice
  static const String backofficeLogin = '/backoffice-users/login';
  static const String backofficeUsers = '/backoffice-users';
  static const String backofficeUserDetails = '/backoffice-users/{id}';
  static const String createBackofficeUser = '/backoffice-users';
  static const String updateBackofficeUser = '/backoffice-users/{id}';
  static const String deleteBackofficeUser = '/backoffice-users/{id}';

  // Dons/Gifts
  static const String dons = '/dons';
  static const String donDetails = '/dons/{id}';
  static const String createDon = '/dons';
  static const String updateDon = '/dons/{id}';
  static const String deleteDon = '/dons/{id}';

  // Besoins/Needs
  static const String besoins = '/besoins';
  static const String besoinDetails = '/besoins/{id}';
  static const String createBesoin = '/besoins';
  static const String updateBesoin = '/besoins/{id}';
  static const String deleteBesoin = '/besoins/{id}';

  // Ventes/Sales
  static const String ventes = '/ventes';
  static const String venteDetails = '/ventes/{id}';
  static const String createVente = '/ventes';
  static const String updateVente = '/ventes/{id}';
  static const String deleteVente = '/ventes/{id}';

  // Echanges/Exchanges
  static const String echanges = '/echanges';
  static const String echangeDetails = '/echanges/{id}';
  static const String createEchange = '/echanges';
  static const String updateEchange = '/echanges/{id}';
  static const String deleteEchange = '/echanges/{id}';
}
