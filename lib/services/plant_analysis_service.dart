import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class PlantAnalysisService {
  // Cargar URL base desde .env
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8005';
  
  // Instancia del servicio de autenticación
  static final AuthService _authService = AuthService();

  /// Analizar imagen de planta
  /// Si no se proporciona userId, se obtiene automáticamente de la sesión
  static Future<Map<String, dynamic>> analyzePlantImage({
    required String imagePath,
    int? userId,
    int? greenhouseId,
  }) async {
    try {
      // Si no se proporciona userId, obtenerlo de la sesión
      final finalUserId = userId ?? await _authService.getUserId();
      
      if (finalUserId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      print('Analizando imagen de planta...');
      print('Usuario: $finalUserId, Invernadero: $greenhouseId');
      
      // Construir URL con parámetros
      final uri = Uri.parse('$baseUrl/plant-analysis/classify').replace(
        queryParameters: {
          'user_id': finalUserId.toString(),
          if (greenhouseId != null) 'greenhouse_id': greenhouseId.toString(),
        },
      );
      
      print('URL: $uri');
      
      // Crear request multipart
      var request = http.MultipartRequest('POST', uri);
      
      // Agregar imagen con contentType explícito
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imagePath,
        filename: 'plant_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      
      print('Detalles del archivo:');
      print('  - Path: $imagePath');
      print('  - Filename: ${multipartFile.filename}');
      print('  - ContentType: ${multipartFile.contentType}');
      print('  - Length: ${multipartFile.length} bytes');
      
      request.files.add(multipartFile);
      
      print('Headers del request:');
      request.headers.forEach((key, value) {
        print('  - $key: $value');
      });
      
      print('Files en el request:');
      for (var file in request.files) {
        print('  - Field: ${file.field}');
        print('  - Filename: ${file.filename}');
        print('  - ContentType: ${file.contentType}');
        print('  - Length: ${file.length}');
      }
      
      // Enviar request
      print('Enviando imagen...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout - El análisis tomó demasiado tiempo');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Análisis completado');
        
        // Mostrar información del resultado
        if (data['alert_activated'] == true) {
          print('Alerta activada - Enfermedad detectada');
          print('Chat ID: ${data['chat_id']}');
        } else {
          print('Planta saludable');
        }
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Error al analizar la imagen',
          'error': response.body,
        };
      }
    } catch (e) {
      print('Error analizando imagen: $e');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Verificar estado del servicio de análisis
  static Future<bool> checkServiceStatus() async {
    try {
      print('Verificando servicio de análisis...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/plant-analysis/health'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Servicio no disponible: $e');
      return false;
    }
  }
}