import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/courier_account.dart';
import '../services/courier_service.dart';
import '../utils/Layout/app_bottom_bar.dart';
import '../utils/custom_snackbar.dart';
import 'courier_companies_screen.dart';

class AddCourierCompanyScreen extends StatefulWidget {
  final CourierAccount? courierAccount;
  final bool isEdit;
  const AddCourierCompanyScreen({Key? key, this.courierAccount, this.isEdit = false}) : super(key: key);

  @override
  State<AddCourierCompanyScreen> createState() => _AddCourierCompanyScreenState();
}

class _AddCourierCompanyScreenState extends State<AddCourierCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCourier;
  String? selectedStatus;
  bool isDefault = false;
  bool obscurePassword = true;
  bool isLoadingCouriers = true;

  final TextEditingController accountTitleController = TextEditingController();
  final TextEditingController accountNoController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();

  List<Map<String, dynamic>> couriers = [];
  final List<String> statuses = ['Active', 'Inactive'];
  final CourierService _courierService = CourierService();

  @override
  void initState() {
    super.initState();
    _loadCouriers();
  }

  Future<void> _loadCouriers() async {
    try {
      final couriersData = await _courierService.getCouriers('OR-00009');
      setState(() {
        couriers = couriersData;
        isLoadingCouriers = false;
      });
      
      // If editing, populate form after couriers are loaded
      if (widget.courierAccount != null) {
        _populateFormForEdit();
      }
    } catch (e) {
      setState(() {
        isLoadingCouriers = false;
      });
      // Show error snackbar
      customSnackBar('Error', 'Failed to load couriers: ${e.toString()}');
    }
  }

  void _populateFormForEdit() {
    final c = widget.courierAccount!;
    
    // Find the courier in the loaded list
    final courierData = couriers.firstWhere(
      (courier) => courier['id'].toString() == c.courierId,
      orElse: () => couriers.isNotEmpty ? couriers.first : {},
    );
    
    if (courierData.isNotEmpty) {
      selectedCourier = courierData['name'] ?? courierData['courier_name'] ?? '';
    }
    
    accountTitleController.text = c.accountTitle;
    accountNoController.text = c.courierAcno;
    userController.text = c.courierUser;
    passwordController.text = c.courierPassword;
    apiKeyController.text = c.courierApikey;
    selectedStatus = c.status.toLowerCase() == 'active' ? 'Active' : 'Inactive';
    isDefault = c.isDefault == '1';
  }

  void _showCourierSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CourierSearchDialog(
          couriers: couriers,
          selectedCourier: selectedCourier,
          onCourierSelected: (courierName) {
            setState(() {
              selectedCourier = courierName;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.isEdit ? 'Edit Courier Companies' : 'Add Courier Companies',
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 16),
                isLoadingCouriers
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
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
                            Text('Loading couriers...', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFF7F8FA),
                        ),
                        child: InkWell(
                          onTap: () => _showCourierSearchDialog(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedCourier ?? 'Select Courier',
                                    style: TextStyle(
                                      color: selectedCourier != null ? Colors.black : Colors.grey,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: accountTitleController,
                  decoration: _inputDecoration('Account Title'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter account title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: accountNoController,
                  decoration: _inputDecoration('Account No'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter account no' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: userController,
                  decoration: _inputDecoration('User'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter user' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: _inputDecoration('Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: apiKeyController,
                  decoration: _inputDecoration('API Key'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: _inputDecoration('Select Status'),
                  items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => selectedStatus = val),
                  validator: (val) => val == null ? 'Please select status' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Default Courier', style: TextStyle(fontSize: 16)),
                    Switch(
                      value: isDefault,
                      onChanged: (val) => setState(() => isDefault = val),
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
                    onPressed: () async {
                      // Validate courier selection
                      if (selectedCourier == null) {
                        customSnackBar('Error', 'Please select a courier');
                        return;
                      }
                      
                      if (_formKey.currentState!.validate()) {
                        if (widget.isEdit) {
                          await _updateCourier();
                        } else {
                          await _storeCourier();
                        }
                      }
                    },
                    child: Text(widget.isEdit ? 'Update' : 'Save', style: const TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A2A3A),
        onPressed: () {},
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: const AppBottomBar(selectedIndex: 3),
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

  Future<void> _updateCourier() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Get courier ID based on selected courier name from dynamic data
      String courierId;
      final selectedCourierData = couriers.firstWhere(
        (courier) => (courier['name'] ?? courier['courier_name'] ?? '') == selectedCourier,
        orElse: () => {},
      );
      
      if (selectedCourierData.isNotEmpty) {
        courierId = selectedCourierData['id'].toString();
      } else {
        // Fallback to original courier_id if not found
        courierId = widget.courierAccount!.courierId;
      }
      
      // Call the update API
      final success = await _courierService.updateCourier(
        acno: widget.courierAccount!.acno,
        userId: 38, // This should come from user session/context
        id: widget.courierAccount!.id,
        courierId: courierId,
        accountTitle: accountTitleController.text,
        accountNo: accountNoController.text,
        accountUser: userController.text,
        accountPassword: passwordController.text,
        apikey: apiKeyController.text,
        status: selectedStatus == 'Active' ? '1' : '0',
        isDefault: isDefault ? '1' : '0',
      );
      
      // Hide loading indicator
      Navigator.of(context).pop();

      if (success) {
        // Show success snackbar
        customSnackBar('Success', 'Courier updated successfully');
        
        // Navigate back to courier companies screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
      
      // Show error snackbar
      customSnackBar('Error', 'Failed to update courier: ${e.toString()}');
    }
  }

  Future<void> _storeCourier() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Get courier ID based on selected courier name from dynamic data
      String courierId;
      final selectedCourierData = couriers.firstWhere(
        (courier) => (courier['name'] ?? courier['courier_name'] ?? '') == selectedCourier,
        orElse: () => {},
      );
      
      if (selectedCourierData.isNotEmpty) {
        courierId = selectedCourierData['id'].toString();
      } else {
        // Fallback to first courier if not found
        courierId = couriers.isNotEmpty ? couriers.first['id'].toString() : '1';
      }
      
      // Call the store API
      final success = await _courierService.storeCourier(
        acno: 'OR-00009', // This should come from user session/context
        userId: 38, // This should come from user session/context
        courierId: courierId,
        accountTitle: accountTitleController.text,
        accountNo: accountNoController.text,
        accountUser: userController.text,
        accountPassword: passwordController.text,
        apikey: apiKeyController.text,
        status: selectedStatus == 'Active' ? '1' : '0',
        isDefault: isDefault ? '1' : '0',
      );
      
      // Hide loading indicator
      Navigator.of(context).pop();

      if (success) {
        // Show success snackbar
        customSnackBar('Success', 'Courier added successfully');
        
        // Navigate back to courier companies screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
      
      // Show error snackbar
      customSnackBar('Error', 'Failed to add courier: ${e.toString()}');
    }
  }

  Widget _navBarItem(IconData icon, String label, String route) {
    return InkWell(
      onTap: () {
        Get.offAllNamed(route);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: const Color(0xFF0A2A3A)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF0A2A3A))),
        ],
      ),
    );
  }
}

class _CourierUpdateSuccessBottomSheet extends StatelessWidget {
  const _CourierUpdateSuccessBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0FF),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(32),
              child: const Icon(Icons.check_rounded, color: Color(0xFF007AFF), size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Success!',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Courier details updated successfully',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Color(0xFF8E8E93)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => CourierCompaniesScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Ok', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourierAddSuccessBottomSheet extends StatelessWidget {
  const _CourierAddSuccessBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0FF),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(32),
              child: const Icon(Icons.check_rounded, color: Color(0xFF007AFF), size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Success!',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Courier details added successfully',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Color(0xFF8E8E93)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => CourierCompaniesScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Ok', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 

class _CourierSearchDialog extends StatefulWidget {
  final List<Map<String, dynamic>> couriers;
  final String? selectedCourier;
  final Function(String) onCourierSelected;

  const _CourierSearchDialog({
    Key? key,
    required this.couriers,
    required this.selectedCourier,
    required this.onCourierSelected,
  }) : super(key: key);

  @override
  State<_CourierSearchDialog> createState() => _CourierSearchDialogState();
}

class _CourierSearchDialogState extends State<_CourierSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCouriers = [];

  @override
  void initState() {
    super.initState();
    _filteredCouriers = widget.couriers;
  }

  void _filterCouriers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCouriers = widget.couriers;
      } else {
        _filteredCouriers = widget.couriers.where((courier) {
          final courierName = (courier['name'] ?? courier['courier_name'] ?? '').toString().toLowerCase();
          return courierName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Courier',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search couriers...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _filterCouriers,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredCouriers.isEmpty
                  ? const Center(
                      child: Text(
                        'No couriers found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredCouriers.length,
                      itemBuilder: (context, index) {
                        final courier = _filteredCouriers[index];
                        final courierName = courier['name'] ?? courier['courier_name'] ?? 'Unknown';
                        final isSelected = courierName == widget.selectedCourier;

                        return ListTile(
                          title: Text(courierName),
                          leading: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF007AFF))
                              : const Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey),
                          onTap: () => widget.onCourierSelected(courierName),
                          tileColor: isSelected ? const Color(0xFFE6F0FF) : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 