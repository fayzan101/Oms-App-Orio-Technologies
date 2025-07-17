import 'package:flutter/material.dart';
import 'order_list_screen.dart';
import '../utils/Layout/app_bottom_bar.dart';
import '../services/statement_service.dart';
import '../services/auth_service.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../services/courier_service.dart';
import '../models/courier_account.dart';
import '../utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

// Blue color constant for theme
const Color kBlue = Color(0xFF007AFF);

class _SearchDialog extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const _SearchDialog({
    Key? key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  late List<String> _filteredOptions;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    if (widget.options.length > 2) {
      _searchController.addListener(() {
        setState(() {
          final query = _searchController.text.toLowerCase();
          _filteredOptions = widget.options.where((option) => option.toLowerCase().contains(query)).toList();
        });
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kBlue)),
            if (widget.options.length > 2) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search_rounded, color: kBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kBlue, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: _filteredOptions.isEmpty
                  ? const Center(child: Text('No options found.', style: TextStyle(color: kBlue)))
                  : ListView.separated(
                      itemCount: _filteredOptions.length,
                      separatorBuilder: (_, __) => Container(
                        height: 1,
                        color: kBlue.withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      itemBuilder: (context, i) {
                        final option = _filteredOptions[i];
                        final isSelected = option == widget.selectedValue;
                        return ListTile(
                          title: Text(option, style: TextStyle(color: isSelected ? kBlue : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          selected: isSelected,
                          selectedTileColor: kBlue.withOpacity(0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onTap: () {
                            widget.onSelected(option);
                            Navigator.of(context).pop();
                          },
                          trailing: isSelected ? const Icon(Icons.check_circle, color: kBlue) : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget SearchableField({
  required BuildContext context,
  required String label,
  required String? value,
  required List<String> options,
  required ValueChanged<String> onSelected,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey[300]!, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.08),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: InkWell(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => _SearchDialog(
            title: label,
            options: options,
            selectedValue: value,
            onSelected: onSelected,
          ),
        );
        if (selected != null) {
          onSelected(selected);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                (value == null || value.isEmpty) ? label : value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: (value == null || value.isEmpty) ? const Color(0xFF6B6B6B) : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
          ],
        ),
      ),
    ),
  );
}

class CreateCnScreen extends StatefulWidget {
  final dynamic order;
  const CreateCnScreen({Key? key, this.order}) : super(key: key);

  @override
  State<CreateCnScreen> createState() => _CreateCnScreenState();
}

class _CreateCnScreenState extends State<CreateCnScreen> {
  String? selectedAccount = 'Select your account';
  String? selectedType = 'Parcel';
  String? selectedFragile = 'Fragile(Yes)';
  String? selectedCourier = 'Blue Cargo';
  String? selectedCity;
  String? selectedInsurance = 'Insurance(Yes)';
  List<String> cityList = [];
  bool _isLoadingCities = false;
  final AuthService _authService = Get.find<AuthService>();
  List<CourierAccount> _accounts = [];
  bool _isLoadingAccounts = false;
  final CourierService _courierService = CourierService();

  // Add state for dropdowns
  String fragileRequire = 'N';
  String insuranceRequire = 'N';
  String parcelType = 'Parcel';
  bool isSubmitting = false;

  // Add state for pickup and city dropdowns
  List<String> pickupOptions = [];
  String? selectedPickup;
  bool _isLoadingPickup = false;
  String? selectedCityDropdown;

  // Add state for service code dropdown
  List<String> serviceCodes = [];
  String? selectedServiceCode;
  bool _isLoadingServiceCodes = false;

  bool _isInitialLoading = true;
  int _loadingCount = 0;

  @override
  void initState() {
    super.initState();
    _startInitialLoad();
  }

  void _startInitialLoad() async {
    setState(() {
      _isInitialLoading = true;
      _loadingCount = 4; // accounts, cities, service codes, pickup locations
    });
    await Future.wait([
      _fetchAccountsWrapper(),
      _fetchCitiesWrapper(),
      _fetchServiceCodesWrapper(),
      _fetchPickupLocationsWrapper(),
    ]);
    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _fetchAccountsWrapper() async {
    await _fetchAccounts();
    setState(() { _loadingCount--; });
  }
  Future<void> _fetchCitiesWrapper() async {
    await _fetchCities();
    setState(() { _loadingCount--; });
  }
  Future<void> _fetchServiceCodesWrapper() async {
    await _fetchServiceCodes();
    setState(() { _loadingCount--; });
  }
  Future<void> _fetchPickupLocationsWrapper() async {
    await _fetchPickupLocations();
    setState(() { _loadingCount--; });
  }

  Future<void> _fetchCities() async {
    setState(() { _isLoadingCities = true; });
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null || acno.isEmpty) {
        setState(() { _isLoadingCities = false; });
        return;
      }
      final cities = await StatementService().fetchCityList(acno);
      setState(() {
        cityList = cities
            .map((c) => (c['name']?.toString() ?? c['city_name']?.toString() ?? ''))
            .where((c) => c.isNotEmpty)
            .toList();
        if (cityList.isNotEmpty && (selectedCityDropdown == null || !cityList.contains(selectedCityDropdown))) {
          selectedCityDropdown = cityList.first;
        }
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() { _isLoadingCities = false; });
    }
  }

  Future<void> _fetchAccounts() async {
    setState(() { _isLoadingAccounts = true; });
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null || acno.isEmpty) {
        setState(() { _isLoadingAccounts = false; });
        return;
      }
      final accounts = await _courierService.getCourierAccounts(acno);
      setState(() {
        _accounts = accounts;
        if (_accounts.isNotEmpty && (selectedAccount == null || !_accounts.any((a) => _accountDropdownValue(a) == selectedAccount))) {
          selectedAccount = _accountDropdownValue(_accounts.first);
        }
        _isLoadingAccounts = false;
      });
    } catch (e) {
      setState(() { _isLoadingAccounts = false; });
    }
  }

  Future<void> _fetchServiceCodes() async {
    setState(() { _isLoadingServiceCodes = true; });
    try {
      final user = _authService.currentUser.value;
      final acno = user?.acno ?? widget.order?['acno'] ?? '';
      final courierId = widget.order?['courier_id']?.toString() ?? '1';
      final customerCourierId = widget.order?['customer_courier_id']?.toString() ?? '55';
      final dio = Dio();
      final response = await dio.post(
        'https://oms.getorio.com/api/order/getServiceCode',
        data: {
          "acno": acno,
          "courier_id": int.tryParse(courierId) ?? 1,
          "customer_courier_id": int.tryParse(customerCourierId) ?? 55,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<String> codes = [];
        if (data is Map && data['service_code'] is List) {
          // Handle list of objects or strings
          final rawList = data['service_code'];
          if (rawList.isNotEmpty && rawList.first is Map && rawList.first.containsKey('service_code')) {
            codes = List<String>.from(rawList.map((e) => e['service_code'].toString()));
          } else {
            codes = List<String>.from(rawList.map((e) => e.toString()));
          }
        } else if (data is Map && data['payload'] is List) {
          final rawList = data['payload'];
          if (rawList.isNotEmpty && rawList.first is Map && rawList.first.containsKey('service_code')) {
            codes = List<String>.from(rawList.map((e) => e['service_code'].toString()));
          } else {
            codes = List<String>.from(rawList.map((e) => e.toString()));
          }
        }
        setState(() {
          serviceCodes = codes;
          selectedServiceCode = codes.isNotEmpty ? codes.first : null;
          _isLoadingServiceCodes = false;
        });
      } else {
        setState(() {
          serviceCodes = [];
          selectedServiceCode = null;
          _isLoadingServiceCodes = false;
        });
      }
    } catch (e) {
      setState(() {
        serviceCodes = [];
        selectedServiceCode = null;
        _isLoadingServiceCodes = false;
      });
    }
  }

  Future<void> _fetchPickupLocations() async {
    setState(() { _isLoadingPickup = true; });
    try {
      final user = _authService.currentUser.value;
      final acno = user?.acno ?? widget.order?['acno'] ?? '';
      final courierId = widget.order?['courier_id']?.toString() ?? '1';
      final customerCourierId = widget.order?['customer_courier_id']?.toString() ?? '55';
      final dio = Dio();
      final response = await dio.post(
        'https://oms.getorio.com/api/pickup/show',
        data: {
          "acno": acno,
          "courier_id": int.tryParse(courierId) ?? 1,
          "customer_courier_id": int.tryParse(customerCourierId) ?? 55,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<String> pickups = [];
        if (data is Map && data['pickuplocation'] is List) {
          pickups = List<String>.from(data['pickuplocation'].map((e) => e['pickuplocation_name'].toString()));
        } else if (data is Map && data['payload'] is List) {
          pickups = List<String>.from(data['payload'].map((e) => e['pickuplocation_name'].toString()));
        }
        setState(() {
          pickupOptions = pickups;
          selectedPickup = pickups.isNotEmpty ? pickups.first : null;
          _isLoadingPickup = false;
        });
      } else {
        setState(() {
          pickupOptions = [];
          selectedPickup = null;
          _isLoadingPickup = false;
        });
      }
    } catch (e) {
      setState(() {
        pickupOptions = [];
        selectedPickup = null;
        _isLoadingPickup = false;
      });
    }
  }

  String _accountDropdownValue(CourierAccount account) {
    return '${account.accountTitle} (${account.courierName})';
  }

  Future<void> _showCitySearchDialog() async {
    if (_isLoadingCities) return;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => _CitySearchDialog(
        cities: cityList,
        initialCity: selectedCityDropdown,
      ),
    );
    if (selected != null) {
      setState(() {
        selectedCityDropdown = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create CN',
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
            SearchableField(
                    context: context,
                    label: 'Select your account',
                    value: selectedAccount,
                    options: [
                      'Select your account',
                      ..._accounts.map((a) => _accountDropdownValue(a)),
                    ],
                    onSelected: (val) => setState(() => selectedAccount = val),
                  ),
            SearchableField(
              context: context,
              label: 'Fragile?',
              value: fragileRequire == 'Y' ? 'Yes' : 'No',
              options: ['Y', 'N'].map((v) => v == 'Y' ? 'Yes' : 'No').toList(),
              onSelected: (val) => setState(() => fragileRequire = val == 'Yes' ? 'Y' : 'N'),
            ),
            SearchableField(
              context: context,
              label: 'Insurance?',
              value: insuranceRequire == 'Y' ? 'Yes' : 'No',
              options: ['Y', 'N'].map((v) => v == 'Y' ? 'Yes' : 'No').toList(),
              onSelected: (val) => setState(() => insuranceRequire = val == 'Yes' ? 'Y' : 'N'),
            ),
            SearchableField(
              context: context,
              label: 'Parcel Type',
              value: parcelType,
              options: ['Parcel', 'Document'],
              onSelected: (val) => setState(() => parcelType = val),
            ),
            SearchableField(
              context: context,
              label: 'Pickup',
              value: selectedPickup,
              options: pickupOptions,
              onSelected: (val) => setState(() => selectedPickup = val),
            ),
            if (_isLoadingPickup)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
            SearchableField(
              context: context,
              label: 'City',
              value: selectedCityDropdown,
              options: cityList,
              onSelected: (val) => setState(() => selectedCityDropdown = val),
            ),
            SearchableField(
              context: context,
              label: 'Service Code',
              value: selectedServiceCode,
              options: serviceCodes,
              onSelected: (val) => setState(() => selectedServiceCode = val),
            ),
            if (_isLoadingServiceCodes)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (widget.order != null)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Order ID', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Text(widget.order['id']?.toString() ?? '', style: TextStyle(fontWeight: FontWeight.w400)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _summaryRow('Name', widget.order['consignee_name'] ?? ''),
                    _summaryRow('Pickup', widget.order['pickup_address'] ?? ''),
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 2),
                     child: Row(
                       children: [
                         const Text('Destination City', style: TextStyle(fontWeight: FontWeight.w700)),
                         const SizedBox(width: 8),
                         Expanded(
                           child: _isLoadingCities
                               ? const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                               : GestureDetector(
                                   onTap: _showCitySearchDialog,
                                   child: Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                     decoration: BoxDecoration(
                                       color: Colors.white,
                                       borderRadius: BorderRadius.circular(14),
                                       border: Border.all(color: Colors.grey[300]!, width: 1),
                                       boxShadow: [
                                         BoxShadow(
                                           color: Colors.grey.withOpacity(0.08),
                                           blurRadius: 8,
                                           offset: Offset(0, 2),
                                         ),
                                       ],
                                     ),
                                     child: Row(
                                       children: [
                                         Expanded(
                                           child: Text(
                                             selectedCityDropdown ?? 'Select City',
                                             style: GoogleFonts.poppins(
                                               fontWeight: FontWeight.w500,
                                               color: selectedCityDropdown != null ? kBlue : Colors.grey[600],
                                               fontSize: 15,
                                             ),
                                           ),
                                         ),
                                         const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
                                       ],
                                     ),
                                   ),
                                 ),
                         ),
                       ],
                     ),
                   ),
                    _summaryRow('Weight', widget.order['weight']?.toString() ?? ''),
                    _summaryRow('CN', widget.order['consigment_no']?.toString() ?? ''),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  setState(() { isSubmitting = true; });
                  final user = _authService.currentUser.value;
                  final acno = user?.acno ?? '';
                  final userId = user?.userId ?? '';
                  final customerId = user?.customerId ?? '';
                  final order = widget.order;
                  final courierId = order?['courier_id']?.toString() ?? '1';
                  final customerCourierId = order?['customer_courier_id']?.toString() ?? '55';
                  final orderId = order?['id'] ?? order?['order_id'];
                  // Use selectedPickup and selectedCityDropdown
                  final body = {
                    "acno": acno,
                    "user_id": userId,
                    "customer_id": customerId,
                    "courier_id": courierId,
                    "customer_courier_id": customerCourierId,
                    "service_code": selectedServiceCode,
                    "fragile_require": fragileRequire,
                    "insurance_require": insuranceRequire,
                    "insurance_value": 0,
                    "parcel_type": parcelType == 'Parcel' ? 'P' : 'D',
                    "pickup_location_id": selectedPickup,
                    "detail": [
                      {
                        "order_id": orderId,
                        "destination_city_id": selectedCityDropdown,
                      }
                    ]
                  };
                  try {
                    final dio = Dio();
                    final response = await dio.post(
                      'https://oms.getorio.com/api/shipment/create',
                      data: body,
                      options: Options(headers: {'Content-Type': 'application/json'}),
                    );
                    if (response.statusCode == 200 && (response.data['status'] == 1 || response.data['success'] == true)) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const _CnSuccessBottomSheet(),
                      );
                    } else {
                      customSnackBar('Error', response.data['message'] ?? 'Failed to create shipment');
                    }
                  } catch (e) {
                    customSnackBar('Error', 'Failed to create shipment: \\${e.toString()}');
                  } finally {
                    setState(() { isSubmitting = false; });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Create CN', style: TextStyle(fontSize: 18, color: Colors.white)),
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
              bottomNavigationBar: const AppBottomBar(selectedIndex: 2),
    );
  }

  Widget _dropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged, {bool dense = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: dense,
          contentPadding: EdgeInsets.symmetric(vertical: dense ? 8 : 14),
        ),
        style: const TextStyle(fontSize: 15, color: Colors.black),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

class _CnSuccessBottomSheet extends StatelessWidget {
  const _CnSuccessBottomSheet({Key? key}) : super(key: key);

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
              'CN are successfully generated',
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
                    MaterialPageRoute(builder: (_) => const OrderListScreen()),
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

class _CitySearchDialog extends StatefulWidget {
  final List<String> cities;
  final String? initialCity;
  const _CitySearchDialog({Key? key, required this.cities, this.initialCity}) : super(key: key);

  @override
  State<_CitySearchDialog> createState() => _CitySearchDialogState();
}

class _CitySearchDialogState extends State<_CitySearchDialog> {
  late List<String> filteredCities;
  late TextEditingController searchController;
  String? selected;

  @override
  void initState() {
    super.initState();
    filteredCities = widget.cities;
    searchController = TextEditingController();
    selected = widget.initialCity;
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final query = searchController.text.toLowerCase();
      filteredCities = widget.cities.where((c) => c.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select City', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kBlue)),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search city...',
                prefixIcon: const Icon(Icons.search_rounded, color: kBlue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kBlue)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kBlue, width: 2)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: filteredCities.isEmpty
                  ? const Center(child: Text('No cities found.', style: TextStyle(color: kBlue)))
                  : ListView.builder(
                      itemCount: filteredCities.length,
                      itemBuilder: (context, i) {
                        final city = filteredCities[i];
                        final isSelected = city == selected;
                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                city,
                                style: TextStyle(
                                  color: isSelected ? kBlue : Colors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              selectedTileColor: kBlue.withOpacity(0.08),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              onTap: () {
                                Navigator.of(context).pop(city);
                              },
                              trailing: isSelected ? const Icon(Icons.check_circle, color: kBlue) : null,
                            ),
                            Container(
                              height: 1,
                              color: kBlue.withOpacity(0.2),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 