import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/Layout/app_bottom_bar.dart';
import 'calendar_screen.dart'; // Import the new CalendarScreen

class OrioRuleDetailScreen extends StatefulWidget {
  const OrioRuleDetailScreen({Key? key}) : super(key: key);

  @override
  State<OrioRuleDetailScreen> createState() => _OrioRuleDetailScreenState();
}

class _OrioRuleDetailScreenState extends State<OrioRuleDetailScreen> {
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF007AFF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF007AFF),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      print('Selected date: \\${picked.toIso8601String()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text('Orio Rules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF007AFF)),
            onPressed: () {
              Get.to(() => const CalendarScreen());
            },
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, color: Color(0xFF007AFF)),
            label: const Text(
              'Create Rule',
              style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF181A3D),
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/rule_banner.png'),
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                opacity: 0.2,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Attention!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  'Rules will automatically apply in intervals of 10 minutes after the rule is added.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Rule - 01',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: true,
                onChanged: (v) {},
                activeColor: Color(0xFF007AFF),
              ),
            ],
          ),
          if (_selectedDate != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Selected: \\${_selectedDate!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 15, color: Color(0xFF007AFF)),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _detailBox('Testing Rule'),
          const SizedBox(height: 12),
          _detailBox('First Call Attempt'),
          const SizedBox(height: 12),
          _detailBox('Weight'),
          const SizedBox(height: 12),
          _detailBox('Equal to'),
          const SizedBox(height: 12),
          _detailBox('10 KG'),
          const SizedBox(height: 12),
          _detailBox('With 3PL'),
          const SizedBox(height: 12),
          _detailBox('Account 9 (BlueEx)'),
          const SizedBox(height: 12),
          _detailBox('BLUE CARGO'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A2A3A),
        onPressed: () {},
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: const AppBottomBar(selectedIndex: 2),
    );
  }

  Widget _detailBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }
} 