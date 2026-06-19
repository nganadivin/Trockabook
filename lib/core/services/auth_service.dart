import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import 'package:flutter/material.dart';
import '../network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // // // 1. Crée une instance interne privée
  // static final AuthService _instance = AuthService._internal();

  // // // 2. Un constructeur "factory" qui renvoie toujours la même instance
  // factory AuthService() {
  //   return _instance;
  // }

  // // // 3. Le vrai constructeur privé
  // AuthService._internal();

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Récupère le profil utilisateur depuis l'API
  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final response = await _apiClient.get('/users/me');
      return response.data ?? {};
    } on DioException catch (e) {
      throw AuthenticationException(_extractErrorMessage(e, 'Failed to fetch user profile'));
    } catch (e) {
      throw AuthenticationException('Error fetching user profile: $e');
    }
  }

  /// Extrait un message d'erreur lisible depuis une DioException, quel que
  /// soit le type du corps de réponse renvoyé par le backend (Map, String ou null).
  String _extractErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      return data['message']?.toString() ?? e.message ?? fallback;
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    return e.message ?? fallback;
  }

  /// Initialise l'utilisateur au démarrage de l'app
  Future<void> initializeUser() async {
    try {
      String? token = await _storage.read(key: 'idToken');
      if (token != null) {
        _currentUser = await fetchUserProfile();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur initialisation: $e');
      await logout();
    }
  }

  /// Appelé après une connexion réussie
  void onLoginSuccess(Map<String, dynamic> userData) {
    _currentUser = userData;
    notifyListeners();
  }

  /// Connexion avec email et mot de passe
  Future<Map<String, dynamic>?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      debugPrint('Starting login attempt for email: $email');

      final payload = {'email': email, 'password': password};

      debugPrint('Sending login request to /auth/login');

      final response = await _apiClient.post('/auth/login', payload);

      debugPrint('Login successful.');

      final data = response.data ?? {};
      if (data['idToken'] != null) {
        await _storage.write(key: 'idToken', value: data['idToken']);
        if (data['refreshToken'] != null) {
          await _storage.write(
            key: 'refreshToken',
            value: data['refreshToken'],
          );
        }
        onLoginSuccess(data);
        return data;
      } else {
        throw AuthenticationException('No token received from server');
      }
    } on DioException catch (e) {
      debugPrint('DioException caught in signInWithEmailAndPassword:');
      debugPrint('   Status Code: ${e.response?.statusCode}');
      debugPrint('   Message: ${e.message}');
      debugPrint(
        '   Request URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}',
      );
      debugPrint('   Response Body: ${e.response?.data}');

      String errorMessage = e.response?.data is Map
          ? e.response?.data['message'] ?? e.message ?? 'Login failed'
          : e.message ?? 'Login failed';

      throw AuthenticationException(errorMessage);
    } catch (e) {
      debugPrint('Generic exception in signInWithEmailAndPassword: $e');
      throw AuthenticationException(e.toString());
    }
  }

  /// Création d'un nouvel utilisateur
  Future<dynamic> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String ville,
    required double latitude,
    required double longitude,
    required String profileImage,
    required int numberOfChildren,
    required int age,
    required List<String> roles,
    required bool cgu_valide,
  }) async {
    try {
      debugPrint('Starting user registration for email: $email');

      final payload = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'telephone': phone,
        'ville': ville,
        'latitude': latitude,
        'longitude': longitude,
        'profileImage': profileImage,
        'numberOfChildren': numberOfChildren,
        'age': age,
        'roles': roles,
        'cgu_valide': cgu_valide,
      };

      debugPrint('Sending registration request to /users/register');

      final response = await _apiClient.post('/users/register', payload);

      debugPrint('Registration successful.');

      return response.data;
    } on DioException catch (e) {
      debugPrint('DioException caught in createUser:');
      debugPrint('   Status Code: ${e.response?.statusCode}');
      debugPrint('   Message: ${e.message}');
      debugPrint(
        '   Request URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}',
      );
      debugPrint('   Request Method: ${e.requestOptions.method}');
      debugPrint('   Response Status: ${e.response?.statusCode}');
      debugPrint('   Response Body: ${e.response?.data}');

      // Extraire le message d'erreur
      String errorMessage = 'Registration failed';
      if (e.response?.data is Map) {
        errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            e.message ??
            'Registration failed';
      } else if (e.response?.data is String) {
        errorMessage = e.response?.data as String;
      } else {
        errorMessage = e.message ?? 'Registration failed';
      }

      throw AuthenticationException(errorMessage);
    } catch (e) {
      debugPrint('Generic exception in createUser: $e');
      throw AuthenticationException('Error during registration: $e');
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      // Appel optionnel à l'API pour notifier la déconnexion
      await _apiClient.post('/auth/logout', {});
    } catch (e) {
      debugPrint('Error calling logout endpoint: $e');
    }

    await _storage.deleteAll();
    _currentUser = null;
    notifyListeners();
  }

  /// Vérification si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: 'idToken');
    return token != null;
  }

  /// Mise à jour du profil utilisateur
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? ville,
    double? latitude,
    double? longitude,
    String? profileImage,
    int? age,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (phone != null) body['telephone'] = phone;
      if (ville != null) body['ville'] = ville;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (profileImage != null) body['profileImage'] = profileImage;
      if (age != null) body['age'] = age;

      final response = await _apiClient.patch('/users/me', body);
      final updatedUser = response.data ?? {};

      _currentUser = updatedUser;
      notifyListeners();

      return updatedUser;
    } on DioException catch (e) {
      throw AuthenticationException(_extractErrorMessage(e, 'Failed to update profile'));
    } catch (e) {
      throw AuthenticationException(e.toString());
    }
  }

  /// Mot de passe oublié
  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.post('/auth/forgot-password', {'email': email});
    } on DioException catch (e) {
      throw AuthenticationException(
        _extractErrorMessage(e, 'Failed to process forgot password'),
      );
    } catch (e) {
      throw AuthenticationException(e.toString());
    }
  }

  /// Vérifier OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      debugPrint('Verifying OTP for email: $email');

      final payload = {'email': email, 'otp': otp};

      debugPrint('Sending OTP verification to /auth/verify-otp');

      final response = await _apiClient.post('/auth/verify-otp', payload);

      debugPrint('OTP verification successful.');

      final data = response.data ?? {};
      if (data['idToken'] != null) {
        await _storage.write(key: 'idToken', value: data['idToken']);
        if (data['refreshToken'] != null) {
          await _storage.write(
            key: 'refreshToken',
            value: data['refreshToken'],
          );
        }
        onLoginSuccess(data);
        return data;
      } else {
        throw AuthenticationException('No token received from server');
      }
    } on DioException catch (e) {
      debugPrint('DioException caught in verifyOtp:');
      debugPrint('   Status Code: ${e.response?.statusCode}');
      debugPrint('   Message: ${e.message}');
      debugPrint(
        '   Request URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}',
      );
      debugPrint('   Response Body: ${e.response?.data}');

      String errorMessage = e.response?.data is Map
          ? e.response?.data['message'] ??
                e.message ??
                'OTP verification failed'
          : e.message ?? 'OTP verification failed';

      throw AuthenticationException(errorMessage);
    } catch (e) {
      debugPrint('Generic exception in verifyOtp: $e');
      throw AuthenticationException(e.toString());
    }
  }
}
