import 'package:flutter/material.dart';
import './widgets/sensor_card.dart';
import '../gemini_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  final int userId;

  const DashboardScreen({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ScrollController _scrollController;

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                  Text(
                    '¡Hola, ${widget.username}!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Monitoreo de sensores en tiempo real',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          // Capa 2: Contenido desplazable que tapa la capa 1
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 100)),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Función de cámara próximamente'),
                            duration: Duration(seconds: 1),
                          ),
                        );
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
                        builder: (context) => const GeminiScreen(),
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
