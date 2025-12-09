import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/api_service.dart';
import '../../models/sensor_reading.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  late ScrollController _scrollController;

  // Estado de carga de datos desde el backend
  bool _isLoading = false;

  // ID del sensor a consultar (ajustar según tu configuración)
  static const int sensorId = 1;

  // Datos de tendencias obtenidos del backend
  // Cada entrada representa un día con temperatura, humedad y luz
  // Inicializados con valores por defecto
  List<Map<String, dynamic>> _trendingData = [];

  // Configuración de plantas para análisis de salud
  final List<String> _plants = ['Uva', 'Tomate', 'Maíz', 'Papa'];
  String _selectedPlant = 'Uva';

  // Datos de salud de plantas (simulados)
  // Mapea cada planta a su historial de salud por día
  late Map<String, List<Map<String, dynamic>>> _plantHealthData;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _generatePlantHealthData();
    // Muestra datos por defecto inmediatamente
    _trendingData = _getDefaultTrendingData();
    // Carga datos reales del historial en segundo plano
    _loadTrendingData();
  }

  /// Obtiene el historial de lecturas del sensor desde el backend
  ///
  /// Procesa las lecturas para agruparlas por día de la semana
  /// y calcular promedios diarios de temperatura, humedad y luz.
  /// Si no hay datos, mantiene los valores por defecto.
  /// Verifica que el widget esté montado antes de llamar setState.
  Future<void> _loadTrendingData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    // Obtiene las últimas 168 lecturas (7 días si se toma 1 lectura por hora)
    final readings = await ApiService.getSensorReadings(sensorId, limit: 168);

    // Verifica que el widget aún esté montado antes de actualizar el estado
    if (!mounted) return;

    setState(() {
      _isLoading = false;

      if (readings.isEmpty) {
        // Si no hay datos del backend, mantiene valores por defecto
        _trendingData = _getDefaultTrendingData();
      } else {
        // Procesa las lecturas para generar datos de tendencias
        _trendingData = _processReadingsIntoTrends(readings);
      }
    });
  }

  /// Genera datos de tendencias por defecto cuando no hay conexión
  ///
  /// Retorna:
  ///   - Lista de 7 días con valores simulados para temperatura, humedad y luz
  List<Map<String, dynamic>> _getDefaultTrendingData() {
    return [
      {'day': 'Lun', 'temperature': 22.5, 'humidity': 60.0, 'light': 800.0},
      {'day': 'Mar', 'temperature': 23.1, 'humidity': 62.0, 'light': 820.0},
      {'day': 'Mié', 'temperature': 24.5, 'humidity': 65.0, 'light': 850.0},
      {'day': 'Jue', 'temperature': 23.8, 'humidity': 63.0, 'light': 830.0},
      {'day': 'Vie', 'temperature': 25.2, 'humidity': 67.0, 'light': 870.0},
      {'day': 'Sab', 'temperature': 24.0, 'humidity': 64.0, 'light': 840.0},
      {'day': 'Dom', 'temperature': 23.5, 'humidity': 61.0, 'light': 810.0},
    ];
  }

  /// Procesa las lecturas del sensor para crear datos de tendencias por día
  ///
  /// Agrupa las lecturas por día de la semana y calcula el promedio
  /// de temperatura, humedad y luz para cada día.
  ///
  /// Parámetros:
  ///   - readings: Lista de lecturas del sensor ordenadas por fecha
  ///
  /// Retorna:
  ///   - Lista de mapas con promedios diarios de los últimos 7 días
  List<Map<String, dynamic>> _processReadingsIntoTrends(
    List<SensorReading> readings,
  ) {
    if (readings.isEmpty) return _getDefaultTrendingData();

    // Nombres de los días de la semana en español
    final daysOfWeek = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sab', 'Dom'];

    // Agrupa lecturas por día de la semana
    final Map<int, List<SensorReading>> readingsByDay = {};

    for (var reading in readings) {
      // weekday: 1 = Lunes, 7 = Domingo
      final dayIndex = reading.timestamp.weekday - 1;
      readingsByDay.putIfAbsent(dayIndex, () => []);
      readingsByDay[dayIndex]!.add(reading);
    }

    // Calcula promedios para cada día
    final List<Map<String, dynamic>> trends = [];

    for (int i = 0; i < 7; i++) {
      final dayReadings = readingsByDay[i] ?? [];

      if (dayReadings.isEmpty) {
        // Si no hay datos para este día, usa valores por defecto
        trends.add({
          'day': daysOfWeek[i],
          'temperature': 24.0,
          'humidity': 65.0,
          'light': 850.0,
        });
      } else {
        // Calcula el promedio de las lecturas del día
        final avgTemp =
            dayReadings.map((r) => r.temperature).reduce((a, b) => a + b) /
            dayReadings.length;

        final avgHumidity =
            dayReadings.map((r) => r.humidity).reduce((a, b) => a + b) /
            dayReadings.length;

        final avgLight =
            dayReadings.map((r) => r.light).reduce((a, b) => a + b) /
            dayReadings.length;

        trends.add({
          'day': daysOfWeek[i],
          'temperature': avgTemp,
          'humidity': avgHumidity,
          'light': avgLight,
        });
      }
    }

    return trends;
  }

  /// Genera datos simulados de salud de plantas por día
  ///
  /// Crea un historial de salud (porcentaje) para cada planta
  /// durante los 7 días de la semana con valores aleatorios.
  void _generatePlantHealthData() {
    final random = Random();
    _plantHealthData = {
      for (var plant in _plants)
        plant: List.generate(
          7,
          (index) => {
            'day': ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sab', 'Dom'][index],
            'health': 70.0 + random.nextInt(30) + random.nextDouble(),
          },
        ),
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.grey.shade50],
            stops: const [0.0, 0.35],
          ),
        ),
        child: Stack(
          children: [
            // Capa 1: Encabezado fijo con título
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tendencias semanales',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'Analiza el comportamiento de tus sensores',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(width: 8),
                        // Indicador visual mientras se cargan los datos
                        if (_isLoading)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Capa 2: Contenido desplazable que tapa la capa 1
            RefreshIndicator(
              onRefresh: _loadTrendingData,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gráfica de barras: Temperatura promedio por día
                            _sectionTitle('Temperatura (°C)'),
                            _buildBarChart(
                              _trendingData,
                              'temperature',
                              Colors.orange,
                            ),
                            const SizedBox(height: 32),
                            // Gráfica de barras: Humedad promedio por día
                            _sectionTitle('Humedad (%)'),
                            _buildBarChart(
                              _trendingData,
                              'humidity',
                              Colors.blue,
                            ),
                            const SizedBox(height: 32),
                            // Gráfica de barras: Luz promedio por día
                            _sectionTitle('Luz (lux)'),
                            _buildBarChart(
                              _trendingData,
                              'light',
                              Colors.amber,
                            ),
                            const SizedBox(height: 32),
                            // Gráfica de líneas: Comparación temperatura vs humedad
                            _sectionTitle('Tendencia del clima'),
                            _buildClimateLineChart(_trendingData),
                            const SizedBox(height: 32),
                            // Selector de plantas y gráfica de salud (simulado)
                            _sectionTitle('Salud de las plantas'),
                            _buildPlantHealthSection(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para títulos de sección
  ///
  /// Retorna un Text con estilo consistente para todos los títulos
  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
  );

  /// Construye una gráfica de barras verticales
  ///
  /// Muestra los valores de un parámetro (temperatura, humedad o luz)
  /// para cada día de la semana usando barras verticales coloreadas.
  ///
  /// Parámetros:
  ///   - data: Lista de mapas con datos por día
  ///   - key: Nombre del campo a graficar (temperature, humidity, light)
  ///   - color: Color de las barras
  Widget _buildBarChart(
    List<Map<String, dynamic>> data,
    String key,
    Color color,
  ) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: CustomPaint(painter: BarChartPainter(data, key, color)),
    );
  }

  /// Construye una gráfica de líneas para comparar temperatura y humedad
  ///
  /// Dibuja dos líneas superpuestas: una roja para temperatura y una azul
  /// para humedad, permitiendo ver la correlación entre ambas variables.
  ///
  /// Parámetros:
  ///   - data: Lista de mapas con datos de temperatura y humedad por día
  Widget _buildClimateLineChart(List<Map<String, dynamic>> data) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: CustomPaint(painter: ClimateLineChartPainter(data)),
    );
  }

  /// Construye la sección de salud de plantas
  ///
  /// Muestra un selector dropdown para elegir entre diferentes plantas
  /// y una gráfica de líneas con el índice de salud de la planta seleccionada
  /// durante los últimos 7 días.
  ///
  /// NOTA: Esta sección usa datos simulados, no del backend
  Widget _buildPlantHealthSection() {
    final plantData = _plantHealthData[_selectedPlant]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown para seleccionar tipo de planta
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButton<String>(
            value: _selectedPlant,
            isExpanded: true,
            underline: const SizedBox(),
            items: _plants
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (value) => setState(() => _selectedPlant = value!),
          ),
        ),
        const SizedBox(height: 16),
        // Gráfica de salud de la planta seleccionada
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: CustomPaint(painter: PlantHealthChartPainter(plantData)),
        ),
      ],
    );
  }
}

// CustomPainters para renderizar las gráficas

/// Painter para gráficas de barras verticales
///
/// Dibuja barras verticales para visualizar datos numéricos por día.
/// Las barras se normalizan automáticamente según el rango de valores
/// para aprovechar el espacio vertical disponible.
///
/// Características:
/// - Calcula automáticamente el ancho de las barras según el espacio disponible
/// - Normaliza las alturas en base al valor mínimo y máximo
/// - Dibuja etiquetas de días debajo de cada barra
/// - Usa esquinas redondeadas para un aspecto moderno
class BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final String keyName;
  final Color color;

  BarChartPainter(this.data, this.keyName, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Configuración del pincel para las barras
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Configuración para pintar texto (etiquetas de días)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Cálculo del ancho de cada barra y espaciado
    final barWidth = size.width / (data.length * 2);
    final spacing = barWidth * 0.5;

    // Extrae valores numéricos del campo especificado
    final values = data.map((e) => (e[keyName] as num).toDouble()).toList();
    final minVal = values.reduce(min);
    final maxVal = values.reduce(max);
    final range = maxVal - minVal;

    // Factor de escala para normalizar las alturas de las barras
    // Usa 70% del alto disponible para dejar espacio para las etiquetas
    final scale = range > 0 ? (size.height * 0.7) / range : 0;

    // Dibuja cada barra y su etiqueta
    for (int i = 0; i < data.length; i++) {
      final value = (data[i][keyName] as num).toDouble();

      // Normaliza la altura de la barra basándose en el rango de valores
      final normalizedHeight = range > 0 ? (value - minVal) * scale : 0;
      final x = spacing + i * (barWidth + spacing);
      final y = size.height - normalizedHeight - 30;

      // Dibuja la barra con esquinas redondeadas
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x.toDouble(),
            y.toDouble(),
            barWidth.toDouble(),
            normalizedHeight.toDouble(),
          ),
          const Radius.circular(6),
        ),
        paint,
      );

      // Dibuja la etiqueta del día debajo de la barra
      textPainter.text = TextSpan(
        text: data[i]['day'],
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, size.height - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter para gráfica de líneas dobles (temperatura y humedad)
///
/// Dibuja dos líneas superpuestas para comparar la evolución de
/// temperatura (línea roja) y humedad (línea azul) a lo largo de la semana.
///
/// Características:
/// - Normaliza cada variable independientemente para mejor visualización
/// - Maneja casos donde no hay variación en los datos
/// - Usa colores diferenciados para distinguir las variables
class ClimateLineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  ClimateLineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    // Pincel para línea de temperatura (rojo)
    final tempPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Pincel para línea de humedad (azul)
    final humPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Extrae valores de temperatura y humedad
    final tempValues = data
        .map((e) => (e['temperature'] as num).toDouble())
        .toList();
    final humValues = data
        .map((e) => (e['humidity'] as num).toDouble())
        .toList();

    // Calcula rangos para normalización independiente
    final tMin = tempValues.reduce(min);
    final tMax = tempValues.reduce(max);
    final hMin = humValues.reduce(min);
    final hMax = humValues.reduce(max);

    final tRange = tMax - tMin;
    final hRange = hMax - hMin;

    // Espaciado horizontal entre puntos
    final spacing = size.width / (data.length - 1);
    final tempPath = Path();
    final humPath = Path();

    // Construye los paths para ambas líneas
    for (int i = 0; i < data.length; i++) {
      final t = (data[i]['temperature'] as num).toDouble();
      final h = (data[i]['humidity'] as num).toDouble();
      final x = i * spacing;

      // Normaliza posiciones Y (invierte porque el eje Y crece hacia abajo)
      final yT = tRange > 0
          ? size.height - ((t - tMin) / tRange) * size.height * 0.8
          : size.height * 0.5;
      final yH = hRange > 0
          ? size.height - ((h - hMin) / hRange) * size.height * 0.8
          : size.height * 0.5;

      if (i == 0) {
        tempPath.moveTo(x, yT);
        humPath.moveTo(x, yH);
      } else {
        tempPath.lineTo(x, yT);
        humPath.lineTo(x, yH);
      }
    }

    // Dibuja ambas líneas
    canvas.drawPath(tempPath, tempPaint);
    canvas.drawPath(humPath, humPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter para gráfica de salud de plantas
///
/// Dibuja una línea simple que muestra la evolución del índice de salud
/// de la planta seleccionada durante la última semana.
///
/// NOTA: Esta gráfica usa datos simulados, no datos reales del backend
class PlantHealthChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  PlantHealthChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    // Pincel para la línea de salud (verde)
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final spacing = size.width / (data.length - 1);

    // Extrae valores de salud y calcula rango
    final healthValues = data
        .map((e) => (e['health'] as num).toDouble())
        .toList();
    final minVal = healthValues.reduce(min);
    final maxVal = healthValues.reduce(max);
    final range = maxVal - minVal;

    // Construye el path de la línea
    for (int i = 0; i < data.length; i++) {
      final h = (data[i]['health'] as num).toDouble();
      final x = i * spacing;

      // Normaliza la posición Y
      final y = range > 0
          ? size.height - ((h - minVal) / range) * size.height * 0.8
          : size.height * 0.5;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
