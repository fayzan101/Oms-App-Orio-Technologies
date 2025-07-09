import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navBarItem(Icons.home, 'Home', 0),
            _navBarItem(Icons.list_alt, 'Order List', 1),
            const SizedBox(width: 48), // Space for FAB
            _navBarItem(Icons.bar_chart, 'Reports', 2),
            _navBarItem(Icons.menu, 'Menu', 3),
          ],
        ),
      ),
    );
  }

  Widget _navBarItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onTabSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF0A2A3A)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF0A2A3A))),
        ],
      ),
    );
  }
} 