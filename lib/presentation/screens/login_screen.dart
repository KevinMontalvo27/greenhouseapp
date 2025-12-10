import 'package:flutter/material.dart';
import '../../services/login_service.dart';
import 'greenhouse_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _tapCount = 0;
  bool _showBypassButton = false;
  bool _databaseError = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleScreenTap() {
    setState(() {
      _tapCount++;
    });

    if (_tapCount >= 5 && !_showBypassButton) {
      setState(() {
        _showBypassButton = true;
      });
      _showInfo('🔓 Botón de omisión desbloqueado');
    }
  }

  void _handleBypassLogin() {
    print('🔓 Omitiendo login...');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GreenhouseScreen()),
    );
  }

  Future<void> _handleLogin() async {
    // Validar campos
    if (_usernameController.text.trim().isEmpty) {
      _showError('Por favor ingresa tu usuario');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Por favor ingresa tu contraseña');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔄 Iniciando login...');

      final result = await LoginService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Verificar si es un error de conexión a BD
      if (result['message']?.contains('connection') ??
          false || result['message']?.contains('database') ??
          false) {
        setState(() {
          _databaseError = true;
        });
        _showWarning(
          '⚠️ Error de base de datos - Algunos datos pueden no cargarse',
        );
        print('⚠️ Error de BD detectado: ${result['message']}');
        // Permitir continuar a pesar del error
      }

      if (result['success']) {
        print('✅ Login exitoso');

        // Navegar a la pantalla de selección de invernaderos
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GreenhouseScreen()),
        );
      } else {
        _showError(result['message'] ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      print('❌ Error en login: $e');

      // Detectar si es un error de base de datos
      String errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('connection') ||
          errorMsg.contains('database') ||
          errorMsg.contains('server')) {
        setState(() {
          _databaseError = true;
        });
        _showWarning(
          '⚠️ No se pudo conectar a la base de datos - La app continuará en modo limitado',
        );
        print('⚠️ Error de base de datos: $e');
        // Permitir continuar a pesar del error
      } else {
        if (mounted) {
          _showError('Error de conexión. Verifica tu red.');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _handleScreenTap,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo o icono
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.agriculture, // Icono de agricultura
                        size: 80,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Greenhouse App',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Monitoreo inteligente de invernaderos',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),

                    const SizedBox(height: 48),

                    // Formulario
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Campo de usuario
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            enabled: !_isLoading,
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 16),

                          // Campo de contraseña
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            enabled: !_isLoading,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleLogin(),
                          ),

                          const SizedBox(height: 24),

                          // Botón de login
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          // Botón de omisión (solo si está desbloqueado)
                          if (_showBypassButton) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : _handleBypassLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '🔓 Omitir Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
