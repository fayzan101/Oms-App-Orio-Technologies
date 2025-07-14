import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'orio_rule_detail_screen.dart';
import '../utils/Layout/app_bottom_bar.dart';
import '../services/auth_service.dart';
import '../services/rules_service.dart';
import '../utils/custom_snackbar.dart';

class CreateRuleScreen extends StatefulWidget {
  const CreateRuleScreen({Key? key}) : super(key: key);

  @override
  State<CreateRuleScreen> createState() => _CreateRuleScreenState();
}

class _CreateRuleScreenState extends State<CreateRuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ruleTitleController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();
  late final RulesService _rulesService;
  
  // Form fields matching the API requirements
  String? selectedStatusIds;
  String? weightType;
  final TextEditingController weightValueController = TextEditingController();
  String? paymentMethodId;
  String? customerCitylistId;
  String? orderType;
  final TextEditingController orderValueController = TextEditingController();
  final TextEditingController platformValueController = TextEditingController();
  String? platformType;
  String? selectedAddressKeyword;
  String? isContain;
  String? courierId;
  String? customerCourierId;
  String? pickupId;
  final TextEditingController serviceCodeController = TextEditingController();

  // Dropdown options
  final List<String> statusOptions = ['1', '2', '3']; // Status IDs
  final List<String> weightTypes = ['>=', '<=', '=='];
  final List<String> paymentMethods = ['1', '2', '3']; // Payment method IDs
  final List<String> cities = ['27', '28', '29']; // City IDs
  final List<String> orderTypes = ['>=', '<=', '=='];
  final List<String> platformTypes = ['OMS', 'Shopify', 'WooCommerce'];
  final List<String> containOptions = ['0', '1']; // 0 = not contain, 1 = contain
  final List<String> couriers = ['1', '2', '3']; // Courier IDs
  final List<String> customerCouriers = ['55', '56', '57']; // Customer courier IDs
  final List<String> pickups = ['1', '2', '3']; // Pickup IDs

  // Dynamic keywords from API
  List<Map<String, dynamic>> keywords = [];
  bool isLoadingKeywords = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _rulesService = RulesService(_authService);
    _loadUserDataAndFetchKeywords();
  }

  Future<void> _loadUserDataAndFetchKeywords() async {
    // Load user data if not already loaded
    if (_authService.currentUser.value == null) {
      await _authService.loadUserData();
    }
    await _fetchKeywords();
  }

  Future<void> _fetchKeywords() async {
    setState(() {
      isLoadingKeywords = true;
    });
    
    try {
      final keywordsData = await _rulesService.getKeywords();
      setState(() {
        keywords = keywordsData;
        isLoadingKeywords = false;
      });
    } catch (e) {
      setState(() {
        isLoadingKeywords = false;
      });
      customSnackBar('Error', 'Failed to load keywords: ${e.toString()}');
    }
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
          'Create Rules',
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
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              
              // Status IDs dropdown
              _dropdown('Status IDs', statusOptions, selectedStatusIds, (val) => setState(() => selectedStatusIds = val)),
              const SizedBox(height: 16),
              
              // Weight Type and Value
                Row(
                  children: [
                    Expanded(
                    flex: 2,
                    child: _dropdown('Weight Type', weightTypes, weightType, (val) => setState(() => weightType = val)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: weightValueController,
                      decoration: _inputDecoration('Weight Value'),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Enter weight value' : null,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Payment Method
              _dropdown('Payment Method ID', paymentMethods, paymentMethodId, (val) => setState(() => paymentMethodId = val)),
              const SizedBox(height: 16),
              
              // Customer City List
              _dropdown('Customer City List ID', cities, customerCitylistId, (val) => setState(() => customerCitylistId = val)),
              const SizedBox(height: 16),
              
              // Order Type and Value
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _dropdown('Order Type', orderTypes, orderType, (val) => setState(() => orderType = val)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: orderValueController,
                      decoration: _inputDecoration('Order Value'),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Enter order value' : null,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              
              // Platform Value and Type
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: platformValueController,
                      decoration: _inputDecoration('Platform Value'),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Enter platform value' : null,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _dropdown('Platform Type', platformTypes, platformType, (val) => setState(() => platformType = val)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Address Keywords and Is Contain
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: isLoadingKeywords
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFF7F8FA),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Loading keywords...', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : keywords.isEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFFF7F8FA),
                            ),
                            child: const Text('No keywords available', style: TextStyle(color: Colors.grey)),
                          )
                        : _dropdown(
                            'Address Keywords',
                            keywords.map((k) => k['id'].toString()).toList(),
                            selectedAddressKeyword,
                            (val) => setState(() => selectedAddressKeyword = val),
                            displayText: (value) {
                              try {
                                final keyword = keywords.firstWhere(
                                  (k) => k['id'].toString() == value,
                                  orElse: () => {'title': 'Select Keyword'},
                                );
                                return keyword['title']?.toString() ?? 'Select Keyword';
                              } catch (e) {
                                print('Error in displayText: $e');
                                return 'Select Keyword';
                              }
                            },
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _dropdown('Is Contain', containOptions, isContain, (val) => setState(() => isContain = val)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Courier ID and Customer Courier ID
              Row(
                children: [
                  Expanded(
                    child: _dropdown('Courier ID', couriers, courierId, (val) => setState(() => courierId = val)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dropdown('Customer Courier ID', customerCouriers, customerCourierId, (val) => setState(() => customerCourierId = val)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Pickup ID and Service Code
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _dropdown('Pickup ID', pickups, pickupId, (val) => setState(() => pickupId = val)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: serviceCodeController,
                      decoration: _inputDecoration('Service Code'),
                      validator: (val) => val == null || val.isEmpty ? 'Enter service code' : null,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
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
                  onPressed: isLoading ? null : _createRule,
                  child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Create Rule', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A253B),
        onPressed: () {},
        child: const Icon(Icons.edit_rounded, color: Colors.white),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: const AppBottomBar(selectedIndex: 2),
    );
  }

  Widget _dropdown(
    String label, 
    List<String> items, 
    String? value, 
    ValueChanged<String?> onChanged, {
    String Function(String)? displayText,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label),
      items: items.map((e) => DropdownMenuItem(
        value: e, 
        child: Text(displayText != null ? displayText(e) : e)
      )).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Please select $label' : null,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
      dropdownColor: Colors.white,
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w400,
        fontSize: 13,
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
      labelStyle: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w400,
        fontSize: 13,
        color: Colors.black54,
      ),
    );
  }

  Future<void> _createRule() async {
    if (_formKey.currentState!.validate()) {
                          setState(() {
        isLoading = true;
      });
      
      try {
        final success = await _rulesService.createRule(
          title: ruleTitleController.text,
          statusIds: selectedStatusIds,
          weightType: weightType,
          weightValue: weightValueController.text,
          paymentMethodId: paymentMethodId,
          customerCitylistId: customerCitylistId,
          orderType: orderType,
          orderValue: orderValueController.text,
          platformType: platformType,
          platformValue: platformValueController.text,
          addressKeywords: selectedAddressKeyword ?? '',
          isContain: isContain,
          courierId: courierId,
          customerCourierId: customerCourierId,
          pickupId: pickupId,
          serviceCode: serviceCodeController.text,
        );
        
        if (success) {
          customSnackBar('Success', 'Rule created successfully!');
          Get.back(); // Navigate back to previous screen
        } else {
          customSnackBar('Error', _rulesService.errorMessage.value);
        }
      } catch (e) {
        customSnackBar('Error', 'Failed to create rule: ${e.toString()}');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
} 