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
  final List<dynamic> orders;
  const CreateCnScreen({Key? key, required this.orders}) : super(key: key);

  @override
  State<CreateCnScreen> createState() => _CreateCnScreenState();
}

class _CreateCnScreenState extends State<CreateCnScreen> {
  // Dropdown state
  String? selectedAccount = null; // Default to label
  String? selectedType = 'Parcel';
  String? selectedFragile = null; // Default to label
  String? selectedCourier = null; // Default to label
  String? selectedCity = null; // Default to label
  String? selectedInsurance = null; // Default to label
  List<String> cityList = [];
  bool _isLoadingCities = false;
  final AuthService _authService = Get.find<AuthService>();
  List<CourierAccount> _accounts = [];
  bool _isLoadingAccounts = false;
  final CourierService _courierService = CourierService();

  // Add state for dropdowns
  String fragileRequire = ''; // No default selection
  String insuranceRequire = ''; // No default selection
  String parcelType = ''; // No default selection, label will be shown
  bool isSubmitting = false;

  // Add state for pickup and city dropdowns
  List<String> pickupOptions = [];
  String? selectedPickup = null; // Default to label
  bool _isLoadingPickup = false;
  String? selectedCityDropdown = null; // Default to label
  
  // Add state to store pickup locations and cities with their IDs
  List<Map<String, dynamic>> pickupLocationsWithIds = [];
  List<Map<String, dynamic>> citiesWithIds = [];

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
      final countryId = 1;
      final dio = Dio();
      final response = await dio.post(
        'https://oms.getorio.com/api/cities',
        data: {"country_id": countryId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<String> cities = [];
        List<Map<String, dynamic>> cityObjs = [];
        if (data is List) {
          cityObjs = List<Map<String, dynamic>>.from(data);
          cities = data.map<String>((c) => c['city_name']?.toString() ?? '').where((c) => c.isNotEmpty).toList();
        } else if (data is Map && data['payload'] is List) {
          cityObjs = List<Map<String, dynamic>>.from(data['payload']);
          cities = (data['payload'] as List)
              .map<String>((c) => c['city_name']?.toString() ?? '')
              .where((c) => c.isNotEmpty)
              .toList();
        }
        setState(() {
          cityList = cities;
          citiesWithIds = cityObjs.map((c) => {
            'name': c['city_name']?.toString() ?? '',
            'id': int.tryParse(c['city_id']?.toString() ?? '0') ?? 0,
          }).where((c) => c['id'] != 0).toList();
          if (cityList.isNotEmpty && (selectedCityDropdown == null || !cityList.contains(selectedCityDropdown))) {
            selectedCityDropdown = cityList.first;
          }
          _isLoadingCities = false;
        });
      } else {
        setState(() {
          cityList = [];
          selectedCityDropdown = null;
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      setState(() {
        cityList = [];
        selectedCityDropdown = null;
        _isLoadingCities = false;
      });
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
        // Do not auto-select the first account. Only keep selectedAccount if it matches an account, otherwise set to null.
        if (_accounts.any((a) => _accountDropdownValue(a) == selectedAccount)) {
          // keep selectedAccount
        } else {
          selectedAccount = null;
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
      final acno = user?.acno ?? widget.orders.first['acno'] ?? '';
      
      // Extract from selected courier account
      String? courierId;
      String? customerCourierId;
      
      if (selectedAccount != null && selectedAccount != 'Select your account') {
        try {
          final selectedAccountObj = _accounts.firstWhere(
            (account) => _accountDropdownValue(account) == selectedAccount,
          );
          courierId = selectedAccountObj.courierId;
          customerCourierId = selectedAccountObj.id;
        } catch (e) {
          // If account not found, return empty list
          setState(() {
            serviceCodes = [];
            selectedServiceCode = null;
            _isLoadingServiceCodes = false;
          });
          return;
        }
      } else {
        // No account selected, return empty list
        setState(() {
          serviceCodes = [];
          selectedServiceCode = null;
          _isLoadingServiceCodes = false;
        });
        return;
      }
      
      // Return empty list if either ID is null
      if (courierId == null || customerCourierId == null) {
        setState(() {
          serviceCodes = [];
          selectedServiceCode = null;
          _isLoadingServiceCodes = false;
        });
        return;
      }
      
      final dio = Dio();
      final response = await dio.post(
        'https://stagingoms.orio.digital/api/order/getServiceCode',
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
          // Do not auto-select the first service code
          if (!serviceCodes.contains(selectedServiceCode)) {
            selectedServiceCode = null;
          }
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
      final acno = user?.acno ?? widget.orders.first['acno'] ?? '';
      
      // Extract from selected courier account
      String? courierId;
      String? customerCourierId;
      
      if (selectedAccount != null && selectedAccount != 'Select your account') {
        try {
          final selectedAccountObj = _accounts.firstWhere(
            (account) => _accountDropdownValue(account) == selectedAccount,
          );
          courierId = selectedAccountObj.courierId;
          customerCourierId = selectedAccountObj.id;
        } catch (e) {
          // If account not found, return empty list
          setState(() {
            pickupOptions = [];
            selectedPickup = null;
            _isLoadingPickup = false;
          });
          return;
        }
      } else {
        // No account selected, return empty list
        setState(() {
          pickupOptions = [];
          selectedPickup = null;
          _isLoadingPickup = false;
        });
        return;
      }
      
      // Return empty list if either ID is null
      if (courierId == null || customerCourierId == null) {
        setState(() {
          pickupOptions = [];
          selectedPickup = null;
          _isLoadingPickup = false;
        });
        return;
      }
      
      final dio = Dio();
      final response = await dio.post(
        'https://stagingoms.orio.digital/api/pickup/show',
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
        List<Map<String, dynamic>> pickupLocationsWithIds = [];
        if (data is Map && data['pickuplocation'] is List) {
          pickups = List<String>.from(data['pickuplocation'].map((e) => e['pickuplocation_name'].toString()));
          pickupLocationsWithIds = List<Map<String, dynamic>>.from(data['pickuplocation'].map((e) => {
            'name': e['pickuplocation_name']?.toString() ?? '',
            'id': int.tryParse(e['pickuplocation_id']?.toString() ?? '0') ?? 0, // Use pickuplocation_id as id
            'pickup_code': e['pickup_code']?.toString() ?? '', // Extract pickup_code
          }).where((p) => p['id'] != 0).toList());
        } else if (data is Map && data['payload'] is List) {
          pickups = List<String>.from(data['payload'].map((e) => e['pickuplocation_name'].toString()));
          pickupLocationsWithIds = List<Map<String, dynamic>>.from(data['payload'].map((e) => {
            'name': e['pickuplocation_name']?.toString() ?? '',
            'id': int.tryParse(e['pickuplocation_id']?.toString() ?? '0') ?? 0, // Use pickuplocation_id as id
            'pickup_code': e['pickup_code']?.toString() ?? '', // Extract pickup_code
          }).where((p) => p['id'] != 0).toList());
        }
        setState(() {
          pickupOptions = pickups;
          pickupLocationsWithIds = pickupLocationsWithIds;
          // Do not auto-select the first pickup
          if (!pickupOptions.contains(selectedPickup)) {
            selectedPickup = null;
          }
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
    print('Showing city search dialog with ${cityList.length} cities');
    print('Available cities: $cityList');
    print('Selected city: $selectedCityDropdown');
    
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

  void _showCnSuccessSheet(BuildContext context, List<String> cnList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  const Text('CNs Created', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: cnList.length,
                      itemBuilder: (context, i) => ListTile(
                        leading: const Icon(Icons.local_shipping, color: Colors.blue),
                        title: Text('CN: ${cnList[i]}'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCnStatusDialog(BuildContext context, List<Map<String, String>> cnStatusList, [List<Map<String, dynamic>>? fullPayload]) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('CN Creation Status', textAlign: TextAlign.center),
          content: SizedBox(
            width: 340,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (fullPayload != null && fullPayload.isNotEmpty)
                    ...fullPayload.map((item) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      (item['consigment_no'] != null && item['consigment_no'].toString().isNotEmpty)
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: (item['consigment_no'] != null && item['consigment_no'].toString().isNotEmpty)
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      (item['consigment_no'] != null && item['consigment_no'].toString().isNotEmpty)
                                          ? 'Success'
                                          : 'Failed',
                                      style: TextStyle(
                                        color: (item['consigment_no'] != null && item['consigment_no'].toString().isNotEmpty)
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...item.entries.map((entry) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Expanded(child: Text('${entry.value}')),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        )),
                  if (fullPayload == null || fullPayload.isEmpty)
                    ...cnStatusList.map((item) => ListTile(
                          leading: Icon(
                            item['status'] == 'success' ? Icons.check_circle : Icons.error,
                            color: item['status'] == 'success' ? Colors.green : Colors.red,
                          ),
                          title: Text('Order: ${item['order_id'] ?? '-'}'),
                          subtitle: Text('CN: ${item['cn'] ?? '-'}'),
                          trailing: Text(
                            item['status'] == 'success' ? 'Success' : 'Failed',
                            style: TextStyle(
                              color: item['status'] == 'success' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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
              onSelected: (val) {
                setState(() => selectedAccount = val);
                // Refresh pickup locations and service codes when account changes
                if (val != null && val != 'Select your account') {
                  _fetchPickupLocations();
                  _fetchServiceCodes();
                }
              },
            ),
            // Move Pickup and Service Code fields here
            SearchableField(
              context: context,
              label: 'Pickup',
              value: selectedPickup,
              options: pickupOptions,
              onSelected: (val) => setState(() => selectedPickup = val),
            ),
            SearchableField(
              context: context,
              label: 'Service Code',
              value: selectedServiceCode,
              options: serviceCodes,
              onSelected: (val) => setState(() => selectedServiceCode = val),
            ),
            // Fragile and Insurance with default label
            SearchableField(
              context: context,
              label: 'Fragile',
              value: fragileRequire.isEmpty ? null : (fragileRequire == 'Y' ? 'Yes' : 'No'),
              options: ['Fragile', 'Yes', 'No'],
              onSelected: (val) => setState(() => fragileRequire = val == 'Yes' ? 'Y' : val == 'No' ? 'N' : ''),
            ),
            SearchableField(
              context: context,
              label: 'Insurance',
              value: insuranceRequire.isEmpty ? null : (insuranceRequire == 'Y' ? 'Yes' : 'No'),
              options: ['Insurance', 'Yes', 'No'],
              onSelected: (val) => setState(() => insuranceRequire = val == 'Yes' ? 'Y' : val == 'No' ? 'N' : ''),
            ),
            SearchableField(
              context: context,
              label: 'Parcel Type',
              value: parcelType.isEmpty ? null : parcelType,
              options: ['Parcel Type', 'Parcel', 'Document'],
              onSelected: (val) => setState(() => parcelType = val == 'Parcel Type' ? '' : val),
            ),
            // Inline loading indicators for pickup and service code
            if (widget.orders.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Selected Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.orders.map((order) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
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
                        Text(order['id']?.toString() ?? '', style: TextStyle(fontWeight: FontWeight.w400)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _summaryRow('Name', order['consignee_name'] ?? ''),
                    _summaryRow('Pickup', order['pickup_address'] ?? ''),
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
                    _summaryRow('Weight', order['weight']?.toString() ?? ''),
                    _summaryRow('CN', order['consigment_no']?.toString() ?? ''),
                    const SizedBox(height: 6),
                  ],
                ),
              )).toList(),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  // Validate required fields before submitting
                  if (selectedAccount == null || selectedAccount == 'Select your account' ||
                      selectedPickup == null || selectedPickup!.isEmpty ||
                      selectedServiceCode == null || selectedServiceCode!.isEmpty ||
                      fragileRequire.isEmpty || insuranceRequire.isEmpty || parcelType.isEmpty ||
                      selectedCityDropdown == null || selectedCityDropdown!.isEmpty ||
                      widget.orders.isEmpty) {
                    customSnackBar('Error', 'Please fill required fields');
                    return;
                  }
                  setState(() { isSubmitting = true; });
                  
                  try {
                    final user = _authService.currentUser.value;
                    final acno = user?.acno ?? '';
                    final userId = int.tryParse(user?.userId?.toString() ?? '0') ?? 0;
                    final customerId = int.tryParse(user?.customerId?.toString() ?? '0') ?? 0;
                    final order = widget.orders.first;
                    
                    // Extract courier_id and customer_courier_id from selected account
                    int courierId = 1;
                    int customerCourierId = 55;
                    
                    if (selectedAccount != null && selectedAccount != 'Select your account') {
                      try {
                        final selectedAccountObj = _accounts.firstWhere(
                          (account) => _accountDropdownValue(account) == selectedAccount,
                        );
                        courierId = int.tryParse(selectedAccountObj.courierId) ?? 1;
                        customerCourierId = int.tryParse(selectedAccountObj.id) ?? 55;
                      } catch (e) {
                        if (_accounts.isNotEmpty) {
                          courierId = int.tryParse(_accounts.first.courierId) ?? 1;
                          customerCourierId = int.tryParse(_accounts.first.id) ?? 55;
                        }
                      }
                    }
                    
                    // Extract service_code from dropdown
                    final serviceCode = selectedServiceCode ?? '';
                    
                    // Extract fragile_require and insurance_require from dropdowns
                    final fragileRequireValue = this.fragileRequire == 'Y' ? 'Y' : 'N';
                    final insuranceRequireValue = this.insuranceRequire == 'Y' ? 'Y' : 'N';
                    
                    // Extract parcel_type from dropdown
                    final parcelTypeValue = this.parcelType == 'Parcel' ? 'P' : 'D';
                    
                    // Extract pickup_location_id from dropdown by matching pickup name
                    int pickupLocationId = 0;
                    if (selectedPickup != null && selectedPickup!.isNotEmpty) {
                      final pickupLocation = pickupLocationsWithIds.firstWhere(
                        (p) => p['name'] == selectedPickup,
                        orElse: () => <String, Object>{},
                      );
                      pickupLocationId = pickupLocation['id'] ?? 0;
                      print('Selected pickup: $selectedPickup, Extracted pickupLocationId (pickuplocation_id): $pickupLocationId, pickupLocation: $pickupLocation');
                    } else {
                      print('No pickup selected or pickup name is empty');
                    }
                    // Use pickupLocationId directly in API body
                    final pickupLocationIdInt = int.tryParse(pickupLocationId.toString()) ?? 0;
                    
                    // Extract order_id from order
                    final orderId = int.tryParse(order?['id']?.toString() ?? order?['order_id']?.toString() ?? '0') ?? 0;
                    
                    // Extract destination_city_id from selected city
                    int destinationCityId = 0;
                    if (selectedCityDropdown != null && selectedCityDropdown!.isNotEmpty) {
                      final city = citiesWithIds.firstWhere(
                        (c) => c['name'] == selectedCityDropdown,
                        orElse: () => <String, Object>{},
                      );
                      destinationCityId = city['id'] ?? 0;
                    }
                    
                    // Create detail entries for all orders
                    final detailEntries = widget.orders.map((order) => {
                      "order_id": int.tryParse(order?['id']?.toString() ?? order?['order_id']?.toString() ?? '0') ?? 0,
                      "destination_city_id": destinationCityId,
                    }).toList();
                    
                    final body = {
                      "acno": acno,
                      "user_id": userId,
                      "customer_id": customerId,
                      "courier_id": courierId,
                      "customer_courier_id": customerCourierId,
                      "service_code": serviceCode,
                      "fragile_require": fragileRequireValue,
                      "insurance_require": insuranceRequireValue,
                      "insurance_value": 0,
                      "parcel_type": parcelTypeValue,
                      "pickup_location_id": pickupLocationIdInt,
                      "detail": detailEntries
                    };
                    
                    print('Shipment creation body: $body');
                    
                    final dio = Dio();
                    final response = await dio.post(
                      'https://stagingoms.orio.digital/api/shipment/create',
                      data: body,
                      options: Options(headers: {'Content-Type': 'application/json'}),
                    );
                    
                    print('Shipment creation response: ${response.data}');
                    
                    if (response.statusCode == 200 && (response.data['status'] == 1 || response.data['success'] == true)) {
                      // Extract payload and build status list for all orders
                      final List<Map<String, dynamic>> fullPayload = response.data['payload'] is List
                          ? List<Map<String, dynamic>>.from(response.data['payload'])
                          : [];
                      final Set<String> successOrderIds = fullPayload
                          .where((item) => item['consigment_no'] != null && item['consigment_no'].toString().isNotEmpty)
                          .map((item) => item['order_id']?.toString() ?? '')
                          .toSet();
                      final List<Map<String, dynamic>> dialogList = widget.orders.map((order) {
                        final orderId = order['id']?.toString() ?? order['order_id']?.toString() ?? '';
                        final payloadItem = fullPayload.firstWhere(
                          (item) => (item['order_id']?.toString() ?? '') == orderId,
                          orElse: () => <String, dynamic>{},
                        );
                        return {
                          'order_id': orderId,
                          ...payloadItem,
                          'status': (payloadItem['consigment_no'] != null && payloadItem['consigment_no'].toString().isNotEmpty)
                              ? 'success'
                              : 'failed',
                        };
                      }).toList();
                      // Show dialog with all order statuses
                      await showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => _CnStatusDialog(dialogList: dialogList),
                      );
                      // Only remove successful orders
                      setState(() {
                        widget.orders.removeWhere((order) =>
                          successOrderIds.contains(order['id']?.toString() ?? order['order_id']?.toString() ?? '')
                        );
                        // Only clear form fields and selections if all orders succeeded
                        final allSucceeded = widget.orders.isEmpty;
                        if (allSucceeded) {
                          selectedAccount = null;
                          selectedType = 'Parcel';
                          selectedFragile = null;
                          selectedCourier = null;
                          selectedCity = null;
                          selectedInsurance = null;
                          cityList = [];
                          fragileRequire = '';
                          insuranceRequire = '';
                          parcelType = '';
                          pickupOptions = [];
                          selectedPickup = null;
                          _isLoadingPickup = false;
                          selectedCityDropdown = null;
                          pickupLocationsWithIds = [];
                          citiesWithIds = [];
                          serviceCodes = [];
                          selectedServiceCode = null;
                          _isLoadingServiceCodes = false;
                        }
                      });
                    } else {
                      customSnackBar('Error', response.data['message'] ?? 'Failed to create shipment');
                    }
                  } catch (e) {
                    print('Error creating shipment: $e');
                    customSnackBar('Error', 'Failed to create shipment: ${e.toString()}');
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
            // Add bottom padding to prevent FAB overlap
            const SizedBox(height: 80),
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

class _CnStatusDialog extends StatelessWidget {
  final List<Map<String, dynamic>> dialogList;
  const _CnStatusDialog({Key? key, required this.dialogList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('CN Creation Status', textAlign: TextAlign.center),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: dialogList.map((item) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          item['status'] == 'success' ? Icons.check_circle : Icons.error,
                          color: item['status'] == 'success' ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['status'] == 'success' ? 'Success' : 'Failed',
                          style: TextStyle(
                            color: item['status'] == 'success' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...item.entries.where((entry) => entry.key != 'status').map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(child: Text('${entry.value}')),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
} 