import 'package:flutter/material.dart';
import './widgets/sensor_card.dart';
import '../chat_list_screen.dart';
import '../plant_analysis_screen.dart';
import '../../../services/sensor_service.dart';

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
    _sensorsData = _getDefaultSensorsData();
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

    try {
      // Obtiene la última lectura del sensor
      final readings = await SensorService.getSensorReadings(
        sensorId,
        limit: 1,
      );

      // Verifica que el widget aún esté montado antes de actualizar el estado
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (readings.isNotEmpty) {
          // Actualiza las tarjetas con los datos reales del backend
          _sensorsData = _buildSensorsData(readings.first);
        } else {
          // Si no hay datos, usa valores por defecto
          _sensorsData = _getDefaultSensorsData();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _sensorsData = _getDefaultSensorsData();
        });
      }
    }
  }

  /// Genera datos de sensores por defecto cuando no hay conexión
  ///
  /// Retorna:
  ///   - Lista de mapas con valores simulados para temperatura, humedad y luz
  List<Map<String, dynamic>> _getDefaultSensorsData() {
    return [
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
        'name': 'Luz',
        'reading': '850 lux',
        'date': DateTime.now().subtract(const Duration(minutes: 2)),
        'icon': Icons.light_mode,
        'color': Colors.amber,
      },
    ];
  }

  /// Construye la lista de datos para las tarjetas del dashboard
  ///
  /// Parámetros:
  ///   - reading: Lectura del sensor con los datos actuales
  ///
  /// Retorna:
  ///   - Lista de mapas con la información de cada sensor para mostrar
  List<Map<String, dynamic>> _buildSensorsData(Map<String, dynamic> reading) {
    return [
      {
        'name': 'Temperatura',
        'reading': '${(reading["temperature"] as num).toStringAsFixed(1)}°C',
        'date': DateTime.parse(reading['timestamp'] as String),
        'icon': Icons.thermostat,
        'color': Colors.orange,
      },
      {
        'name': 'Humedad',
        'reading': '${(reading["humidity"] as num).toStringAsFixed(1)}%',
        'date': DateTime.parse(reading['timestamp'] as String),
        'icon': Icons.water_drop,
        'color': Colors.blue,
      },
      {
        'name': 'Luz',
        'reading': '${(reading["light"] as num).toStringAsFixed(0)} lux',
        'date': DateTime.parse(reading['timestamp'] as String),
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
                        builder: (context) => const ChatListScreen(),
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
