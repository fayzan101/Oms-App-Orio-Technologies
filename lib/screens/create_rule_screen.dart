import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_nav_bar.dart';

class CreateRuleScreen extends StatefulWidget {
  const CreateRuleScreen({Key? key}) : super(key: key);

  @override
  State<CreateRuleScreen> createState() => _CreateRuleScreenState();
}

class _CreateRuleScreenState extends State<CreateRuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ruleTitleController = TextEditingController();
  String? trigger;
  String? condition;
  String? thenAction;
  String? courier;
  String? courierCode;
  String? pickup;

  final List<String> triggers = ['Order Placed', 'Order Updated'];
  final List<String> conditions = ['Amount > 1000', 'Amount < 1000'];
  final List<String> thenActions = ['Send Email', 'Send SMS'];
  final List<String> couriers = ['TCS', 'Leopards', 'Blue Ex', 'CallCourier'];
  final List<String> courierCodes = ['Code1', 'Code2'];
  final List<String> pickups = ['Pickup1', 'Pickup2'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Create Rules'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
        child: Form(
          key: _formKey,
          child: ListView(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attention!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text(
                      'Rules will automatically apply in intervals of 10 minutes after the rule is added.',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: ruleTitleController,
                decoration: _inputDecoration('Rule Title'),
                validator: (val) => val == null || val.isEmpty ? 'Enter rule title' : null,
              ),
              const SizedBox(height: 16),
              _dropdown('If Trigger', triggers, trigger, (val) => setState(() => trigger = val)),
              const SizedBox(height: 16),
              _dropdown('Select Condition', conditions, condition, (val) => setState(() => condition = val)),
              const SizedBox(height: 16),
              _dropdown('Then', thenActions, thenAction, (val) => setState(() => thenAction = val)),
              const SizedBox(height: 16),
              _dropdown('Select Courier', couriers, courier, (val) => setState(() => courier = val)),
              const SizedBox(height: 16),
              _dropdown('Choose Courier Code', courierCodes, courierCode, (val) => setState(() => courierCode = val)),
              const SizedBox(height: 16),
              _dropdown('Select Pickup', pickups, pickup, (val) => setState(() => pickup = val)),
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
                    if (_formKey.currentState!.validate()) {
                      // Implement add rule logic
                    }
                  },
                  child: const Text('Add Rule', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A2A3A),
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 2,
        onTabSelected: (index) {
          if (index == 0) Get.offAllNamed('/dashboard');
          if (index == 1) Get.offAllNamed('/order-list');
          if (index == 2) Get.offAllNamed('/reports');
          if (index == 3) Get.offAllNamed('/menu');
        },
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select $label' : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: const Color(0xFFF7F8FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
} 