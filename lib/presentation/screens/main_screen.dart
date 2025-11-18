import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'trending_screen.dart';
import 'map_screen.dart';
import 'widgets/custom_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  final String username;
  final int userId;
  final VoidCallback? onLogout;
  
  const MainScreen({
    super.key,
    required this.username,
    required this.userId,
    this.onLogout,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return const TrendingScreen();
      case 1:
        return DashboardScreen(
          username: widget.username,
          userId: widget.userId,
        );
      case 2:
        return const MapScreen();
      default:
        return DashboardScreen(
          username: widget.username,
          userId: widget.userId,
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
                        if (widget.onLogout != null) {
                          widget.onLogout!();
                        }
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