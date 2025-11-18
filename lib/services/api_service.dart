import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ CAMBIA ESTA IP POR LA IP DE TU COMPUTADORA
  static const String baseUrl = 'http://192.168.100.5:8005';  // ← CAMBIAR AQUÍ
  
  // Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('🔄 Intentando login con: $username');
      print('📡 URL: $baseUrl/users/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout - Verifica que el backend esté corriendo');
        },
      );

      print('📥 Status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Credenciales inválidas',
        };
      }
    } catch (e) {
      print('❌ Error en login: $e');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Resto del código...
}