import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomBar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback? onMenuTap;
  final VoidCallback? onHomeTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onOrderListTap;
  
  const AppBottomBar({
    Key? key, 
    required this.selectedIndex, 
    this.onMenuTap, 
    this.onHomeTap, 
    this.onReportsTap, 
    this.onOrderListTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          // The border line
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              color: Color(0xFFB0B0B0), // bold grey
              // Add a subtle shadow below the line
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000), // subtle grey shadow
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // The actual BottomAppBar
          BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            elevation: 0,
            color: Colors.white,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavBarItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: selectedIndex == 0,
                    onTap: onHomeTap ?? () => Get.offAllNamed('/dashboard'),
                  ),
                  _NavBarItem(
                    icon: Icons.shopping_bag_rounded,
                    label: 'Order List',
                    selected: selectedIndex == 1,
                    onTap: onOrderListTap ?? () => Get.offAllNamed('/order-list'),
                  ),
                  const SizedBox(width: 56), // Space for FAB
                  _NavBarItem(
                    icon: Icons.tune_rounded,
                    label: 'Reports',
                    selected: selectedIndex == 2,
                    onTap: onReportsTap ?? () => Get.offAllNamed('/reports'),
                  ),
                  _NavBarItem(
                    icon: Icons.menu_rounded,
                    label: 'Menu',
                    selected: selectedIndex == 3,
                    onTap: onMenuTap ?? () => Get.offAllNamed('/menu'),
                    selectedColor: const Color(0xFF007AFF),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const _NavBarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? (selectedColor ?? const Color(0xFF007AFF))
        : const Color(0xFF222222);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
