import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/Layout/app_bottom_bar.dart';
import '../services/auth_service.dart';
import '../services/rules_service.dart';
import '../utils/custom_snackbar.dart';

class EditRuleScreen extends StatefulWidget {
  final Map<String, dynamic> ruleData;
  
  const EditRuleScreen({Key? key, required this.ruleData}) : super(key: key);

  @override
  State<EditRuleScreen> createState() => _EditRuleScreenState();
}

class _EditRuleScreenState extends State<EditRuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ruleTitleController = TextEditingController();
  final TextEditingController serviceCodeController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();
  late final RulesService _rulesService;
  
  // Form fields for editing
  String? selectedCourierId;
  String? selectedCustomerCourierId;
  String? selectedPickupId;
  String? selectedStatus;
  
  // Dropdown options
  final List<String> couriers = ['1', '2', '3']; // Courier IDs
  final List<String> customerCouriers = ['55', '56', '57']; // Customer courier IDs
  final List<String> pickups = ['1', '2', '3']; // Pickup IDs
  final List<String> statusOptions = ['0', '1']; // 0 = inactive, 1 = active

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _rulesService = RulesService(_authService);
    _populateFormData();
  }

  void _populateFormData() {
    // Populate form fields with existing rule data
    ruleTitleController.text = widget.ruleData['rule_title'] ?? '';
    serviceCodeController.text = widget.ruleData['service_code'] ?? '';
    selectedCourierId = widget.ruleData['courier_id']?.toString();
    selectedCustomerCourierId = widget.ruleData['customer_courier_id']?.toString();
    selectedPickupId = widget.ruleData['pickup_id']?.toString();
    selectedStatus = widget.ruleData['status']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      extendBody: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 22),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Rule',
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Rule ID (read-only)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Rule ID: ',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.ruleData['id']?.toString() ?? 'N/A',
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Rule Title
              TextFormField(
                controller: ruleTitleController,
                decoration: _inputDecoration('Rule Title'),
                validator: (val) => val == null || val.isEmpty ? 'Enter rule title' : null,
              ),
              const SizedBox(height: 16),
              
              // Courier ID
              _dropdown('Courier ID', couriers, selectedCourierId, (val) => setState(() => selectedCourierId = val)),
              const SizedBox(height: 16),
              
              // Customer Courier ID
              _dropdown('Customer Courier ID', customerCouriers, selectedCustomerCourierId, (val) => setState(() => selectedCustomerCourierId = val)),
              const SizedBox(height: 16),
              
              // Pickup ID
              _dropdown('Pickup ID', pickups, selectedPickupId, (val) => setState(() => selectedPickupId = val)),
              const SizedBox(height: 16),
              
              // Service Code
              TextFormField(
                controller: serviceCodeController,
                decoration: _inputDecoration('Service Code'),
                validator: (val) => val == null || val.isEmpty ? 'Enter service code' : null,
              ),
              const SizedBox(height: 16),
              
              // Status
              _dropdown('Status', statusOptions, selectedStatus, (val) => setState(() => selectedStatus = val)),
              const SizedBox(height: 24),
              
              // Update Button
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
                  onPressed: isLoading ? null : _updateRule,
                  child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Update Rule', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomBar(selectedIndex: 2),
    );
  }

  Widget _dropdown(
    String label, 
    List<String> items, 
    String? value, 
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label),
      items: items.map((e) => DropdownMenuItem(
        value: e, 
        child: Text(e)
      )).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select $label' : null,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
      dropdownColor: Colors.white,
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w400,
        fontSize: 15,
        color: Colors.black,
      ),
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

  Future<void> _updateRule() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      
      try {
        final ruleId = int.tryParse(widget.ruleData['id']?.toString() ?? '') ?? 0;
        if (ruleId == 0) {
          customSnackBar('Error', 'Invalid rule ID');
          return;
        }

        final success = await _rulesService.updateRule(
          ruleId: ruleId,
          ruleTitle: ruleTitleController.text.trim(),
          courierId: int.tryParse(selectedCourierId ?? '1') ?? 1,
          customerCourierId: int.tryParse(selectedCustomerCourierId ?? '55') ?? 55,
          pickupId: int.tryParse(selectedPickupId ?? '1') ?? 1,
          serviceCode: serviceCodeController.text.trim(),
          status: int.tryParse(selectedStatus ?? '1') ?? 1,
        );
        
        if (success) {
          customSnackBar('Success', 'Rule updated successfully!');
          Get.back(); // Navigate back to rules list
        } else {
          customSnackBar('Error', _rulesService.errorMessage.value);
        }
      } catch (e) {
        customSnackBar('Error', 'Failed to update rule: ${e.toString()}');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
} 