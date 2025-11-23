import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PlantAnalysisScreen extends StatefulWidget {
  const PlantAnalysisScreen({super.key});

  @override
  State<PlantAnalysisScreen> createState() => _PlantAnalysisScreenState();
}

class _PlantAnalysisScreenState extends State<PlantAnalysisScreen> {
  late ScrollController _scrollController;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

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

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al tomar foto: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Seleccionar imagen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.blue.shade700,
                  ),
                ),
                title: const Text('Tomar foto'),
                subtitle: const Text('Usar la cámara del dispositivo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: Colors.green.shade700,
                  ),
                ),
                title: const Text('Galería'),
                subtitle: const Text('Seleccionar de tu galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('Por favor selecciona una imagen primero');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    // TODO: Aquí se conectará con el endpoint del backend
    // Por ahora simulamos un análisis
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isAnalyzing = false;
      // Resultado simulado - se reemplazará con la respuesta real del backend
      _analysisResult = {
        'predictions': [
          {'label': 'Tomato___healthy', 'score': 0.95},
          {'label': 'Tomato___Early_blight', 'score': 0.03},
          {'label': 'Tomato___Late_blight', 'score': 0.02},
        ],
      };
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _analysisResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearImage,
              tooltip: 'Nueva imagen',
            ),
        ],
      ),
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
                      'Análisis de Plantas',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Detecta enfermedades en tus plantas',
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
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Área de imagen
                          _buildImageArea(),
                          const SizedBox(height: 20),

                          // Botones de acción
                          _buildActionButtons(),
                          const SizedBox(height: 20),

                          // Resultados del análisis
                          if (_analysisResult != null) _buildAnalysisResults(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageArea() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _selectedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                  if (_isAnalyzing)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Analizando...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )
            : InkWell(
                onTap: _showImageSourceDialog,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 50,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Toca para agregar una imagen',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toma una foto o selecciona de tu galería',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón principal para seleccionar/cambiar imagen
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Botón de analizar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectedImage != null && !_isAnalyzing
                ? _analyzeImage
                : null,
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.search),
            label: Text(_isAnalyzing ? 'Analizando...' : 'Analizar Planta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisResults() {
    final predictions = _analysisResult!['predictions'] as List;
    final topPrediction = predictions.first;
    final label = topPrediction['label'] as String;
    final score = topPrediction['score'] as double;
    final isHealthy = label.toLowerCase().contains('healthy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isHealthy ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isHealthy ? Icons.check_circle : Icons.warning,
                  color: isHealthy ? Colors.green.shade700 : Colors.red.shade700,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resultado del Análisis',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      isHealthy ? 'Planta Saludable' : 'Problema Detectado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isHealthy
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Predicciones:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...predictions.map((pred) {
            final predLabel = _formatLabel(pred['label'] as String);
            final predScore = pred['score'] as double;
            final percentage = (predScore * 100).toStringAsFixed(1);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          predLabel,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: predScore,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        predLabel.toLowerCase().contains('healthy')
                            ? Colors.green
                            : Colors.orange,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatLabel(String label) {
    // Convierte "Tomato___Early_blight" a "Tomato - Early blight"
    return label
        .replaceAll('___', ' - ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}