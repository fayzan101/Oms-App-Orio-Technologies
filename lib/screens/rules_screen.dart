import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/Layout/app_bottom_bar.dart';
import 'create_rule_screen.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Rules'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Launch Rules',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'This section allows you to create Orio Rules,\nUse Orio Rules to automate your flows.',
                style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
              ),
            ),
            const SizedBox(height: 32),
            // Placeholder for illustration
            Center(
              child: SizedBox(
                height: 160,
                child: Image.asset(
                  'assets/rules_illustration.png',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Icon(Icons.rule, size: 120, color: Colors.grey[300]),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No rule available please create rule!',
              style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Get.to(() => const CreateRuleScreen());
                },
                child: const Text('Create Rule', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A2A3A),
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const AppBottomBar(currentTab: 2),
    );
  }
} 