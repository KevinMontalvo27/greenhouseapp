import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/sensor_service.dart';

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

  final List<String> _plants = ['Uva', 'Tomate', 'Maíz', 'Papa'];
  String _selectedPlant = 'Uva';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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

    try {
      // Obtiene las últimas 168 lecturas (7 días si se toma 1 lectura por hora)
      final readings = await SensorService.getSensorReadings(
        sensorId,
        limit: 168,
      );

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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _trendingData = _getDefaultTrendingData();
        });
      }
    }
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
    List<dynamic> readings,
  ) {
    if (readings.isEmpty) return _getDefaultTrendingData();

    // Nombres de los días de la semana en español
    final daysOfWeek = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sab', 'Dom'];

    // Agrupa lecturas por día de la semana
    final Map<int, List<Map<String, dynamic>>> readingsByDay = {};

    for (var reading in readings) {
      final readingMap = reading as Map<String, dynamic>;
      final timestamp = DateTime.parse(readingMap['timestamp'] as String);

      // weekday: 1 = Lunes, 7 = Domingo
      final dayIndex = timestamp.weekday - 1;
      readingsByDay.putIfAbsent(dayIndex, () => []);
      readingsByDay[dayIndex]!.add(readingMap);
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
            dayReadings
                .map((r) => (r['temperature'] as num).toDouble())
                .reduce((a, b) => a + b) /
            dayReadings.length;

        final avgHumidity =
            dayReadings
                .map((r) => (r['humidity'] as num).toDouble())
                .reduce((a, b) => a + b) /
            dayReadings.length;

        final avgLight =
            dayReadings
                .map((r) => (r['light'] as num).toDouble())
                .reduce((a, b) => a + b) /
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
                            // Selector de plantas para análisis de salud
                            _sectionTitle('Salud de las plantas'),
                            _buildPlantHealthSection(),
                            const SizedBox(height: 32),
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
            color: Colors.grey.withOpacity(0.2),
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

  /// Construye la sección de salud de plantas
  ///
  /// Muestra un selector dropdown para elegir entre diferentes plantas.
  ///
  /// INTEGRACIÓN CON BACKEND:
  /// Para conectar con datos reales del backend:
  /// 1. Crear un método en SensorService para obtener la lista de plantas
  /// 2. Llamar ese método en _loadPlantData() y actualizar _plants
  /// 3. El formato esperado es: List<String> con nombres de plantas
  Widget _buildPlantHealthSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
        items: _plants
            .map(
              (p) => DropdownMenuItem(
                value: p,
                child: Row(
                  children: [
                    const Icon(Icons.eco, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(p, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _selectedPlant = value!),
      ),
    );
  }
}

// Painters corregidos
class BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final String keyName;
  final Color color;

  BarChartPainter(this.data, this.keyName, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final barWidth = size.width / (data.length * 2);
    final spacing = barWidth * 0.5;

    final values = data.map((e) => (e[keyName] as num).toDouble()).toList();
    final minVal = values.reduce(min);
    final maxVal = values.reduce(max);
    final range = maxVal - minVal;
    final scale = range > 0 ? (size.height * 0.7) / range : 0;

    for (int i = 0; i < data.length; i++) {
      final value = (data[i][keyName] as num).toDouble();
      final normalizedHeight = range > 0 ? (value - minVal) * scale : 0;
      final x = spacing + i * (barWidth + spacing);
      final y = size.height - normalizedHeight - 30;

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
