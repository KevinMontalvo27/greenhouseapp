import 'package:flutter/material.dart';
import './widgets/sensor_card.dart';
class DashboardScreen extends StatefulWidget {
  final String username;

  const DashboardScreen({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                // Simular actualización de datos
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Datos actualizados'),
                    duration: Duration(seconds: 1),
                  ),
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.grey.shade100,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(20.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _sensorsData.length,
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
      ),
    );
  }
}