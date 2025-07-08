import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart' as dash;
import 'menu.dart' as menu;
import 'report.dart' as report;
import 'package:flutter/services.dart';

class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Create Order',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      // Divider line after AppBar
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 1,
            color: Color(0xFFE0E0E0),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add Product Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8, bottom: 20),
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F7),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Please add Product',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color(0xFF222222),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.add_circle_outline, color: Color(0xFF222222), size: 22),
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    'Customer Detail',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _OrderField(hint: 'Full Name'),
                  _OrderField(hint: 'Email'),
                  _OrderField(hint: 'Phone'),
                  _OrderField(hint: 'Order Reference Code'),
                  _OrderField(hint: 'Address'),
                  _OrderField(hint: 'Landmark'),
                  _OrderDropdownField(hint: 'Destination Country'),
                  _OrderDropdownField(hint: 'Destination City'),
                  _OrderField(hint: 'Latitude'),
                  _OrderField(hint: 'Longitude'),
                  _OrderField(hint: 'Weight'),
                  _OrderField(hint: 'Shipping Charges'),
                  _OrderDropdownField(hint: 'Payment Type'),
                  _OrderField(hint: 'Remarks'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32), // Extra padding for FAB/nav bar
                  SafeArea(child: SizedBox()),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: dash.CustomBottomNavBar(
        selectedIndex: 3,
        onHomeTap: () {
          Get.offAll(() => dash.DashboardScreen());
        },
        onMenuTap: () {
          Get.offAll(() => menu.MenuScreen());
        },
        onReportsTap: () {
          Get.offAll(() => report.ReportsScreen());
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
    );
  }
}

class _OrderField extends StatelessWidget {
  final String hint;
  const _OrderField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: Color(0xFF6B6B6B),
          ),
          filled: true,
          fillColor: Color(0xFFF5F5F7),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _OrderDropdownField extends StatelessWidget {
  final String hint;
  const _OrderDropdownField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: IgnorePointer(
        child: DropdownButtonFormField<String>(
          items: const [],
          onChanged: (_) {},
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Color(0xFF6B6B6B),
            ),
            filled: true,
            fillColor: Color(0xFFF5F5F7),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
        ),
      ),
    );
  }
} 