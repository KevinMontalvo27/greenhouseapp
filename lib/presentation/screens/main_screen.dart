import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'trending_screen.dart';
import 'map_screen.dart';
import 'widgets/custom_bottom_bar.dart';
import '../../services/auth_service.dart';
import '../../services/login_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 1;
  String username = 'Usuario';
  int userId = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getUsername();
    final id = await _authService.getUserId();
    
    setState(() {
      username = user ?? 'Usuario';
      userId = id ?? 0;
      isLoading = false;
    });
  }

  Widget _getBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return const TrendingScreen();
      case 1:
        return DashboardScreen(
          username: username,
          userId: userId,
        );
      case 2:
        return const MapScreen();
      default:
        return DashboardScreen(
          username: username,
          userId: userId,
        );
    }
  }

  Future<void> _handleLogout() async {
    await LoginService.logout();
    
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Datos actualizados'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleLogout();
                      },
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}