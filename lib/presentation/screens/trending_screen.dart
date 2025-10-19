import 'package:flutter/material.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  late ScrollController _scrollController;
  double _scrollOpacity = 1.0;

  // Datos simulados de sensores por día
  final List<Map<String, dynamic>> _trendingData = [
    {'day': 'Lun', 'temperature': 22.5, 'humidity': 60, 'light': 800},
    {'day': 'Mar', 'temperature': 23.1, 'humidity': 62, 'light': 820},
    {'day': 'Mié', 'temperature': 24.5, 'humidity': 65, 'light': 850},
    {'day': 'Jue', 'temperature': 23.8, 'humidity': 63, 'light': 830},
    {'day': 'Vie', 'temperature': 25.2, 'humidity': 67, 'light': 870},
    {'day': 'Sab', 'temperature': 24.0, 'humidity': 64, 'light': 840},
    {'day': 'Dom', 'temperature': 23.5, 'humidity': 61, 'light': 810},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    double scrollPosition = _scrollController.offset;
    double newOpacity = 1.0 - (scrollPosition / 150).clamp(0.0, 1.0);

    if (newOpacity != _scrollOpacity) {
      setState(() {
        _scrollOpacity = newOpacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: false,
                floating: true,
                snap: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                expandedHeight: 90,
                title: AnimatedOpacity(
                  opacity: _scrollOpacity,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Tendencias de las últimas semanas',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Analiza el comportamiento de tus sensores',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Temperatura (°C)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildBarChart(
                            _trendingData,
                            'temperature',
                            Colors.orange,
                            0,
                            30,
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Humedad (%)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildBarChart(
                            _trendingData,
                            'humidity',
                            Colors.blue,
                            0,
                            100,
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Luz (lux)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildBarChart(
                            _trendingData,
                            'light',
                            Colors.amber,
                            0,
                            1000,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    List<Map<String, dynamic>> data,
    String key,
    Color barColor,
    double minValue,
    double maxValue,
  ) {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: BarChartPainter(
          data: data,
          key: key,
          barColor: barColor,
          minValue: minValue,
          maxValue: maxValue,
        ),
        size: const Size(double.infinity, 200),
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final String key;
  final Color barColor;
  final double minValue;
  final double maxValue;

  BarChartPainter({
    required this.data,
    required this.key,
    required this.barColor,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final barWidth = size.width / (data.length * 1.5);
    final spacing = barWidth * 0.5;
    final chartHeight = size.height * 0.8;
    final bottomPadding = size.height * 0.2;

    for (int i = 0; i < data.length; i++) {
      final value = data[i][key] as double;
      final normalizedValue = ((value - minValue) / (maxValue - minValue))
          .clamp(0.0, 1.0);

      final x = i * (barWidth + spacing) + spacing;
      final barHeight = normalizedValue * chartHeight;
      final y = size.height - bottomPadding - barHeight;

      // Dibujar barra
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(8),
        ),
        paint,
      );

      // Dibujar etiqueta del día
      final dayText = data[i]['day'] as String;
      textPainter.text = TextSpan(
        text: dayText,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + barWidth / 2 - textPainter.width / 2,
          size.height - bottomPadding + 10,
        ),
      );

      // Dibujar valor sobre la barra
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, y - 16),
      );
    }

    // Dibujar línea base
    final basePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - bottomPadding),
      Offset(size.width, size.height - bottomPadding),
      basePaint,
    );
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) => false;
}
