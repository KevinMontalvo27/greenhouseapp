import 'package:flutter/material.dart';
import 'dart:math';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  late ScrollController _scrollController;
  double _scrollOpacity = 1.0;

  final List<Map<String, dynamic>> _trendingData = [
    {'day': 'Lun', 'temperature': 22.5, 'humidity': 60, 'light': 800},
    {'day': 'Mar', 'temperature': 23.1, 'humidity': 62, 'light': 820},
    {'day': 'Mié', 'temperature': 24.5, 'humidity': 65, 'light': 850},
    {'day': 'Jue', 'temperature': 23.8, 'humidity': 63, 'light': 830},
    {'day': 'Vie', 'temperature': 25.2, 'humidity': 67, 'light': 870},
    {'day': 'Sab', 'temperature': 24.0, 'humidity': 64, 'light': 840},
    {'day': 'Dom', 'temperature': 23.5, 'humidity': 61, 'light': 810},
  ];

  final List<String> _plants = ['Uva', 'Tomate', 'Maíz', 'Papa'];
  String _selectedPlant = 'Uva';
  late Map<String, List<Map<String, dynamic>>> _plantHealthData;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _generatePlantHealthData();
  }

  void _onScroll() {
    double newOpacity = 1.0 - (_scrollController.offset / 150).clamp(0.0, 1.0);
    if (newOpacity != _scrollOpacity) {
      setState(() => _scrollOpacity = newOpacity);
    }
  }

  void _generatePlantHealthData() {
    final random = Random();
    _plantHealthData = {
      for (var plant in _plants)
        plant: List.generate(
          7,
          (index) => {
            'day': ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sab', 'Dom'][index],
            'health': 70 + random.nextInt(30) + random.nextDouble(),
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
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              expandedHeight: 100,
              title: AnimatedOpacity(
                opacity: _scrollOpacity,
                duration: const Duration(milliseconds: 200),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tendencias de las últimas semanas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Analiza el comportamiento de tus sensores',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Temperatura (°C)'),
                    _buildBarChart(_trendingData, 'temperature', Colors.orange),
                    const SizedBox(height: 32),
                    _sectionTitle('Humedad (%)'),
                    _buildBarChart(_trendingData, 'humidity', Colors.blue),
                    const SizedBox(height: 32),
                    _sectionTitle('Luz (lux)'),
                    _buildBarChart(_trendingData, 'light', Colors.amber),
                    const SizedBox(height: 32),
                    _sectionTitle('Tendencia del clima'),
                    _buildClimateLineChart(_trendingData),
                    const SizedBox(height: 32),
                    _sectionTitle('Salud de las plantas'),
                    _buildPlantHealthSection(),
                    const SizedBox(height: 40),
                  ],
                ),
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

  Widget _buildBarChart(List<Map<String, dynamic>> data, String key, Color color) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: CustomPaint(painter: BarChartPainter(data, key, color)),
    );
  }

  Widget _buildClimateLineChart(List<Map<String, dynamic>> data) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: CustomPaint(painter: ClimateLineChartPainter(data)),
    );
  }

  Widget _buildPlantHealthSection() {
    final plantData = _plantHealthData[_selectedPlant]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: _selectedPlant,
          isExpanded: true,
          items: _plants.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (value) => setState(() => _selectedPlant = value!),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: CustomPaint(painter: PlantHealthChartPainter(plantData)),
        ),
      ],
    );
  }
}

// 🎨── Gráficos
class BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final String keyName;
  final Color color;
  BarChartPainter(this.data, this.keyName, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final barWidth = size.width / (data.length * 1.5);
    final spacing = barWidth / 2;

    final values = data.map((e) => e[keyName] as num).toList();
    final minVal = values.reduce(min);
    final maxVal = values.reduce(max);
    final scale = (size.height * 0.7) / (maxVal - minVal);

    for (int i = 0; i < data.length; i++) {
      final value = data[i][keyName] as num;
      final normalizedHeight = (value - minVal) * scale;
      final x = spacing + i * (barWidth + spacing);
      final y = size.height - normalizedHeight - 30;

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, barWidth, normalizedHeight), const Radius.circular(6)),
        paint,
      );

      textPainter.text = TextSpan(text: data[i]['day'], style: const TextStyle(fontSize: 10, color: Colors.grey));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + barWidth / 2 - textPainter.width / 2, size.height - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ClimateLineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  ClimateLineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final tempPaint = Paint()..color = Colors.red..strokeWidth = 2;
    final humPaint = Paint()..color = Colors.blue..strokeWidth = 2;

    final tempValues = data.map((e) => e['temperature'] as num).toList();
    final humValues = data.map((e) => e['humidity'] as num).toList();
    final tMin = tempValues.reduce(min);
    final tMax = tempValues.reduce(max);
    final hMin = humValues.reduce(min);
    final hMax = humValues.reduce(max);

    final spacing = size.width / (data.length - 1);
    final tempPath = Path();
    final humPath = Path();

    for (int i = 0; i < data.length; i++) {
      final t = data[i]['temperature'] as num;
      final h = data[i]['humidity'] as num;
      final x = i * spacing;
      final yT = size.height - ((t - tMin) / (tMax - tMin)) * size.height * 0.8;
      final yH = size.height - ((h - hMin) / (hMax - hMin)) * size.height * 0.8;

      if (i == 0) {
        tempPath.moveTo(x, yT);
        humPath.moveTo(x, yH);
      } else {
        tempPath.lineTo(x, yT);
        humPath.lineTo(x, yH);
      }
    }

    canvas.drawPath(tempPath, tempPaint);
    canvas.drawPath(humPath, humPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PlantHealthChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  PlantHealthChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green..strokeWidth = 3..style = PaintingStyle.stroke;
    final path = Path();
    final spacing = size.width / (data.length - 1);

    final healthValues = data.map((e) => e['health'] as num).toList();
    final minVal = healthValues.reduce(min);
    final maxVal = healthValues.reduce(max);

    for (int i = 0; i < data.length; i++) {
      final h = data[i]['health'] as num;
      final x = i * spacing;
      final y = size.height - ((h - minVal) / (maxVal - minVal)) * size.height * 0.8;

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