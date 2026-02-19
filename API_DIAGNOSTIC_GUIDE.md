# 🔍 Guide de Diagnostic - Erreur 404 API

## Problème Identifié
Erreur `404 (Not Found)` sur les appels API, notamment `/users/register` vers `https://trocabook.vercel.app/`

---

## ✅ Vérifications Effectuées

### 1. **Configuration des URLs**
- ✅ `ApiEndpoints.apibaseUrl` = `https://trocabook.vercel.app/`
- ✅ Endpoints correctement configurés dans `lib/core/config/api_endpoints.dart`
- ✅ ApiClient utilise le bon baseUrl: `ApiEndpoints.apibaseUrl`

### 2. **Headers HTTP**
Les headers suivants sont maintenant envoyés avec chaque requête:
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer <token> (si disponible)
```

### 3. **Logging Détaillé Activé**

Le système enregistre maintenant:

#### 📤 **REQUEST LOG** (avant envoi)
```
📡 [API REQUEST]
   URL: https://trocabook.vercel.app//users/register
   Method: POST
   Headers: {...}
   Body: {...}
   ✅ Token added: eyJhbGc... (si applicable)
```

#### ✅ **RESPONSE LOG** (succès)
```
✅ [API RESPONSE] Status: 200
   Data: {...}
```

#### ❌ **ERROR LOG** (erreurs)
```
❌ [API ERROR]
   Status: 404
   Message: ...
   URL: https://trocabook.vercel.app//users/register
   Response: {...}
   Full Response Body: {...}
```

---

## 🔧 Améliorations Apportées

### 1. **ApiClient Enhanced Logging** (`lib/core/network/api_client.dart`)
- ✅ Log de chaque requête (URL, method, headers, body)
- ✅ Log de chaque réponse (status, data)
- ✅ Log détaillé des erreurs avec URL complète
- ✅ Affichage des tokens (masqué après 20 caractères)

### 2. **AuthService Detailed Error Handling** (`lib/core/services/auth_service.dart`)

#### **`createUser()` (Registration)**
```dart
try {
  print('🔄 Starting user registration...');
  print('📧 Email: $email');
  print('📤 Sending registration request to /users/register');
  print('📦 Payload: $payload');
  
  final response = await _apiClient.post('/users/register', payload);
  
  print('✅ Registration successful!');
  print('📦 Response: ${response.data}');
} on DioException catch (e) {
  print('❌ DioException caught in createUser:');
  print('   Status Code: ${e.response?.statusCode}');
  print('   Response Body: ${e.response?.data}');
  print('   Request URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}');
  // ... plus de détails
}
```

#### **`signInWithEmailAndPassword()` (Login)**
- ✅ Log complet de la tentative de connexion
- ✅ Affichage de l'URL complète
- ✅ Détails de la réponse d'erreur

#### **`verifyOtp()` (OTP Verification)**
- ✅ Log du processus de vérification OTP
- ✅ Détails complets de l'erreur si 404

### 3. **API Diagnostic Tool** (`lib/core/diagnostic/api_diagnostic.dart`)
- ✅ Affiche la configuration complète au démarrage
- ✅ Liste tous les endpoints configurés
- ✅ Montre les URLs complètes
- ✅ Affiche les headers qui seront envoyés
- ✅ Liste les problèmes courants à vérifier

---

## 📋 Logs Affichés au Démarrage

Quand l'app démarre, vous verrez:

```
╔════════════════════════════════════════════════════════════╗
║         🔍 API DIAGNOSTICS                                 ║
╚════════════════════════════════════════════════════════════╝

📋 BASE CONFIGURATION:
   Base URL: https://trocabook.vercel.app/

🔐 ENDPOINTS CONFIGURÉS:
   ✅ AUTHENTICATION:
      - Login:           /auth/login
      - Register:        /users/register
      - Verify OTP:      /auth/verify-otp
   ... (liste complète)

📤 COMPLETE URLs WILL BE:
   ➜ POST   https://trocabook.vercel.app//users/register
   ➜ POST   https://trocabook.vercel.app//auth/login
   ... (autres URLs)
```

---

## 🎯 Comment Diagnostiquer le 404

### **Étape 1: Ouvrir la Console du Navigateur**
- F12 → Onglet "Console"

### **Étape 2: Tenter une Action (login, register, etc.)**

### **Étape 3: Chercher les Logs (dans cet ordre)**

1. **🔍 Logs au démarrage** (API DIAGNOSTICS)
   - Vérifier que Base URL est correct
   - Vérifier que les endpoints sont listés

2. **📡 Logs de requête** (API REQUEST)
   - Copier l'URL complète
   - Tester dans un nouvel onglet
   - Vérifier que c'est bien: `https://trocabook.vercel.app//users/register`

3. **❌ Logs d'erreur** (API ERROR)
   - Lire le Status Code (404, 500, etc.)
   - Regarder le Response Body
   - Noter le message exact

### **Étape 4: Onglet "Network" du Navigateur**
- Rafraîchir la page (Ctrl+Shift+R)
- Tenter l'action problématique
- Cliquer sur la requête qui échoue
- Vérifier:
  - **Request URL** - doit être complet
  - **Request Method** - POST/GET/etc
  - **Request Headers** - Content-Type, Authorization
  - **Status Code** - 404? 500? 401?
  - **Response** - voir le corps de la réponse d'erreur

---

## 🚨 Causes Courantes du 404

### **1. URL Incorrecte**
- ❌ `https://trocabook.vercel.app/users/register` (manque `/api`)
- ❌ `https://trocabook.vercel.app//user/register` (manque `s`)
- ❌ `https://trocabook.vercel.app//users/register/` (slash final)
- ✅ `https://trocabook.vercel.app//users/register` (correct)

### **2. Endpoint Non Implémenté**
- Si vous voyez le 404 dans la réponse d'erreur
- L'endpoint n'existe peut-être pas sur le backend
- Contactez l'équipe backend ou vérifiez la documentation API

### **3. CORS Non Configuré**
- Si vous voyez une erreur CORS dans la console
- Le backend doit avoir CORS activé pour le domaine
- Besoin de configuration backend

### **4. Headers Manquants**
- Si le backend refuse sans Content-Type
- Vérifier que `Content-Type: application/json` est envoyé
- ✅ C'est maintenant fait automatiquement

### **5. Token Expiré (401)**
- Si vous obtenez 401 au lieu de 404
- Le token n'est plus valide
- Besoin de se reconnecter

---

## 📊 Arborescence des Fichiers Modifiés

```
lib/
├── main.dart (⭐ MODIFIÉ - import + appel ApiDiagnostic)
├── core/
│   ├── diagnostic/
│   │   └── api_diagnostic.dart (✨ NOUVEAU - outil de diagnostic)
│   ├── network/
│   │   └── api_client.dart (⭐ MODIFIÉ - logging détaillé)
│   ├── services/
│   │   └── auth_service.dart (⭐ MODIFIÉ - try/catch détaillé)
│   └── config/
│       └── api_endpoints.dart (✅ VÉRIFIÉ - URLs correctes)
```

---

## 🔄 Prochaines Étapes

1. **Relancer l'app** et ouvrir la console du navigateur
2. **Vérifier les logs au démarrage** - voir si les URLs sont correctes
3. **Tenter une action** (login, register, etc.)
4. **Analyser les logs d'erreur** dans la console
5. **Vérifier l'onglet Network** dans les dev tools
6. **Communiquer les détails** pour debug

---

## 💡 Exemple de Output Attendu

**Console au démarrage:**
```
╔════════════════════════════════════════════════════════════╗
║         🔍 API DIAGNOSTICS                                 ║
╚════════════════════════════════════════════════════════════╝

📋 BASE CONFIGURATION:
   Base URL: https://trocabook.vercel.app/

🔐 ENDPOINTS CONFIGURÉS:
   ✅ AUTHENTICATION:
      - Login:           /auth/login
      - Register:        /users/register
      ...
```

**Console lors d'un appel API (ex: register):**
```
🔄 Starting user registration...
📧 Email: test@example.com
📤 Sending registration request to /users/register
📦 Payload: {firstName: John, lastName: Doe, email: test@example.com, ...}

📡 [API REQUEST]
   URL: https://trocabook.vercel.app//users/register
   Method: POST
   Headers: {Content-Type: application/json, Accept: application/json}
   Body: {firstName: John, lastName: Doe, ...}

❌ [API ERROR]
   Status: 404
   Message: Not Found
   URL: https://trocabook.vercel.app//users/register
   Response: {error: "Endpoint not found"}
```

---

## 📞 Support

Si vous voyez toujours le 404 après vérification:

1. Copier les logs complets de la console
2. Vérifier que l'URL complète dans les logs est correcte
3. Tester cette URL dans un navigateur ou Postman
4. Vérifier la configuration du backend
5. Demander au backend team si l'endpoint est activé

---

**✅ Diagnostic System Ready!**
