import 'package:flutter/material.dart';
import './widgets/sensor_card.dart';
import '../gemini_screen.dart';
import '../plant_analysis_screen.dart';
import '../../../services/api_service.dart';
import '../../../models/sensor_reading.dart';

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

  // Estado de carga de datos del sensor
  bool _isLoading = false;

  // ID del sensor a consultar (ajustar según tu configuración)
  static const int sensorId = 1;

  // Datos de los sensores que se mostrarán en las tarjetas
  // Inicializados con valores por defecto y se actualizan con datos reales
  List<Map<String, dynamic>> _sensorsData = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Muestra datos por defecto inmediatamente
    _sensorsData = _buildSensorsData(SensorReading.defaultReading());
    // Carga datos reales del sensor en segundo plano
    _loadSensorData();
  }

  /// Obtiene la lectura más reciente del sensor desde el backend
  ///
  /// Actualiza el estado con los datos reales de temperatura, humedad y luz.
  /// Si no hay conexión, mantiene los valores por defecto.
  /// Verifica que el widget esté montado antes de llamar setState.
  Future<void> _loadSensorData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    // Llama al servicio para obtener la última lectura del sensor
    final reading = await ApiService.getLatestReading(sensorId);

    // Verifica que el widget aún esté montado antes de actualizar el estado
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      // Actualiza las tarjetas con los datos reales del backend
      _sensorsData = _buildSensorsData(reading);
    });
  }

  /// Construye la lista de datos para las tarjetas del dashboard
  ///
  /// Parámetros:
  ///   - reading: Lectura del sensor con los datos actuales
  ///
  /// Retorna:
  ///   - Lista de mapas con la información de cada sensor para mostrar
  List<Map<String, dynamic>> _buildSensorsData(SensorReading reading) {
    return [
      {
        'name': 'Temperatura',
        'reading': '${reading.temperature.toStringAsFixed(1)}°C',
        'date': reading.timestamp,
        'icon': Icons.thermostat,
        'color': Colors.orange,
      },
      {
        'name': 'Humedad',
        'reading': '${reading.humidity.toStringAsFixed(1)}%',
        'date': reading.timestamp,
        'icon': Icons.water_drop,
        'color': Colors.blue,
      },
      {
        'name': 'Luz',
        'reading': '${reading.light.toStringAsFixed(0)} lux',
        'date': reading.timestamp,
        'icon': Icons.light_mode,
        'color': Colors.amber,
      },
    ];
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
                  Row(
                    children: [
                      const Text(
                        'Monitoreo de sensores en tiempo real',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      // Indicador visual del estado de carga
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
          CustomScrollView(
            controller: _scrollController,
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
                  child: RefreshIndicator(
                    // Permite actualizar los datos deslizando hacia abajo
                    onRefresh: _loadSensorData,
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
                      physics: const AlwaysScrollableScrollPhysics(),
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PlantAnalysisScreen(),
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
