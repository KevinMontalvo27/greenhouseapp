/// Modelo que representa una lectura de sensor del backend
///
/// Este modelo mapea los datos que vienen del endpoint FastAPI:
/// GET /sensor/{sensor_id}
///
/// Campos principales:
/// - temperature: Temperatura en grados Celsius (0-50 °C)
/// - humidity: Humedad relativa en porcentaje (0-100 %)
/// - light: Intensidad lumínica en lux
/// - smoke: Detección de humo (true/false)
/// - timestamp: Fecha y hora de la lectura
class SensorReading {
  final int id;
  final double temperature;
  final double humidity;
  final double light;
  final bool smoke;
  final DateTime timestamp;

  SensorReading({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.light,
    required this.smoke,
    required this.timestamp,
  });

  /// Factory constructor que parsea el JSON del backend
  ///
  /// Maneja conversiones automáticas de int a double para evitar errores
  /// de tipo cuando el backend devuelve números enteros
  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      id: json['id'] as int,
      // Convierte int a double si es necesario para temperatura
      temperature: (json['temperature'] as num).toDouble(),
      // Convierte int a double si es necesario para humedad
      humidity: (json['humidity'] as num).toDouble(),
      // Convierte int a double si es necesario para luz
      light: (json['light'] as num).toDouble(),
      smoke: json['smoke'] as bool,
      // Parsea el string ISO 8601 a DateTime
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convierte el objeto a JSON (útil para debugging)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'temperature': temperature,
      'humidity': humidity,
      'light': light,
      'smoke': smoke,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Crea una lectura por defecto cuando no hay conexión
  ///
  /// Valores simulados para evitar pantallas en blanco cuando
  /// el backend no está disponible
  factory SensorReading.defaultReading() {
    return SensorReading(
      id: 0,
      temperature: 24.5,
      humidity: 65.0,
      light: 850.0,
      smoke: false,
      timestamp: DateTime.now(),
    );
  }
}
