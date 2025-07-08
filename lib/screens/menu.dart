import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';
import 'report.dart' as report;
import 'create_order.dart' as create_order;
import 'order_list_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _isDialogOpen = false;

  Future<void> showSuccessDialog(BuildContext context, {String title = 'Success!', String message = 'Action completed successfully.'}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F7),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(32),
                  child: Icon(Icons.check_circle_outline, color: Color(0xFF007AFF), size: 64),
                ),
                SizedBox(height: 24),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007AFF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Profile Image
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, size: 38, color: Colors.grey[400]),
                      ),
                      const SizedBox(width: 16),
                      // Name, Email, Profile Button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Asad Ahmed Khan',
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'asadahmedkhan17@gmail.com',
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 28,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF007AFF), width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  minimumSize: const Size(0, 28),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Profile',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: Color(0xFF007AFF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Menu Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Menu List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 0),
                  children: [
                    _MenuItem(
                      icon: Icons.local_shipping_outlined,
                      label: 'Courier Companies',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.notifications_none_outlined,
                      label: 'Notifications',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.tune,
                      label: 'Rules',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.play_circle_outline,
                      label: 'Help Videos',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.power_settings_new,
                      label: 'Sign Out',
                      onTap: () => showLogoutBottomSheet(Get.context!),
                      iconColor: const Color(0xFF007AFF),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _isDialogOpen ? null : CustomBottomNavBar(
          selectedIndex: 4,
          onHomeTap: () {
            Get.offAll(() => DashboardScreen());
          },
          onReportsTap: () {
            Get.offAll(() => report.ReportsScreen());
          },
          onMenuTap: () {},
          onOrderListTap: () {
            Get.to(() => const OrderListScreen());
          },
          onPencilTap: () {
            Get.offAll(() => create_order.CreateOrderScreen());
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.offAll(() => create_order.CreateOrderScreen());
          },
          backgroundColor: const Color(0xFF0A253B),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.edit, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

void showLogoutBottomSheet(BuildContext context) async {
  final state = context.findAncestorStateOfType<_MenuScreenState>();
  state?.setState(() => state._isDialogOpen = true);
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F7),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(32),
                child: Icon(Icons.delete_outline, color: Color(0xFF007AFF), size: 64),
              ),
              SizedBox(height: 24),
              Text(
                'Are you Sure',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You want to logout',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: Color(0xFF8E8E93),
                ),
              ),
              SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF2F2F7),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'No',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF007AFF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  state?.setState(() => state._isDialogOpen = false);
  if (result == true) {
    await Get.find<AuthService>().logout();
    state?.setState(() => state._isDialogOpen = true);
    await state?.showSuccessDialog(context, title: 'Logged out!', message: 'You have been logged out successfully.');
    state?.setState(() => state._isDialogOpen = false);
    Get.offAll(() => SignInScreen());
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _MenuItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? const Color(0xFF007AFF),
                size: 22,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF8E8E93), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback? onHomeTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onOrderListTap;
  final VoidCallback? onPencilTap;
  const CustomBottomNavBar({Key? key, required this.selectedIndex, this.onHomeTap, this.onReportsTap, this.onMenuTap, this.onOrderListTap, this.onPencilTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BottomAppBar(
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
                onTap: onOrderListTap ?? () {},
              ),
              const SizedBox(width: 56), // Space for FAB
              _NavBarItem(
                icon: Icons.tune_outlined,
                label: 'Reports',
                selected: selectedIndex == 2,
                onTap: onReportsTap ?? () {},
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