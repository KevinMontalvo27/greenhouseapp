import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/greenhouse_screen.dart';

Future<void> main() async {
  // Asegurar que los bindings estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: ".env");
    print('Variables de entorno cargadas correctamente');
    print('API Base URL: ${dotenv.env['API_BASE_URL']}');
  } catch (e) {
    print('Error cargando .env: $e');
    print('Usando valores por defecto');
  }
  
  // Cargar sesión del usuario (si existe)
  final authService = AuthService();
  await authService.loadSession();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenhouse App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

/// Pantalla de Splash que verifica si hay sesión activa
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Esperar un poco para mostrar el splash (opcional)
    await Future.delayed(const Duration(seconds: 1));
    
    // Verificar si hay sesión activa
    final authService = AuthService();
  final userId = await authService.getUserId();
    final username = await authService.getUsername();
    
    if (!mounted) return;
    
    if (userId != null && username != null) {
      print('Sesión activa detectada: $username (ID: $userId)');
      
      // Hay sesión activa - ir directo a selección de invernaderos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GreenhouseScreen(),
        ),
      );
    } else {
      print('No hay sesión activa - mostrar login');
      
      // No hay sesión - ir a login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Azul oscuro
              Color(0xFF3B82F6), // Azul medio
              Color(0xFF60A5FA), // Azul claro
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono principal
              Icon(
                Icons.agriculture,
                size: 100,
                color: Colors.white,
              ),
              
              SizedBox(height: 24),
              
              // Título
              Text(
                'Greenhouse App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: 8),
              
              // Subtítulo
              Text(
                'Monitoreo inteligente',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              
              SizedBox(height: 48),
              
              // Loading indicator
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}