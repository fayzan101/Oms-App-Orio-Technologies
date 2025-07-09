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
              TextFormField(
                controller: ruleTitleController,
                decoration: _inputDecoration('Rule Title'),
                validator: (val) => val == null || val.isEmpty ? 'Enter rule title' : null,
              ),
              const SizedBox(height: 16),
              _dropdown('If Trigger', triggers, trigger, (val) => setState(() => trigger = val)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  _showSelectConditionsSheet(context, (selected) {
                    setState(() {
                      condition = selected;
                    });
                  });
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: _inputDecoration('Select Condition'),
                    controller: TextEditingController(text: condition),
                    validator: (val) => val == null || val.isEmpty ? 'Please select condition' : null,
                  ),
                ),
              ),
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

  void _showSelectConditionsSheet(BuildContext context, ValueChanged<String> onSelected) {
    final List<String> conditions = [
      'Weight',
      'Payment Method',
      'City List',
      'Order Value',
      'Platform',
      'Address Keywords',
    ];
    TextEditingController searchController = TextEditingController();
    List<String> filtered = List.from(conditions);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Select Conditions',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (val) {
                          setState(() {
                            filtered = conditions
                                .where((c) => c.toLowerCase().contains(val.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...filtered.map((c) => Column(
                          children: [
                            ListTile(
                              title: Text(c),
                              onTap: () {
                                onSelected(c);
                                Navigator.of(context).pop();
                              },
                            ),
                            const Divider(height: 1),
                          ],
                        )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
} 