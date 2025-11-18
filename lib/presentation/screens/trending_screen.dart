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
    {'day': 'Lun', 'temperature': 22.5, 'humidity': 60.0, 'light': 800.0},
    {'day': 'Mar', 'temperature': 23.1, 'humidity': 62.0, 'light': 820.0},
    {'day': 'Mié', 'temperature': 24.5, 'humidity': 65.0, 'light': 850.0},
    {'day': 'Jue', 'temperature': 23.8, 'humidity': 63.0, 'light': 830.0},
    {'day': 'Vie', 'temperature': 25.2, 'humidity': 67.0, 'light': 870.0},
    {'day': 'Sab', 'temperature': 24.0, 'humidity': 64.0, 'light': 840.0},
    {'day': 'Dom', 'temperature': 23.5, 'humidity': 61.0, 'light': 810.0},
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
      child: CustomPaint(
        painter: BarChartPainter(data, key, color),
      ),
    );
  }

  Widget _buildClimateLineChart(List<Map<String, dynamic>> data) {
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
      child: CustomPaint(
        painter: ClimateLineChartPainter(data),
      ),
    );
  }

  Widget _buildPlantHealthSection() {
    final plantData = _plantHealthData[_selectedPlant]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
          child: DropdownButton<String>(
            value: _selectedPlant,
            isExpanded: true,
            underline: const SizedBox(),
            items: _plants.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (value) => setState(() => _selectedPlant = value!),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
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
          child: CustomPaint(
            painter: PlantHealthChartPainter(plantData),
          ),
        ),
      ],
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
          Rect.fromLTWH(x.toDouble(), y.toDouble(), barWidth.toDouble(), normalizedHeight.toDouble()),
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

class ClimateLineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  
  ClimateLineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final tempPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final humPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final tempValues = data.map((e) => (e['temperature'] as num).toDouble()).toList();
    final humValues = data.map((e) => (e['humidity'] as num).toDouble()).toList();
    
    final tMin = tempValues.reduce(min);
    final tMax = tempValues.reduce(max);
    final hMin = humValues.reduce(min);
    final hMax = humValues.reduce(max);
    
    final tRange = tMax - tMin;
    final hRange = hMax - hMin;

    final spacing = size.width / (data.length - 1);
    final tempPath = Path();
    final humPath = Path();

    for (int i = 0; i < data.length; i++) {
      final t = (data[i]['temperature'] as num).toDouble();
      final h = (data[i]['humidity'] as num).toDouble();
      final x = i * spacing;
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
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    final spacing = size.width / (data.length - 1);

    final healthValues = data.map((e) => (e['health'] as num).toDouble()).toList();
    final minVal = healthValues.reduce(min);
    final maxVal = healthValues.reduce(max);
    final range = maxVal - minVal;

    for (int i = 0; i < data.length; i++) {
      final h = (data[i]['health'] as num).toDouble();
      final x = i * spacing;
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