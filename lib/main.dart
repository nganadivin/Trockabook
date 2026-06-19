import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:trocabook_front/core/providers/listing_provider.dart';
import 'package:trocabook_front/core/providers/theme_provider.dart';
import 'package:trocabook_front/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:trocabook_front/core/diagnostic/api_diagnostic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔍 Print diagnostics au démarrage
  ApiDiagnostic.printDiagnostics();

  final authService = AuthService();
  await authService.initializeUser();

  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<ListingProvider>(
          create: (_) => ListingProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: const App(),
    ),
  );
}
