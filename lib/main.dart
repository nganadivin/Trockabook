import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:trocabook_front/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:trocabook_front/core/diagnostic/api_diagnostic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔍 Print diagnostics au démarrage
  ApiDiagnostic.printDiagnostics();

  final authService = AuthService();
  await authService.initializeUser();

  runApp(
    ChangeNotifierProvider<AuthService>(
      create: (_) => authService,
      child: const App(),
    ),
  );
}
