import 'package:flutter/foundation.dart';
import '../config/api_endpoints.dart';

/// Classe pour diagnostiquer les problèmes API
class ApiDiagnostic {
  static void printDiagnostics() {
    if (!kDebugMode) return;

    print('''
╔════════════════════════════════════════════════════════════╗
║         🔍 API DIAGNOSTICS                                 ║
╚════════════════════════════════════════════════════════════╝

📋 BASE CONFIGURATION:
   Base URL: ${ApiEndpoints.apibaseUrl}
   Base URL (alternative): ${ApiEndpoints.baseUrl}

🔐 ENDPOINTS CONFIGURÉS:
   
   ✅ AUTHENTICATION:
      - Login:           /auth/login
      - Register:        /users/register
      - Verify OTP:      /auth/verify-otp
      - Forgot Password: /auth/forgot-password
      - Logout:          /auth/logout
      
   ✅ USERS:
      - Profile (Me):    /users/me
      - Update Profile:  /users/me
      - Get User:        /users/{id}
      - User Status:     /users/{id}/status
      
   ✅ BOOKS:
      - List Books:      /livres
      - My Books:        /livres/user/{userId}
      - Create Book:     /livres (POST)
      - Update Book:     /livres/{id} (PATCH)
      - Delete Book:     /livres/{id} (DELETE)
      - Search Books:    /livres/search
      
   ✅ CHATS:
      - List Chats:      /chats
      - Get Chat:        /chats/{id}
      - Send Message:    /chats/{id}/messages (POST)
      - Get Messages:    /chats/{id}/messages
      
   ✅ TRANSACTIONS:
      - List:            /transactions
      - Create:          /transactions
      - Get Details:     /transactions/{id}
      - Negotiate:       /transactions/{id}/negotiate
      - Accept:          /transactions/{id}/accept

📤 COMPLETE URLs WILL BE:
   Base: ${ApiEndpoints.apibaseUrl}
   
   Examples:
   ➜ POST   ${ApiEndpoints.apibaseUrl}/users/register
   ➜ POST   ${ApiEndpoints.apibaseUrl}/auth/login
   ➜ GET    ${ApiEndpoints.apibaseUrl}/users/me
   ➜ POST   ${ApiEndpoints.apibaseUrl}/livres
   ➜ GET    ${ApiEndpoints.apibaseUrl}/chats

🔧 HEADERS THAT WILL BE SENT:
   Content-Type: application/json
   Accept: application/json
   Authorization: Bearer <token_if_exists>

⚠️  COMMON ISSUES TO CHECK:
   1. Is the base URL correct? Check: ${ApiEndpoints.apibaseUrl}
   2. Are there trailing slashes? (There shouldn't be)
   3. Is CORS enabled on the backend?
   4. Are the endpoints actually implemented on the backend?
   5. Check browser DevTools Network tab for actual requests

═══════════════════════════════════════════════════════════════
''');
  }

  /// Test une URL complète
  static void testEndpoint(String endpoint, String method) {
    if (!kDebugMode) return;

    final fullUrl = '${ApiEndpoints.apibaseUrl}$endpoint';
    print('''
📡 ENDPOINT TEST:
   Method: $method
   Endpoint: $endpoint
   Full URL: $fullUrl
   Status: Ready to test
''');
  }
}
