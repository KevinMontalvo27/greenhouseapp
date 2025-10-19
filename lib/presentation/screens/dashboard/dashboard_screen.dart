import 'package:flutter/material.dart';
import './widgets/sensor_card.dart';
// import '../chat/widgets/custom_bottom_bar.dart';
// import '../trending_screen.dart';
// import '../map_screen.dart';
import '../gemini_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String username;

  const DashboardScreen({super.key, required this.username});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
  // Fin de clase
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ScrollController _scrollController;
  double _scrollOpacity = 1.0;

  // Datos simulados de sensores
  final List<Map<String, dynamic>> _sensorsData = [
    {
      'name': 'Temperatura',
      'reading': '24.5°C',
      'date': DateTime.now().subtract(const Duration(minutes: 5)),
      'icon': Icons.thermostat,
      'color': Colors.orange,
    },
    {
      'name': 'Humedad',
      'reading': '65%',
      'date': DateTime.now().subtract(const Duration(minutes: 3)),
      'icon': Icons.water_drop,
      'color': Colors.blue,
    },
    {
      'name': 'Presión',
      'reading': '1013 hPa',
      'date': DateTime.now().subtract(const Duration(minutes: 8)),
      'icon': Icons.speed,
      'color': Colors.purple,
    },
    {
      'name': 'Luz',
      'reading': '850 lux',
      'date': DateTime.now().subtract(const Duration(minutes: 2)),
      'icon': Icons.light_mode,
      'color': Colors.amber,
    },
    {
      'name': 'CO2',
      'reading': '420 ppm',
      'date': DateTime.now().subtract(const Duration(minutes: 10)),
      'icon': Icons.air,
      'color': Colors.green,
    },
    {
      'name': 'Sonido',
      'reading': '45 dB',
      'date': DateTime.now().subtract(const Duration(minutes: 1)),
      'icon': Icons.volume_up,
      'color': Colors.teal,
    },
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
                        Text(
                          '¡Hola, ${widget.username}!',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Monitoreo de sensores en tiempo real',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
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
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: _sensorsData.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final sensor = _sensorsData[index];
                      return SensorCard(
                        sensorName: sensor['name'],
                        reading: sensor['reading'],
                        readingDate: sensor['date'],
                        icon: sensor['icon'],
                        color: sensor['color'],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Acción de la cámara
                      },
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.blue.shade700,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'gemini',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            // Asegúrate de importar GeminiScreen arriba
                            GeminiScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    'assets/gemini.png',
                    width: 32,
                    height: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
