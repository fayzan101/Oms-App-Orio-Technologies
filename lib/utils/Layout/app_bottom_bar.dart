import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomBar extends StatelessWidget {
  final int currentTab;
  const AppBottomBar({Key? key, required this.currentTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    double barHeight = mediaQuery.size.height * 0.09;
    double iconSize = mediaQuery.size.width * 0.07;
    double fontSize = 12;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 205, 203, 203).withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.white,
        elevation: 18.0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: barHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavButton(
                icon: Icons.home,
                label: 'Home',
                tab: 0,
                currentTab: currentTab,
                onTap: () => Get.offAllNamed('/dashboard'),
                iconSize: iconSize,
                fontSize: fontSize,
              ),
              _NavButton(
                icon: Icons.list_alt,
                label: 'Order List',
                tab: 1,
                currentTab: currentTab,
                onTap: () => Get.offAllNamed('/order-list'),
                iconSize: iconSize,
                fontSize: fontSize,
              ),
              _NavButton(
                icon: Icons.bar_chart,
                label: 'Reports',
                tab: 2,
                currentTab: currentTab,
                onTap: () => Get.offAllNamed('/reports'),
                iconSize: iconSize,
                fontSize: fontSize,
              ),
              _NavButton(
                icon: Icons.menu,
                label: 'Menu',
                tab: 3,
                currentTab: currentTab,
                onTap: () => Get.offAllNamed('/menu'),
                iconSize: iconSize,
                fontSize: fontSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int tab;
  final int currentTab;
  final VoidCallback onTap;
  final double iconSize;
  final double fontSize;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.tab,
    required this.currentTab,
    required this.onTap,
    required this.iconSize,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentTab == tab;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700;
    return MaterialButton(
      onPressed: onTap,
      padding: EdgeInsets.zero, // Remove extra padding
      minWidth: 0, // Remove minimum width constraint
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: iconSize),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
