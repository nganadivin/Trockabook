import 'package:go_router/go_router.dart';
import 'package:trocabook_front/features/settings/presentation/pages/setting_page.dart';
import '../core/services/auth_service.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/profile/presentation/pages/my_profile_page.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';
import '../features/profile/presentation/pages/public_profile_page.dart';
import '../features/books/presentation/pages/add_book_page.dart';
import '../features/books/presentation/pages/add_book_page_v2.dart';
import '../core/models/book_category_enum.dart';
import '../features/books/presentation/pages/my_books_page.dart';
import '../features/books/presentation/pages/book_details_page.dart';
import '../features/books/presentation/pages/edit_book_page.dart';
import '../features/books/presentation/pages/category_listing_pages.dart';
import '../features/search/presentation/pages/search_page.dart'
    hide FiltersPage;
import '../features/search/presentation/pages/filters_page.dart';
import '../features/exchange/presentation/pages/propose_exchange_page.dart';
import '../features/exchange/presentation/pages/propose_exchange_new_page.dart';
import '../features/exchange/presentation/pages/exchange_details_page.dart';
import '../features/exchange/presentation/pages/exchanges_history_page.dart';
import '../features/chat/presentation/pages/conversations_page.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/map/presentation/pages/map_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/moderation/presentation/pages/moderation_page.dart';
import '../features/needs/presentation/pages/needs_page.dart';
import '../features/ratings/presentation/pages/ratings_page.dart';
import '../features/home/presentation/pages/listings_more_page.dart';
import '../features/home/presentation/pages/main_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) async {
      final authService = AuthService();
      final bool loggedIn = await authService.isLoggedIn();

      // Si l'utilisateur n'est pas connecté et essaie d'aller ailleurs qu'au login
      // if (!loggedIn &&
      //     state.matchedLocation != '/login' &&  state.matchedLocation != '/register') {
      //   return '/register';
      // }

      // Si l'utilisateur est connecté et essaie d'aller au login, on l'envoie à l'accueil
      if (loggedIn && state.matchedLocation == '/login') {
        return '/home';
      }

      return null; // Pas de redirection nécessaire
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: '/otp', builder: (context, state) => const OtpPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/listings-more/:type',
        builder: (context, state) =>
            ListingsMorePage(type: state.pathParameters['type']!),
      ),
      GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage1(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MyProfilePage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/public-profile/:userId',
        builder: (context, state) =>
            PublicProfilePage(userId: state.pathParameters['userId']!),
      ),
      GoRoute(
        path: '/add-book',
        builder: (context, state) => const AddBookPage(),
      ),
      GoRoute(
        path: '/my-books',
        builder: (context, state) => const MyBooksPage(),
      ),
      GoRoute(
        path: '/book-details/:bookId',
        builder: (context, state) =>
            BookDetailsPage(bookId: state.pathParameters['bookId']!),
      ),
      GoRoute(
        path: '/edit-book/:bookId',
        builder: (context, state) =>
            EditBookPage(bookId: state.pathParameters['bookId']!),
      ),
      GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
      GoRoute(
        path: '/filters',
        builder: (context, state) => const FiltersPage(),
      ),
      GoRoute(
        path: '/propose-exchange/:bookId',
        builder: (context, state) =>
            ProposeExchangePage(bookId: state.pathParameters['bookId']!),
      ),
      GoRoute(
        path: '/propose-exchange-new',
        builder: (context, state) => const ProposeExchangeNewPage(),
      ),
      GoRoute(
        path: '/exchange-details/:exchangeId',
        builder: (context, state) => ExchangeDetailsPage(
          exchangeId: state.pathParameters['exchangeId']!,
        ),
      ),
      GoRoute(
        path: '/exchanges-history',
        builder: (context, state) => const ExchangesHistoryPage(),
      ),
      GoRoute(
        path: '/conversations',
        builder: (context, state) => const ConversationsPage(),
      ),
      GoRoute(
        path: '/chat/:exchangeId',
        builder: (context, state) =>
            ChatPage(exchangeId: state.pathParameters['exchangeId']!),
      ),
      GoRoute(path: '/map', builder: (context, state) => const MapPage()),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/moderation',
        builder: (context, state) => const ModerationPage(),
      ),
      GoRoute(path: '/needs', builder: (context, state) => const NeedsPage()),
      GoRoute(
        path: '/ratings',
        builder: (context, state) => const RatingsPage(),
      ),
      // New category-based listing pages
      GoRoute(
        path: '/add-book-v2',
        builder: (context, state) => const AddBookPageV2(),
      ),
      // Per-type add pages that preselect category
      GoRoute(
        path: '/add-exchange',
        builder: (context, state) =>
            const AddBookPageV2(initialCategory: BookCategory.exchange),
      ),
      GoRoute(
        path: '/add-sell',
        builder: (context, state) =>
            const AddBookPageV2(initialCategory: BookCategory.sell),
      ),
      GoRoute(
        path: '/add-donate',
        builder: (context, state) =>
            const AddBookPageV2(initialCategory: BookCategory.donate),
      ),
      GoRoute(
        path: '/add-need',
        builder: (context, state) =>
            const AddBookPageV2(initialCategory: BookCategory.need),
      ),
      GoRoute(
        path: '/exchange-books',
        builder: (context, state) => const ExchangeBooksPage(),
      ),
      GoRoute(
        path: '/sell-books',
        builder: (context, state) => const SellBooksPage(),
      ),
      GoRoute(
        path: '/donate-books',
        builder: (context, state) => const DonateBooksPage(),
      ),
      GoRoute(
        path: '/need-books',
        builder: (context, state) => const NeedBooksPage(),
      ),
    ],
  );
}
