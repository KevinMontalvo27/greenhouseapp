import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class GreenhouseService {
  // Cargar URL base desde .env
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8005';
  
  // Instancia del servicio de autenticación
  static final AuthService _authService = AuthService();

  /// Obtener invernaderos del usuario
  /// Si no se proporciona userId, se obtiene automáticamente de la sesión
  static Future<List<dynamic>> getGreenhouses({int? userId}) async {
    try {
      // Si no se proporciona userId, obtenerlo de la sesión
      final finalUserId = userId ?? await _authService.getUserId();
      
      if (finalUserId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      print('Obteniendo invernaderos para usuario: $finalUserId');
      print('URL: $baseUrl/greenhouses/user/$finalUserId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/greenhouses/user/$finalUserId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        print('${data.length} invernaderos obtenidos');
        return data;
      } else {
        throw Exception('Error al obtener invernaderos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error obteniendo invernaderos: $e');
      rethrow;
    }
  }

  /// Obtener un invernadero específico por ID
  static Future<Map<String, dynamic>> getGreenhouseById(int greenhouseId) async {
    try {
      print('📡 Obteniendo invernadero: $greenhouseId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/greenhouses/$greenhouseId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener invernadero');
      }
    } catch (e) {
      print('❌ Error obteniendo invernadero: $e');
      rethrow;
    }
  }

  /// Obtener sensores de un invernadero
  static Future<List<dynamic>> getSensors(int greenhouseId) async {
    try {
      print('📡 Obteniendo sensores del invernadero: $greenhouseId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/sensors/greenhouse/$greenhouseId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        print('✅ ${data.length} sensores obtenidos');
        return data;
      } else {
        throw Exception('Error al obtener sensores');
      }
    } catch (e) {
      print('❌ Error obteniendo sensores: $e');
      rethrow;
    }
  }
}