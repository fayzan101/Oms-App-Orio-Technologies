import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dashboard_screen.dart';
import 'order_list_screen.dart';
import 'report.dart' as report;
import 'change_password_screen.dart';
import '../widgets/custom_nav_bar.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://oms.getorio.com/api/profile',
        data: {
          "acno": "OR-00009",
          "userid": 38,
          "customer_id": 38
        },
      );
      if (response.data['status'] == 1 && response.data['payload'] is List && response.data['payload'].isNotEmpty) {
        setState(() {
          profileData = response.data['payload'][0];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'No profile data found.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load profile.';
        isLoading = false;
      });
    }
  }

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
          'Profile',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _profileField('First Name', profileData?['first_name'] ?? ''),
                      _profileField('Last Name', profileData?['last_name'] ?? ''),
                      _profileField('Email', profileData?['email'] ?? ''),
                      _profileField('Phone No', profileData?['phone'] ?? ''),
                      _profileField('Account No', profileData?['acno'] ?? ''),
                      _profileField('Address', profileData?['address'] ?? ''),
                      _profileField('CNIC', profileData?['cnic'] ?? ''),
                      _profileField('CNIC Expiry Date', profileData?['cnic_expiry'] ?? ''),
                      _profileField('Business Name', profileData?['business_name'] ?? ''),
                      _profileField('Business Address', profileData?['business_address'] ?? ''),
                      _profileField('NTN', profileData?['ntn'] ?? ''),
                      // Bank Name Dropdown
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: null,
                          decoration: const InputDecoration(
                            hintText: 'Bank Name',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          items: [
                            'Bank Alfalah',
                            'HBL',
                            'UBL',
                            'MCB',
                            'Meezan',
                            'Other',
                          ].map((bank) => DropdownMenuItem(
                                value: bank,
                                child: Text(bank),
                              )).toList(),
                          onChanged: (value) {},
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      _profileField('Account Title', profileData?['account_title'] ?? ''),
                      _profileField('Account Number', profileData?['account_number'] ?? ''),
                      _profileField('IBAN Number', profileData?['iban'] ?? ''),
                      // Upload CNIC Image
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.cloud_upload_outlined, color: Color(0xFF007AFF), size: 36),
                                  SizedBox(height: 8),
                                  Text('Upload CNIC Image', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF007AFF))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Get.to(() => const ChangePasswordScreen());
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFB0B0B0), width: 1.5),
                                backgroundColor: const Color(0xFFF5F5F7),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Change Password', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF007AFF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: const Text('Updated', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 3,
        onTabSelected: (index) {
          if (index == 0) Get.offAllNamed('/dashboard');
          if (index == 1) Get.offAllNamed('/order-list');
          if (index == 2) Get.offAllNamed('/reports');
          if (index == 3) Get.offAllNamed('/menu');
        },
      ),
    );
  }
}

Widget _profileField(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          enabled: false,
          controller: TextEditingController(text: value),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
    ],
  );
} 