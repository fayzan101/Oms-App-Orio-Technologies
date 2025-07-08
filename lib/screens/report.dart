import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart';
import 'menu.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show both status and navigation bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
            onPressed: () => Get.offAll(() => DashboardScreen()),
          ),
          title: const Text(
            'Reports',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.1,
            children: const [
              _ReportCard(
                icon: Icons.assignment_outlined,
                label: 'COD Statements',
              ),
              _ReportCard(
                icon: Icons.show_chart_outlined,
                label: 'Ageing Report',
              ),
              _ReportCard(
                icon: Icons.grid_view_rounded,
                label: 'Courier Insights Report',
              ),
              _ReportCard(
                icon: Icons.description_outlined,
                label: 'Load Sheet',
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: 2,
          onHomeTap: () {
            Get.offAll(() => DashboardScreen());
          },
          onMenuTap: () {
            Get.offAll(() => const MenuScreen());
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF0A253B),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.edit, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ReportCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F7),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF007AFF), size: 40),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback? onMenuTap;
  final VoidCallback? onHomeTap;
  const CustomBottomNavBar({Key? key, required this.selectedIndex, this.onMenuTap, this.onHomeTap}) : super(key: key);

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
              height: 1,
              color: const Color(0xFFB0B0B0),
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
                    icon: Icons.home_outlined,
                    label: 'Home',
                    selected: selectedIndex == 0,
                    onTap: onHomeTap ?? () {},
                  ),
                  _NavBarItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Order List',
                    selected: selectedIndex == 1,
                    onTap: () {},
                  ),
                  const SizedBox(width: 56), // Space for FAB
                  _NavBarItem(
                    icon: Icons.tune_outlined,
                    label: 'Reports',
                    selected: selectedIndex == 2,
                    onTap: () {},
                  ),
                  _NavBarItem(
                    icon: Icons.menu,
                    label: 'Menu',
                    selected: selectedIndex == 4,
                    onTap: onMenuTap ?? () {},
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