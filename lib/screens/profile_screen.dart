import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart';
import 'order_list_screen.dart';
import 'report.dart' as report;
import 'change_password_screen.dart';
import '../utils/Layout/app_bottom_bar.dart';
import '../services/auth_service.dart';
import '../services/statement_service.dart';
import '../models/user_model.dart';
import '../utils/custom_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  bool isEditing = false;
  bool isUpdating = false;
  String? error;
  bool _dialogShown = false;
  final AuthService _authService = Get.find<AuthService>();

  // Controllers for editable fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController cnicExpiryController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessAddressController = TextEditingController();
  final TextEditingController ntnController = TextEditingController();
  final TextEditingController accountTitleController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ibanController = TextEditingController();

  String? selectedBank;
  List<String> banks = [];
  bool _isLoadingBanks = false;
  String? _bankError;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    _fetchBanks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = Get.arguments;
    if (!_dialogShown && args != null && args['showSuccess'] == true) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showProfileUpdateSuccessDialog(context);
      });
    }
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
          _populateControllers();
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

  void _populateControllers() {
    if (profileData != null) {
      firstNameController.text = profileData!['first_name'] ?? '';
      lastNameController.text = profileData!['last_name'] ?? '';
      emailController.text = profileData!['email'] ?? '';
      phoneController.text = profileData!['phone'] ?? '';
      addressController.text = profileData!['address'] ?? '';
      cnicController.text = profileData!['cnic'] ?? '';
      cnicExpiryController.text = profileData!['cnic_expiry'] ?? '';
      businessNameController.text = profileData!['business_name'] ?? '';
      businessAddressController.text = profileData!['business_address'] ?? '';
      ntnController.text = profileData!['ntn'] ?? '';
      accountTitleController.text = profileData!['account_title'] ?? '';
      accountNumberController.text = profileData!['account_number'] ?? '';
      ibanController.text = profileData!['iban'] ?? '';
      selectedBank = profileData!['bank_name'] ?? (banks.isNotEmpty ? banks.first : null);
    }
  }

  Future<void> _fetchBanks() async {
    setState(() {
      _isLoadingBanks = true;
      _bankError = null;
    });
    try {
      final service = StatementService();
      final bankData = await service.fetchBanks(1); // country_id = 1 for Pakistan
      print('Profile screen received bank data: $bankData');
      print('Bank data length: ${bankData.length}');
      
      final bankNames = bankData.map((e) => e['name']?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      print('Extracted bank names: $bankNames');
      print('Bank names length: ${bankNames.length}');
      
      setState(() {
        banks = bankNames;
        _isLoadingBanks = false;
      });
      print('Banks list updated: $banks');
    } catch (e) {
      print('Error fetching banks: $e');
      setState(() {
        _bankError = 'Failed to load banks: $e';
        _isLoadingBanks = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      isUpdating = true;
    });

    try {
      final profile = CustomerProfile(
        customerId: '38',
        acno: 'OR-00009',
        email: emailController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        cnic: cnicController.text.trim(),
        cnicExpiry: cnicExpiryController.text.trim(),
        cnicImage: profileData?['cnic_image'] ?? '',
        hostingReceipt: profileData?['hosting_receipt'] ?? '',
        businessName: businessNameController.text.trim(),
        businessAddress: businessAddressController.text.trim(),
        ntn: ntnController.text.trim(),
        accountTitle: accountTitleController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        iban: ibanController.text.trim(),
        bankId: 31, // Default bank ID
      );

      final success = await _authService.updateCustomerProfile(profile);

      if (success) {
        customSnackBar('Success', 'Profile updated successfully!');
        
        setState(() {
          isEditing = false;
        });
        
        // Refresh profile data
        await fetchProfile();
      } else {
        customSnackBar('Error', _authService.errorMessage.value);
      }
    } catch (e) {
      customSnackBar('Error', 'Failed to update profile: ${e.toString()}');
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
        actions: [
          if (!isLoading && error == null)
            IconButton(
              icon: Icon(
                isEditing ? Icons.close : Icons.edit,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  if (isEditing) {
                    // Cancel editing - restore original values
                    _populateControllers();
                  }
                  isEditing = !isEditing;
                });
              },
            ),
        ],
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
                      _profileField('First Name', firstNameController, isEditing),
                      _profileField('Last Name', lastNameController, isEditing),
                      _profileField('Email', emailController, isEditing),
                      _profileField('Phone No', phoneController, isEditing),
                      _profileField('Account No', TextEditingController(text: profileData?['acno'] ?? ''), false),
                      _profileField('Address', addressController, isEditing),
                      _profileField('CNIC', cnicController, isEditing),
                      _profileField('CNIC Expiry Date', cnicExpiryController, isEditing),
                      _profileField('Business Name', businessNameController, isEditing),
                      _profileField('Business Address', businessAddressController, isEditing),
                      _profileField('NTN', ntnController, isEditing),
                      // Bank Name Dropdown
                      if (isEditing) _bankDropdownSection(),
                      _profileField('Account Title', accountTitleController, isEditing),
                      _profileField('Account Number', accountNumberController, isEditing),
                      _profileField('IBAN Number', ibanController, isEditing),
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
                              onPressed: isEditing ? (isUpdating ? null : _updateProfile) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isEditing ? Color(0xFF007AFF) : Color(0xFFB0B0B0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: isUpdating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    isEditing ? 'Update Profile' : 'Updated',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro Display',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
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
      bottomNavigationBar: const AppBottomBar(currentTab: 3),
    );
  }

  Widget _bankDropdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Bank Name',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
        if (_isLoadingBanks)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (_bankError != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _bankError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          )
        else
          _bankDropdown(),
      ],
    );
  }

  Widget _bankDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedBank,
        decoration: const InputDecoration(
          hintText: 'Select Bank',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          isDense: true,
        ),
        items: banks.map((bank) => DropdownMenuItem(
          value: bank,
          child: Text(
            bank,
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        )).toList(),
        onChanged: banks.isNotEmpty ? (value) {
          setState(() {
            selectedBank = value;
          });
        } : null,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
        style: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: Colors.black,
        ),
        dropdownColor: const Color(0xFFF5F5F7),
        isExpanded: true,
      ),
    );
  }
}

void _showProfileUpdateSuccessDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
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
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0FF),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(32),
                child: const Icon(Icons.check, color: Color(0xFF007AFF), size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                'Success!',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black),
              ),
              const SizedBox(height: 8),
              const Text(
                'Profile updated successfully',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
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
    },
  );
}

Widget _profileField(String label, TextEditingController controller, bool isEditing) {
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
          enabled: isEditing,
          controller: controller,
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