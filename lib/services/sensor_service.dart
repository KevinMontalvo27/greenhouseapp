import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SensorService {
  // Cargar URL base desde .env
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8005';

  /// Obtener lecturas de un sensor
  static Future<List<dynamic>> getSensorReadings(
    int sensorId, {
    int? limit,
  }) async {
    try {
      final uri = limit != null
          ? Uri.parse('$baseUrl/sensor-readings/$sensorId?limit=$limit')
          : Uri.parse('$baseUrl/sensor-readings/$sensorId');
      
      print('📡 Obteniendo lecturas del sensor: $sensorId');
      print('📡 URL: $uri');
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        print('✅ ${data.length} lecturas obtenidas');
        return data;
      } else {
        throw Exception('Error al obtener lecturas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo lecturas: $e');
      rethrow;
    }
  }

  /// Obtener última lectura de un sensor
  static Future<Map<String, dynamic>?> getLatestReading(int sensorId) async {
    try {
      final readings = await getSensorReadings(sensorId, limit: 1);
      return readings.isNotEmpty ? readings.first : null;
    } catch (e) {
      print('❌ Error obteniendo última lectura: $e');
      rethrow;
    }
  }

  /// Obtener estadísticas de un sensor
  static Future<Map<String, dynamic>> getSensorStatistics(
    int sensorId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final uri = Uri.parse('$baseUrl/sensor-readings/$sensorId/statistics')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      print('📡 Obteniendo estadísticas del sensor: $sensorId');
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener estadísticas');
      }
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      rethrow;
    }
  }
}