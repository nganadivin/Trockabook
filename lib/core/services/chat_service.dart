import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../errors/exceptions.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  /// Get all chats for current user
  Future<List<Map<String, dynamic>>> getChats() async {
    try {
      final response = await _apiClient.get('/chats');
      final List<dynamic> chats = response.data is List ? response.data : [];
      return List<Map<String, dynamic>>.from(
        chats.map((chat) => Map<String, dynamic>.from(chat as Map)),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _getMockChats();
      }
      throw ApiException(e.message ?? 'Failed to fetch chats');
    }
  }

  /// Get a specific chat by ID
  Future<Map<String, dynamic>> getChatById(String chatId) async {
    try {
      final response = await _apiClient.get('/chats/$chatId');
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch chat');
    }
  }

  /// Create a new chat
  Future<Map<String, dynamic>> createChat({
    required String participantId,
  }) async {
    try {
      final response = await _apiClient.post('/chats', {
        'participantId': participantId,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to create chat');
    }
  }

  /// Get messages from a chat
  Future<List<Map<String, dynamic>>> getChatMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        '/chats/$chatId/messages?page=$page&limit=$limit',
      );
      final List<dynamic> messages = response.data is List
          ? response.data
          : response.data['messages'] ?? [];
      return List<Map<String, dynamic>>.from(
        messages.map((message) => Map<String, dynamic>.from(message as Map)),
      );
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to fetch messages');
    }
  }

  /// Send a message to a chat
  Future<Map<String, dynamic>> sendMessage(
    String chatId, {
    required String contenu,
    String? type,
  }) async {
    try {
      final response = await _apiClient.post('/chats/$chatId/messages', {
        'contenu': contenu,
        if (type != null) 'type': type,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Failed to send message');
    }
  }

  // Mock data for testing
  List<Map<String, dynamic>> _getMockChats() {
    return [
      {
        'id': 'chat_1',
        'participantName': 'Sophie Martin',
        'lastMessage': 'Merci pour le livre! Il est en bon état.',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'avatar': 'https://via.placeholder.com/80x80?text=Sophie',
        'unread': 0,
      },
      {
        'id': 'chat_2',
        'participantName': 'Jean Dupont',
        'lastMessage': 'Tu as toujours le manuel de Maths?',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'avatar': 'https://via.placeholder.com/80x80?text=Jean',
        'unread': 1,
      },
      {
        'id': 'chat_3',
        'participantName': 'Marie Leclerc',
        'lastMessage': 'Ok, on se rencontre demain?',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'avatar': 'https://via.placeholder.com/80x80?text=Marie',
        'unread': 0,
      },
      {
        'id': 'chat_4',
        'participantName': 'Luc Bernard',
        'lastMessage': 'Intéressé par ton échange',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'avatar': 'https://via.placeholder.com/80x80?text=Luc',
        'unread': 0,
      },
    ];
  }
}
