import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/statement_service.dart';
import '../services/auth_service.dart';
import 'package:dio/dio.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? selectedOrder;
  String? selectedPlatform;
  String? selectedCourier;
  String? selectedCity;
  String? selectedStatus;

  final List<String> orders = ['Booked', 'Unbooked'];
  List<String> platforms = [];
  List<String> couriers = [];
  bool _isLoadingCouriers = false;
  String? _courierError;
  List<String> cities = [];
  List<String> statuses = [];
  bool _isLoadingStatuses = false;
  String? _statusError;

  bool _isLoadingPlatforms = false;
  bool _isLoadingCities = false;
  String? _platformError;
  String? _cityError;
  final AuthService _authService = Get.find<AuthService>();

  void resetFilters() {
    setState(() {
      selectedOrder = null;
      selectedPlatform = null;
      selectedCourier = null;
      selectedCity = null;
      selectedStatus = 'All';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchData();
    _fetchStatuses();
    _fetchCouriers();
  }

  Future<void> _loadUserDataAndFetchData() async {
    // Load user data if not already loaded
    if (_authService.currentUser.value == null) {
      await _authService.loadUserData();
    }
    await _fetchPlatforms();
    await _fetchCities();
  }

  Future<void> _fetchPlatforms() async {
    setState(() {
      _isLoadingPlatforms = true;
      _platformError = null;
    });
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        setState(() {
          _platformError = 'User not logged in';
          _isLoadingPlatforms = false;
        });
        return;
      }

      final service = StatementService();
      final shops = await service.fetchShopNames(acno);
      setState(() {
        platforms = shops.map((e) => e['platform_name']?.toString() ?? '').where((e) => e.isNotEmpty).toList();
        _isLoadingPlatforms = false;
      });
    } catch (e) {
      setState(() {
        _platformError = 'Failed to load platforms';
        _isLoadingPlatforms = false;
      });
    }
  }

  Future<void> _fetchCities() async {
    setState(() {
      _isLoadingCities = true;
      _cityError = null;
    });
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        setState(() {
          _cityError = 'User not logged in';
          _isLoadingCities = false;
        });
        return;
      }

      final service = StatementService();
      final cityData = await service.fetchCityList(acno);
      print('Filter screen received city data: $cityData');
      print('City data length: ${cityData.length}');
      
      final cityNames = cityData.map((e) => e['name']?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      print('Extracted city names: $cityNames');
      print('City names length: ${cityNames.length}');
      
      setState(() {
        cities = cityNames;
        _isLoadingCities = false;
      });
      print('Cities list updated: $cities');
    } catch (e) {
      print('Error fetching cities: $e');
      setState(() {
        _cityError = 'Failed to load cities: $e';
        _isLoadingCities = false;
      });
    }
  }

  Future<void> _fetchStatuses() async {
    setState(() {
      _isLoadingStatuses = true;
      _statusError = null;
    });
    try {
      final response = await Dio().post(
        'https://oms.getorio.com/api/common/status',
        data: {"status_type": "Customer Service"},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final List<dynamic> data = response.data;
      setState(() {
        statuses = data.map((e) => e['name'].toString()).toList();
        _isLoadingStatuses = false;
      });
    } catch (e) {
      setState(() {
        _statusError = 'Failed to load statuses';
        _isLoadingStatuses = false;
      });
    }
  }

  Future<void> _fetchCouriers() async {
    setState(() {
      _isLoadingCouriers = true;
      _courierError = null;
    });
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        setState(() {
          _courierError = 'User not logged in';
          _isLoadingCouriers = false;
        });
        return;
      }
      final response = await Dio().post(
        'https://oms.getorio.com/api/courier/index',
        data: {"acno": acno},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);
      setState(() {
        couriers = data.map((e) => e['courier_name'].toString()).toList();
        _isLoadingCouriers = false;
      });
    } catch (e) {
      setState(() {
        _courierError = 'Failed to load couriers';
        _isLoadingCouriers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoadingAll = _isLoadingStatuses || _isLoadingCouriers || _isLoadingPlatforms || _isLoadingCities;
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
          'Filter',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: isLoadingAll
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  _FilterDropdown(
                    hint: 'Select Orders',
                    value: selectedOrder,
                    items: orders,
                    onChanged: (val) => setState(() => selectedOrder = val),
                  ),
                  _statusError != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(_statusError!, style: const TextStyle(color: Colors.red)),
                        )
                      : _FilterDropdown(
                          hint: 'Select Status',
                          value: selectedStatus,
                          items: statuses,
                          onChanged: (val) => setState(() => selectedStatus = val),
                        ),
                  _platformError != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(_platformError!, style: const TextStyle(color: Colors.red)),
                        )
                      : _FilterDropdown(
                          hint: 'Select Platforms',
                          value: selectedPlatform,
                          items: platforms,
                          onChanged: (val) => setState(() => selectedPlatform = val),
                        ),
                  _courierError != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(_courierError!, style: const TextStyle(color: Colors.red)),
                        )
                      : _FilterDropdown(
                          hint: 'Select Courier',
                          value: selectedCourier,
                          items: couriers,
                          onChanged: (val) => setState(() => selectedCourier = val),
                        ),
                  _cityError != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(_cityError!, style: const TextStyle(color: Colors.red)),
                        )
                      : _FilterDropdown(
                          hint: 'Select Cities',
                          value: selectedCity,
                          items: cities,
                          onChanged: (val) => setState(() => selectedCity = val),
                        ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: resetFilters,
                    child: const Text(
                      'Reset Filter',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.red,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?)? onChanged;
  const _FilterDropdown({required this.hint, required this.value, required this.items, this.onChanged});

  @override
  Widget build(BuildContext context) {
    print('_FilterDropdown build - hint: $hint, items: $items, items length: ${items.length}');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: items.isNotEmpty ? onChanged : null,
        decoration: InputDecoration(
          hintText: items.isNotEmpty ? hint : 'No items available',
          hintStyle: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: Color(0xFF6B6B6B),
          ),
          filled: true,
          fillColor: Color(0xFFF5F5F7),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
      ),
    );
  }
} 