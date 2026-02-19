# 🧪 Guide de Test des Endpoints - Trocabook API

## 📌 Comment Utiliser Ce Guide

1. **Ouvrir Postman** (ou tout autre client HTTP)
2. **Tester chaque endpoint** de cette liste
3. **Rapporter les résultats** (200, 404, 500, etc.)

---

## ✅ ENDPOINTS À TESTER

### 🔐 AUTHENTICATION

#### 1. **REGISTER (Enregistrement)**
```http
POST https://trocabook.vercel.app//users/register

Headers:
  Content-Type: application/json
  Accept: application/json

Body:
{
  "firstName": "Test",
  "lastName": "User",
  "email": "test@example.com",
  "password": "password123",
  "telephone": "0600000000",
  "ville": "Douala",
  "latitude": 3.8480,
  "longitude": 11.5021,
  "profileImage": "",
  "numberOfChildren": 0,
  "age": 25,
  "roles": ["USER"],
  "cgu_valide": true
}
```

**Autres chemins possibles à essayer:**
```
POST /auth/register
POST /api/auth/register
POST /signup
POST /api/signup
POST /auth/signup
```

---

#### 2. **LOGIN (Connexion)**
```http
POST https://trocabook.vercel.app//auth/login

Headers:
  Content-Type: application/json
  Accept: application/json

Body:
{
  "email": "test@example.com",
  "password": "password123"
}
```

**Autres chemins possibles:**
```
POST /users/login
POST /api/users/login
POST /authenticate
POST /api/authenticate
```

---

#### 3. **VERIFY OTP**
```http
POST https://trocabook.vercel.app//auth/verify-otp

Headers:
  Content-Type: application/json
  Accept: application/json

Body:
{
  "email": "test@example.com",
  "otp": "123456"
}
```

---

#### 4. **FORGOT PASSWORD**
```http
POST https://trocabook.vercel.app//auth/forgot-password

Headers:
  Content-Type: application/json
  Accept: application/json

Body:
{
  "email": "test@example.com"
}
```

---

#### 5. **LOGOUT**
```http
POST https://trocabook.vercel.app//auth/logout

Headers:
  Content-Type: application/json
  Authorization: Bearer <YOUR_TOKEN>

Body:
{}
```

---

### 👤 USERS

#### 6. **GET PROFILE (Moi)**
```http
GET https://trocabook.vercel.app//users/me

Headers:
  Authorization: Bearer <YOUR_TOKEN>
  Accept: application/json
```

---

#### 7. **UPDATE PROFILE**
```http
PATCH https://trocabook.vercel.app//users/me

Headers:
  Content-Type: application/json
  Authorization: Bearer <YOUR_TOKEN>

Body:
{
  "firstName": "NewName",
  "lastName": "NewLastName",
  "telephone": "0600000001",
  "ville": "Yaoundé",
  "latitude": 3.8480,
  "longitude": 11.5021,
  "age": 26,
  "profileImage": "https://..."
}
```

---

#### 8. **GET USER BY ID**
```http
GET https://trocabook.vercel.app//users/{id}

Headers:
  Authorization: Bearer <YOUR_TOKEN>
  Accept: application/json

Example:
GET https://trocabook.vercel.app//users/123
```

---

### 📚 BOOKS (LIVRES)

#### 9. **LIST ALL BOOKS**
```http
GET https://trocabook.vercel.app//livres

Headers:
  Accept: application/json
  Authorization: Bearer <YOUR_TOKEN> (optionnel)
```

---

#### 10. **GET MY BOOKS**
```http
GET https://trocabook.vercel.app//livres/user/me

Headers:
  Authorization: Bearer <YOUR_TOKEN>
  Accept: application/json
```

**Autres chemins possibles:**
```
GET /livres/user/{userId}
GET /livres/my-books
GET /my-books
```

---

#### 11. **SEARCH BOOKS**
```http
GET https://trocabook.vercel.app//livres/search?q=math

Headers:
  Accept: application/json
  Authorization: Bearer <YOUR_TOKEN> (optionnel)
```

---

#### 12. **CREATE BOOK**
```http
POST https://trocabook.vercel.app//livres

Headers:
  Content-Type: application/json
  Authorization: Bearer <YOUR_TOKEN>

Body:
{
  "titre": "Mathématiques",
  "auteur": "Test Author",
  "description": "Un livre de math",
  "niveau": "Terminale",
  "matiere": "Mathématiques",
  "etat": "Excellent",
  "images": ["https://..."],
  "prix": 5000
}
```

---

#### 13. **GET BOOK DETAILS**
```http
GET https://trocabook.vercel.app//livres/{id}

Headers:
  Accept: application/json
  Authorization: Bearer <YOUR_TOKEN> (optionnel)

Example:
GET https://trocabook.vercel.app//livres/123
```

---

#### 14. **UPDATE BOOK**
```http
PATCH https://trocabook.vercel.app//livres/{id}

Headers:
  Content-Type: application/json
  Authorization: Bearer <YOUR_TOKEN>

Body:
{
  "titre": "Nouveau Titre",
  "etat": "Bon",
  "prix": 6000
}
```

---

#### 15. **DELETE BOOK**
```http
DELETE https://trocabook.vercel.app//livres/{id}

Headers:
  Authorization: Bearer <YOUR_TOKEN>
```

---

### 💬 CHATS

#### 16. **LIST CHATS**
```http
GET https://trocabook.vercel.app//chats

Headers:
  Authorization: Bearer <YOUR_TOKEN>
  Accept: application/json
```

---

#### 17. **GET CHAT DETAILS**
```http
GET https://trocabook.vercel.app//chats/{id}

Headers:
  Authorization: Bearer <YOUR_TOKEN>
  Accept: application/json
```

---

#### 18. **GET MESSAGES**
```http
GET https://trocabook.vercel.app//chats/{id}/messages

Headers:
  Authorization: Bearer <YOUR_TOKEN>
  Accept: application/json

Query Parameters (optionnel):
  ?page=1&limit=20
```

---

#### 19. **SEND MESSAGE**
```http
POST https://trocabook.vercel.app//chats/{id}/messages

Headers:
  Content-Type: application/json
  Authorization: Bearer <YOUR_TOKEN>

Body:
{
  "content": "Bonjour!",
  "type": "text"
}
```

---

#### 20. **CREATE CHAT**
```http
POST https://trocabook.vercel.app//chats

Headers:
  Content-Type: application/json
  Authorization: Bearer <YOUR_TOKEN>

Body:
{
  "participantId": "user_id",
  "initialMessage": "Bonjour, intéressé par ton livre?"
}
```

---

### 📦 TRANSACTIONS (EXCHANGES)

#### 21. **LIST TRANSACTIONS**
```http
GET https://trocabook.vercel.app//transactions

Headers:
  Authorization: Bearer <YOUR_TOKEN>
  Accept: application/json
```

---

#### 22. **CREATE TRANSACTION**
```http
POST https://trocabook.vercel.app//transactions

Headers:
  Content-Type: application/json
  Authorization: Bearer <YOUR_TOKEN>

Body:
{
  "offeredBookId": "book_id_1",
  "requestedBookId": "book_id_2",
  "proposedBy": "user_id"
}
```

---

#### 23. **GET TRANSACTION DETAILS**
```http
GET https://trocabook.vercel.app//transactions/{id}

Headers:
  Authorization: Bearer <YOUR_TOKEN>
  Accept: application/json
```

---

#### 24. **NEGOTIATE TRANSACTION**
```http
PATCH https://trocabook.vercel.app//transactions/{id}/negotiate

Headers:
  Content-Type: application/json
  Authorization: Bearer <YOUR_TOKEN>

Body:
{
  "status": "counter_offered",
  "counterOffer": "Je peux ajouter 2000 FCFA"
}
```

---

#### 25. **ACCEPT TRANSACTION**
```http
PATCH https://trocabook.vercel.app//transactions/{id}/accept

Headers:
  Content-Type: application/json
  Authorization: Bearer <YOUR_TOKEN>

Body:
{
  "status": "accepted"
}
```

---

## 🎯 Format de Test Recommandé

Pour chaque endpoint, tester:

```
✅ Endpoint: [URL]
✅ Méthode: [GET/POST/PATCH/DELETE]
✅ Status attendu: [200/201/400/404/etc]

Résultats:
  Status reçu: [❌/✅]
  Message d'erreur: [si applicable]
  Corps de la réponse: [JSON]
```

---

## 📋 Template de Rapport

```markdown
# Résultats des Tests

## Endpoints Fonctionnant (✅)
- [ ] POST /auth/login
- [ ] GET /users/me
- [ ] GET /livres
- [ ] etc...

## Endpoints Cassés (❌)
- [ ] POST /users/register - Error: 404 Not Found
- [ ] POST /chats - Error: 401 Unauthorized
- [ ] etc...

## Endpoints Non Trouvés (⏳)
- [ ] POST /auth/refresh
- [ ] POST /evaluations
- [ ] etc...

## Notes
- Base URL: https://trocabook.vercel.app/
- CORS: [Fonctionne/Erreur]
- Token: [Fonctionne/Erreur]
```

---

## 🔐 Obtenir un Token de Test

### **Étape 1: Se Connecter (Login)**
```bash
curl -X POST https://trocabook.vercel.app//auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### **Étape 2: Récupérer le Token**
La réponse devrait contenir:
```json
{
  "idToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "...",
  "userId": "123"
}
```

### **Étape 3: Utiliser le Token**
Ajouter à toutes les requêtes authentifiées:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

---

## 💡 Conseils de Dépannage

### **Erreur 404**
- ✅ L'endpoint n'existe pas
- ✅ Vérifier l'URL
- ✅ Vérifier qu'il n'y a pas de slash final
- ✅ Vérifier la capitalization

### **Erreur 401**
- ✅ Token manquant ou expiré
- ✅ Vérifier l'en-tête Authorization
- ✅ Vérifier le format: `Bearer <token>`

### **Erreur 500**
- ✅ Erreur serveur
- ✅ Contacter l'équipe backend

### **Erreur CORS**
- ✅ Vérifier que le backend a CORS activé
- ✅ Vérifier les origins autorisées

---

## 📞 Support

Si un endpoint ne fonctionne pas:
1. **Copier l'URL exacte testée**
2. **Noter le status code reçu**
3. **Noter le message d'erreur**
4. **Tester avec Postman/curl**
5. **Communiquer ces infos au backend**

---

**Good luck with testing! 🚀**
