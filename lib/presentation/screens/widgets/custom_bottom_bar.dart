import 'package:flutter/material.dart';

class CustomBottomBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomBar({
    super.key,
    this.currentIndex = 0,
    required this.onTap,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Tendencias',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Datos Generales',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
    );
  }
}
