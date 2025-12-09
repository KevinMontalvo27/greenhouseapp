import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_reading.dart';

class ApiService {
  // Configuración de la URL base del servidor FastAPI
  // IMPORTANTE: Cambia esta IP por la IP de tu computadora donde corre el backend
  static const String baseUrl = 'http://192.168.100.5:8005';

  // Timeout para todas las peticiones HTTP
  static const Duration requestTimeout = Duration(seconds: 10);

  // Login de usuario
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(
            requestTimeout,
            onTimeout: () {
              throw Exception(
                'Timeout - Verifica que el backend esté corriendo',
              );
            },
          );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Credenciales inválidas'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Obtiene la lectura más reciente de un sensor específico
  ///
  /// Parámetros:
  ///   - sensorId: ID del sensor del cual obtener la lectura
  ///
  /// Retorna:
  ///   - SensorReading con los datos más recientes
  ///   - Si hay error de conexión, retorna una lectura por defecto
  ///
  /// Endpoint consumido: GET /sensor/{sensor_id}?limit=1
  static Future<SensorReading> getLatestReading(int sensorId) async {
    try {
      // Construye la URL con el parámetro limit=1 para obtener solo el último registro
      final url = Uri.parse('$baseUrl/sensor/$sensorId?limit=1');

      final response = await http
          .get(url)
          .timeout(
            requestTimeout,
            onTimeout: () {
              throw Exception('Timeout al conectar con el servidor');
            },
          );

      if (response.statusCode == 200) {
        // El backend devuelve una lista, tomamos el primer elemento
        final List<dynamic> jsonList = jsonDecode(response.body);

        if (jsonList.isNotEmpty) {
          return SensorReading.fromJson(jsonList[0]);
        } else {
          // Si la lista está vacía, retorna valores por defecto
          return SensorReading.defaultReading();
        }
      } else {
        // Si el servidor responde con error, usa valores por defecto
        return SensorReading.defaultReading();
      }
    } catch (e) {
      // En caso de cualquier error (red, parseo, etc), usa valores por defecto
      print('Error al obtener lectura del sensor: $e');
      return SensorReading.defaultReading();
    }
  }

  /// Obtiene el historial de lecturas de un sensor
  ///
  /// Parámetros:
  ///   - sensorId: ID del sensor del cual obtener el historial
  ///   - limit: Número máximo de lecturas a obtener (por defecto 1000)
  ///   - skip: Número de registros a saltar (para paginación, por defecto 0)
  ///
  /// Retorna:
  ///   - Lista de SensorReading con el historial
  ///   - Si hay error, retorna lista vacía
  ///
  /// Endpoint consumido: GET /sensor/{sensor_id}?skip={skip}&limit={limit}
  static Future<List<SensorReading>> getSensorReadings(
    int sensorId, {
    int skip = 0,
    int limit = 1000,
  }) async {
    try {
      // Construye la URL con los parámetros de paginación
      final url = Uri.parse(
        '$baseUrl/sensor/$sensorId?skip=$skip&limit=$limit',
      );

      final response = await http
          .get(url)
          .timeout(
            requestTimeout,
            onTimeout: () {
              throw Exception('Timeout al conectar con el servidor');
            },
          );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        // Convierte cada elemento del JSON a un objeto SensorReading
        return jsonList.map((json) => SensorReading.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error al obtener historial del sensor: $e');
      return [];
    }
  }
}
