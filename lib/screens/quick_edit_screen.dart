import 'package:flutter/material.dart';
import 'order_list_screen.dart';
import '../utils/Layout/app_bottom_bar.dart';
import 'package:dio/dio.dart';
import '../utils/custom_snackbar.dart';

class QuickEditScreen extends StatefulWidget {
  const QuickEditScreen({Key? key}) : super(key: key);

  @override
  State<QuickEditScreen> createState() => _QuickEditScreenState();
}

class _QuickEditScreenState extends State<QuickEditScreen> {
  final TextEditingController nameController = TextEditingController(text: 'Zara Amir');
  final TextEditingController emailController = TextEditingController(text: 'zara675@gmail.com');
  final TextEditingController contactController = TextEditingController(text: '03322448731');
  final TextEditingController addressController = TextEditingController(text: 'Saho Trader`s , Jhang Sadar, Jhang');
  final TextEditingController address2Controller = TextEditingController(text: 'Saho Trader`s , Jhang Sadar, Jhang');
  final TextEditingController weightController = TextEditingController(text: '2.50');
  final TextEditingController tagController = TextEditingController(text: 'Order Tag');
  String selectedCity = 'Karachi';
  bool _isLoading = false;

  Future<void> _submitQuickEdit() async {
    setState(() { _isLoading = true; });
    try {
      // TODO: Replace with actual dynamic acno and id retrieval
      final acno = 'OR-00009'; // Replace with dynamic value
      final id = 25184; // Replace with dynamic value
      final dio = Dio();
      final response = await dio.post(
        'https://oms.getorio.com/api/order/quick_edit',
        data: {
          "acno": acno,
          "id": id,
          "consignee_name": nameController.text.trim(),
          "consignee_email": emailController.text.trim(),
          "consignee_no": contactController.text.trim(),
          "consignee_address": addressController.text.trim(),
          "shipping_charges": 0, // You may want to make this dynamic
          "destination_city_id": 655, // You may want to make this dynamic
          "weight": double.tryParse(weightController.text.trim()) ?? 1,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer QoVDWMtOU9sUzi543rtAVcaeAiEoDH/lQMmuxj4JbjO54gmraIr8QwAloW2F8KEM4PEU9zibMkdCp5RMU3LFqg==',
          },
        ),
      );
      if (response.statusCode == 200 && (response.data['status'] == 1 || response.data['success'] == true)) {
        // Navigate to OrderListScreen and show snackbar there
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OrderListScreen(
              snackbarMessage: 'Consignment detail updated',
            ),
          ),
        );
      } else {
        customSnackBar('Error', response.data['message'] ?? 'Failed to update consignment');
      }
    } catch (e) {
      customSnackBar('Error', 'Failed to update consignment: ${e.toString()}');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Quick Edit',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView(
          children: [
            _inputField(nameController),
            const SizedBox(height: 12),
            _inputField(emailController),
            const SizedBox(height: 12),
            _inputField(contactController),
            const SizedBox(height: 12),
            _inputField(addressController),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCity,
              items: ['Karachi', 'Lahore', 'Islamabad']
                  .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                  .toList(),
              onChanged: (val) => setState(() => selectedCity = val ?? 'Karachi'),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F5F7),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
            ),
            const SizedBox(height: 12),
            _inputField(weightController),
            const SizedBox(height: 12),
            _inputField(tagController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitQuickEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Update', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0A253B),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: const AppBottomBar(selectedIndex: 1),
    );
  }

  Widget _inputField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(fontSize: 16, color: Colors.black),
    );
  }
}

class _QuickEditSuccessBottomSheet extends StatelessWidget {
  const _QuickEditSuccessBottomSheet({Key? key}) : super(key: key);

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
              'Consignment detail updated',
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
                    MaterialPageRoute(builder: (_) => OrderListScreen()),
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