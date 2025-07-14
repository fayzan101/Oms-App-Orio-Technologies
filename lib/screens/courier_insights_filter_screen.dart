import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/courier_service.dart';
import '../services/statement_service.dart';
import '../services/auth_service.dart';
import 'package:dio/dio.dart';

class CourierInsightsFilterScreen extends StatefulWidget {
  final Function(Map<String, dynamic> filters) onApply;
  final VoidCallback onReset;
  const CourierInsightsFilterScreen({Key? key, required this.onApply, required this.onReset}) : super(key: key);

  @override
  State<CourierInsightsFilterScreen> createState() => _CourierInsightsFilterScreenState();
}

class _CourierInsightsFilterScreenState extends State<CourierInsightsFilterScreen> {
  String? selectedStatus;
  String? selectedCourier;
  String? selectedCity;
  String? selectedPaymentMethod;
  String? selectedPaymentStatus;

  List<String> statusOptions = ['Booked', 'In Transit', 'Delivered', 'Returned', 'Failed']; // Example static
  List<String> courierOptions = [];
  List<String> statusApiOptions = [];
  bool isLoadingStatuses = false;
  String? statusError;
  bool isLoadingCouriers = false;
  String? courierError;
  List<String> cityOptions = [];
  List<String> paymentMethodOptions = ['COD', 'CC'];
  List<String> paymentStatusOptions = ['Paid', 'Unpaid', 'Partial']; // Example static

  bool isLoadingCities = false;
  
  // Validation state
  bool showValidationErrors = false;
  final AuthService _authService = Get.find<AuthService>();

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
    await fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    setState(() {
      isLoadingCouriers = true;
      isLoadingCities = true;
    });
    
    final acno = _authService.getCurrentAcno();
    if (acno == null) {
      setState(() {
        isLoadingCouriers = false;
        isLoadingCities = false;
      });
      return;
    }
    
    // Fetch couriers
    try {
      final couriers = await CourierService().getCouriers(acno);
      courierOptions = couriers.map((c) => (c['name'] ?? c['courier_name'] ?? '').toString()).where((s) => s.isNotEmpty).toList();
    } catch (_) {}
    // Fetch cities
    try {
      final cities = await StatementService().fetchCityList(acno);
      cityOptions = cities.map((c) => (c['name'] ?? c['city_name'] ?? '').toString()).where((s) => s.isNotEmpty).toList();
    } catch (_) {}
    setState(() {
      isLoadingCouriers = false;
      isLoadingCities = false;
    });
  }

  Future<void> _fetchStatuses() async {
    setState(() {
      isLoadingStatuses = true;
      statusError = null;
    });
    try {
      final response = await Dio().post(
        'https://oms.getorio.com/api/common/status',
        data: {"status_type": "Customer Service"},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);
      setState(() {
        statusApiOptions = data.map((e) => e['name'].toString()).toList();
        isLoadingStatuses = false;
      });
    } catch (e) {
      setState(() {
        statusError = 'Failed to load statuses';
        isLoadingStatuses = false;
      });
    }
  }

  Future<void> _fetchCouriers() async {
    setState(() {
      isLoadingCouriers = true;
      courierError = null;
    });
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        setState(() {
          courierError = 'User not logged in';
          isLoadingCouriers = false;
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
        courierOptions = data.map((e) => e['courier_name'].toString()).toList();
        isLoadingCouriers = false;
      });
    } catch (e) {
      setState(() {
        courierError = 'Failed to load couriers';
        isLoadingCouriers = false;
      });
    }
  }

  void _showSearchDialog({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog(
        title: title,
        options: options,
        selectedValue: selectedValue,
        onSelected: (val) {
          onSelected(val);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoadingAll = isLoadingStatuses || isLoadingCouriers || isLoadingCities;
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
        title: const Text('Filter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
      ),
      body: isLoadingAll
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _searchableField(
                    label: 'Select Status',
                    value: selectedStatus,
                    isLoading: false,
                    isError: showValidationErrors && selectedStatus == null,
                    onTap: () => _showSearchDialog(
                      title: 'Select Status',
                      options: statusApiOptions,
                      selectedValue: selectedStatus,
                      onSelected: (val) => setState(() => selectedStatus = val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _searchableField(
                    label: 'Select Courier',
                    value: selectedCourier,
                    isLoading: false,
                    isError: showValidationErrors && selectedCourier == null,
                    onTap: () => _showSearchDialog(
                      title: 'Select Courier',
                      options: courierOptions,
                      selectedValue: selectedCourier,
                      onSelected: (val) => setState(() => selectedCourier = val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _searchableField(
                    label: 'Select Destination City',
                    value: selectedCity,
                    isLoading: false,
                    isError: showValidationErrors && selectedCity == null,
                    onTap: () => _showSearchDialog(
                      title: 'Select Destination City',
                      options: cityOptions,
                      selectedValue: selectedCity,
                      onSelected: (val) => setState(() => selectedCity = val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _searchableField(
                    label: 'Select Payment Method',
                    value: selectedPaymentMethod,
                    isLoading: false,
                    isError: showValidationErrors && selectedPaymentMethod == null,
                    onTap: () => _showSearchDialog(
                      title: 'Select Payment Method',
                      options: paymentMethodOptions,
                      selectedValue: selectedPaymentMethod,
                      onSelected: (val) => setState(() => selectedPaymentMethod = val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _searchableField(
                    label: 'Select Payment Status',
                    value: selectedPaymentStatus,
                    isLoading: false,
                    isError: showValidationErrors && selectedPaymentStatus == null,
                    onTap: () => _showSearchDialog(
                      title: 'Select Payment Status',
                      options: paymentStatusOptions,
                      selectedValue: selectedPaymentStatus,
                      onSelected: (val) => setState(() => selectedPaymentStatus = val),
                    ),
                  ),
                  const SizedBox(height: 32),
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
                      onPressed: () {
                        // Check if all fields are selected
                        if (selectedStatus == null || selectedCourier == null || selectedCity == null || selectedPaymentMethod == null || selectedPaymentStatus == null) {
                          setState(() {
                            showValidationErrors = true;
                          });
                          return;
                        }
                        // Reset validation errors
                        setState(() {
                          showValidationErrors = false;
                        });
                        // Apply filters
                        widget.onApply({
                          'status': selectedStatus,
                          'courier': selectedCourier,
                          'city': selectedCity,
                          'paymentMethod': selectedPaymentMethod,
                          'paymentStatus': selectedPaymentStatus,
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text('Apply Filters', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedStatus = null;
                        selectedCourier = null;
                        selectedCity = null;
                        selectedPaymentMethod = null;
                        selectedPaymentStatus = null;
                      });
                      widget.onReset();
                    },
                    child: const Text('Reset Filter', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _searchableField({
    required String label,
    required String? value,
    required bool isLoading,
    required VoidCallback onTap,
    bool isError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: isError ? Colors.red : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
        color: isError ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F7),
      ),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value ?? label,
                        style: TextStyle(
                          color: value != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
    );
  }
}

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
  }

  void _filterOptions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = widget.options;
      } else {
        _filteredOptions = widget.options.where((option) => option.toLowerCase().contains(query.toLowerCase())).toList();
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
                Text(
                  widget.title,
                  style: const TextStyle(
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
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _filterOptions,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredOptions.isEmpty
                  ? const Center(
                      child: Text(
                        'No options found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredOptions.length,
                      itemBuilder: (context, index) {
                        final option = _filteredOptions[index];
                        final isSelected = option == widget.selectedValue;
                        return ListTile(
                          title: Text(option),
                          leading: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF007AFF))
                              : const Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey),
                          onTap: () => widget.onSelected(option),
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