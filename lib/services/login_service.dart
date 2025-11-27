import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class LoginService {
  // Cargar URL base desde .env
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8005';
  
  // Instancia del servicio de autenticación
  static final AuthService _authService = AuthService();
  
  /// Login - Autentica al usuario y guarda la sesión automáticamente
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
        final data = jsonDecode(response.body);
        
        // ✅ Guardar sesión automáticamente
        if (data['user_id'] != null) {
          await _authService.saveUserSession(
            userId: data['user_id'],
            username: data['username'] ?? username,
            userData: data,
          );
          
          print('✅ Sesión guardada para usuario ${data['id']}');
        }
        
        return {
          'success': true,
          'data': data,
          'message': 'Login exitoso',
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

  /// Logout - Cierra la sesión del usuario
  static Future<void> logout() async {
    await _authService.logout();
    print('✅ Usuario deslogueado');
  }

  /// Verificar estado del servidor
  static Future<bool> checkServerStatus() async {
    try {
      print('🔍 Verificando estado del servidor...');
      print('📡 URL: $baseUrl/plant-analysis/health');
      
      final response = await http.get(
        Uri.parse('$baseUrl/plant-analysis/health'),
      ).timeout(const Duration(seconds: 5));

      print('📥 Status: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Servidor no disponible: $e');
      return false;
    }
  }

  /// Obtener el usuario actual desde AuthService
  static Future<int?> getCurrentUserId() async {
    return await _authService.getUserId();
  }

  /// Verificar si hay una sesión activa
  static Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }
}