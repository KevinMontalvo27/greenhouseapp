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
        print('✅ ${data.length} chats obtenidos');
        return data;
      } else {
        throw Exception('Error al obtener chats: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo chats: $e');
      rethrow;
    }
  }

  /// Obtener mensajes de un chat
  static Future<List<dynamic>> getChatMessages(int chatId) async {
    try {
      print('📡 Obteniendo mensajes del chat: $chatId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$chatId/messages'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        print('✅ ${data.length} mensajes obtenidos');
        return data;
      } else {
        throw Exception('Error al obtener mensajes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo mensajes: $e');
      rethrow;
    }
  }

  /// Enviar mensaje en un chat
  static Future<Map<String, dynamic>> sendMessage({
    required int chatId,
    required String message,
  }) async {
    try {
      print('💬 Enviando mensaje al chat: $chatId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chats/$chatId/message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'author': 'user',
          'message': message,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📥 Status code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Mensaje enviado');
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Error al enviar mensaje: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error enviando mensaje: $e');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Obtener información de un chat específico
  static Future<Map<String, dynamic>> getChatById(int chatId) async {
    try {
      print('📡 Obteniendo información del chat: $chatId');
      
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
      print('❌ Error obteniendo chat: $e');
      rethrow;
    }
  }
}