import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'order_list_screen.dart';
import 'report.dart' as report;
import 'dashboard_screen.dart' as dash;
import 'menu.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Rules',
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Launch Rules',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'This section allows you to create Orio Rules,\nUse Orio Rules to automate your flows.',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Illustration
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/icon/graph.png', // Replace with your illustration asset
                  width: 220,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No rule available please create rule!',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Color(0xFF8E8E93),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Create Rule',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0A253B),
        child: const Icon(Icons.edit, color: Colors.white),
        elevation: 4,
      ),
      bottomNavigationBar: dash.CustomBottomNavBar(
        selectedIndex: 4,
        onHomeTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => dash.DashboardScreen()),
            (route) => false,
          );
        },
        onOrderListTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => OrderListScreen()),
            (route) => false,
          );
        },
        onReportsTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => report.ReportsScreen()),
            (route) => false,
          );
        },
        onMenuTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MenuScreen()),
            (route) => false,
          );
        },
      ),
    );
  }
} 