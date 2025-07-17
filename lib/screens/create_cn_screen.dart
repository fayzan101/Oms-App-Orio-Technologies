import 'package:flutter/material.dart';
import 'order_list_screen.dart';
import '../utils/Layout/app_bottom_bar.dart';
import '../services/statement_service.dart';
import '../services/auth_service.dart';
import 'package:get/get.dart';

// Blue color constant for theme
const Color kBlue = Color(0xFF007AFF);

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

  @override
  void initState() {
    super.initState();
    _fetchCities();
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
        if (cityList.isNotEmpty && (selectedCity == null || !cityList.contains(selectedCity))) {
          selectedCity = cityList.first;
        }
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() { _isLoadingCities = false; });
    }
  }

  Future<void> _showCitySearchDialog() async {
    if (_isLoadingCities) return;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => _CitySearchDialog(
        cities: cityList,
        initialCity: selectedCity,
      ),
    );
    if (selected != null) {
      setState(() {
        selectedCity = selected;
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
            _dropdown('Select your account', selectedAccount, ['Select your account', 'Account 1', 'Account 2'], (val) => setState(() => selectedAccount = val), dense: true),
            _dropdown('Parcel', selectedType, ['Parcel', 'Document'], (val) => setState(() => selectedType = val), dense: true),
            _dropdown('Fragile(Yes)', selectedFragile, ['Fragile(Yes)', 'Fragile(No)'], (val) => setState(() => selectedFragile = val), dense: true),
            _dropdown('Blue Cargo', selectedCourier, ['Blue Cargo', 'TCS', 'Leopards'], (val) => setState(() => selectedCourier = val), dense: true),
            _dropdown('Insurance(Yes)', selectedInsurance, ['Insurance(Yes)', 'Insurance(No)'], (val) => setState(() => selectedInsurance = val), dense: true),
            const SizedBox(height: 10),
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
                                       borderRadius: BorderRadius.circular(10),
                                       border: Border.all(color: kBlue, width: 1.5),
                                     ),
                                     child: Row(
                                       children: [
                                         Expanded(
                                           child: Text(
                                             selectedCity ?? 'Select City',
                                             style: TextStyle(
                                               fontWeight: FontWeight.w500,
                                               color: selectedCity != null ? kBlue : Colors.grey[600],
                                               fontSize: 15,
                                             ),
                                           ),
                                         ),
                                         const Icon(Icons.keyboard_arrow_down_rounded, color: kBlue),
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
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const _CnSuccessBottomSheet(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Create CN', style: TextStyle(fontSize: 18, color: Colors.white)),
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