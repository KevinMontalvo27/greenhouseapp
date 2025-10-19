import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'trending_screen.dart';
import 'map_screen.dart';
import 'widgets/custom_bottom_bar.dart'; // Ensure the path is correct

class MainScreen extends StatefulWidget {
  final String username;
  final VoidCallback? onLogout;
  const MainScreen({super.key, required this.username, this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return TrendingScreen();
      case 1:
        return DashboardScreen(username: widget.username);
      case 2:
        return MapScreen();
      default:
        return DashboardScreen(username: widget.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Tendencias'
              : _selectedIndex == 1
              ? 'Dashboard'
              : 'Mapa',
          style: const TextStyle(
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
              if (widget.onLogout != null) {
                widget.onLogout!();
              }
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
