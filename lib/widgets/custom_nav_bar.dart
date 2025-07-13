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
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFF222222), width: 0.3), // dark grey top border
            ),
          ),
          child: BottomAppBar(
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navBarItem(Icons.home_rounded, 'Home', 0),
                  _navBarItem(Icons.list_alt_rounded, 'Order List', 1),
                  const SizedBox(width: 48), // Space for FAB
                  _navBarItem(Icons.bar_chart_rounded, 'Reports', 2),
                  _navBarItem(Icons.menu_rounded, 'Menu', 3),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _NotchBorderPainter(),
            ),
          ),
        ),
      ],
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

class _NotchBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0B0B0) // grey color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 // thick shadow
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8); // soft shadow

    // Parameters matching BottomAppBar's notch
    final double fabRadius = 28.0; // FAB is usually 56x56
    final double notchMargin = 8.0;
    final double notchRadius = fabRadius + notchMargin;
    final double notchCenterX = size.width / 2;
    final double topY = 0.0;

    final double r = notchRadius;
    final double s1 = 15.0;
    final double left = notchCenterX - r - s1;
    final double right = notchCenterX + r + s1;

    final path = Path();
    path.moveTo(0, topY);
    path.lineTo(left, topY);
    final Rect notchRect = Rect.fromCircle(center: Offset(notchCenterX, topY), radius: r);
    path.arcTo(notchRect, 3.14, -3.14, false);
    path.lineTo(size.width, topY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 