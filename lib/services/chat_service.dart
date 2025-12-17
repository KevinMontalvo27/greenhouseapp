import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class ChatService {
  // Cargar URL base desde .env
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8005';
  
  // Instancia del servicio de autenticación
  static final AuthService _authService = AuthService();

  /// Obtener chats del usuario
  /// Si no se proporciona userId, se obtiene automáticamente de la sesión
  static Future<List<dynamic>> getUserChats({int? userId}) async {
    try {
      // Si no se proporciona userId, obtenerlo de la sesión
      final finalUserId = userId ?? await _authService.getUserId();
      
      if (finalUserId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      print('📡 Obteniendo chats del usuario: $finalUserId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/chats/user/$finalUserId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        print('${data.length} chats obtenidos');
        return data;
      } else {
        throw Exception('Error al obtener chats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error obteniendo chats: $e');
      rethrow;
    }
  }

static Future<List<dynamic>> getChatMessages(int chatId) async {
    try {
      // Obtener user_id de la sesión
      final userId = await _authService.getUserId();
      
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      print('Obteniendo mensajes del chat: $chatId');
      print('User ID: $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$chatId/messages?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        print('${data.length} mensajes obtenidos');
        return data;
      } else {
        print('Error body: ${response.body}');
        throw Exception('Error al obtener mensajes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error obteniendo mensajes: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> sendMessage({
    required int chatId,
    required String message,
  }) async {
    try {
      // Obtener user_id de la sesión
      final userId = await _authService.getUserId();
      
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      print('Enviando mensaje al chat: $chatId');
      print('User ID: $userId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chats/$chatId/messages?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
        }),
      ).timeout(const Duration(seconds: 30)); // Timeout aumentado para Gemini

      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Mensaje enviado y respuesta de Gemini recibida');
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('Error body: ${response.body}');
        return {
          'success': false,
          'message': 'Error al enviar mensaje: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error enviando mensaje: $e');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Obtener información de un chat específico
  static Future<Map<String, dynamic>> getChatById(int chatId) async {
    try {
      print('Obteniendo información del chat: $chatId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$chatId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener chat');
      }
    } catch (e) {
      print('Error obteniendo chat: $e');
      rethrow;
    }
  }
}