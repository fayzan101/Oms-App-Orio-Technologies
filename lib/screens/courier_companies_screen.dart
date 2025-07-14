import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/courier_account.dart';
import '../services/courier_service.dart';
import '../services/auth_service.dart';
import 'add_courier_company_screen.dart'; // Added import for AddCourierCompanyScreen
import '../utils/Layout/app_bottom_bar.dart';
import '../utils/custom_snackbar.dart';
import 'search_screen.dart';
import '../widgets/courier_logo_widget.dart';
import 'dart:convert';

class CourierCompaniesScreen extends StatefulWidget {
  CourierCompaniesScreen({Key? key}) : super(key: key);

  @override
  State<CourierCompaniesScreen> createState() => _CourierCompaniesScreenState();
}

class _CourierCompaniesScreenState extends State<CourierCompaniesScreen> {
  final CourierService _courierService = CourierService();
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();
  List<CourierAccount> _allCompanies = [];
  List<CourierAccount> _filteredCompanies = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchCompanies();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndFetchCompanies() async {
    // Load user data if not already loaded
    if (_authService.currentUser.value == null) {
      await _authService.loadUserData();
    }
    await _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        setState(() {
          _error = 'User not logged in';
          _loading = false;
        });
        return;
      }

      final companies = await _courierService.getCourierAccounts(acno);
      setState(() {
        _allCompanies = companies;
        _filteredCompanies = companies;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCompanies = _allCompanies.where((company) {
        return company.accountTitle.toLowerCase().contains(query) ||
               company.courierAcno.toLowerCase().contains(query) ||
               company.courierName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Couriers Companies',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Courier Companies: ${_filteredCompanies.length.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed('/add-courier');
                            },
                            child: const Text(
                              'Add Courier',
                              style: TextStyle(
                                color: Color(0xFF007AFF),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by title, account no, or courier name',
                          prefixIcon: Icon(Icons.search_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _filteredCompanies.isEmpty
                          ? const Center(child: Text('No courier companies found.'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              itemCount: _filteredCompanies.length,
                              itemBuilder: (context, index) {
                                final company = _filteredCompanies[index];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  elevation: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _infoRow('S.No', (index + 1).toString().padLeft(2, '0')),
                                        _infoRow('Account Title', company.accountTitle),
                                        _infoRow('Account No', company.courierAcno),
                                        // Show the label 'Courier' and the logo under the account number, both left-aligned, with spacing
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 0),
                                                child: const Text('Courier', style: TextStyle(fontWeight: FontWeight.w500)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 60),
                                                child: _courierLogoOnly(company.courierName),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _infoRow('Default', company.isDefault == '1' ? 'Y' : 'N'),
                                        _infoRow('Activate', company.status.capitalizeFirst ?? ''),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Text('Actions', style: TextStyle(fontWeight: FontWeight.w500)),
                                            const SizedBox(width: 16),
                                            IconButton(
                                              icon: const Icon(Icons.edit_rounded, color: Color(0xFF007AFF)),
                                              onPressed: () {
                                                Get.to(() => AddCourierCompanyScreen(courierAccount: company, isEdit: true));
                                              },
                                            ),
                                            const Text('Edit', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete_rounded, color: Color(0xFF007AFF)),
                                              onPressed: () {
                                                _showDeleteConfirmation(context, () {
                                                  _deleteCourier(context, company);
                                                });
                                              },
                                            ),
                                            const Text('Delete', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF0A2A3A),
              onPressed: () {
                Get.toNamed('/add-courier');
              },
              child: const Icon(Icons.edit_rounded, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: const AppBottomBar(selectedIndex: 3),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110, // fixed width for label for alignment
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500), textAlign: TextAlign.left),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.normal), textAlign: TextAlign.left)),
        ],
      ),
    );
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

  void _showDeleteConfirmation(BuildContext context, VoidCallback onConfirm) {
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
                  child: const Icon(Icons.delete_rounded, color: Color(0xFF007AFF), size: 64),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Are you Sure',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You want to delete this courier',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Color(0xFF8E8E93)),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F2F7),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('No', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteCourier(BuildContext context, CourierAccount company) async {
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

      // Call the delete API
      final success = await _courierService.deleteCourier(company.id, company.acno);
      
      // Hide loading indicator
      Navigator.of(context).pop();

      if (success) {
        // Show success snackbar
        customSnackBar('Success', 'Courier deleted successfully');
        
        // Refresh the page by rebuilding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => CourierCompaniesScreen()),
        );
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
      
      // Show error snackbar
      customSnackBar('Error', 'Failed to delete courier: ${e.toString()}');
    }
  }

  void _showDeleteSuccess(BuildContext context) {
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
                  child: const Icon(Icons.check_rounded, color: Color(0xFF007AFF), size: 64),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Success!',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You have successfully deleted courier',
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

  Widget _courierLogoOnly(String courierName) {
    final encodedName = Uri.encodeComponent(courierName.trim());
    final logoUrl = 'https://oms.getorio.com/assets/img/shipping-icons/$encodedName.svg';
    return Padding(
      padding: const EdgeInsets.only(bottom: 2), // slight adjustment for baseline
      child: CourierLogoWidget(
        logoUrl: logoUrl,
        width: 48,
        height: 24,
        fit: BoxFit.contain,
        // fallbackWidget: Icon(Icons.local_shipping, color: Colors.grey[400]), // Optionally remove for debugging
      ),
    );
  }
} 