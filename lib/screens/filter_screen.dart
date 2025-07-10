import 'package:flutter/material.dart';
import '../services/statement_service.dart';

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

  final List<String> orders = ['Order 1', 'Order 2', 'Order 3'];
  List<String> platforms = [];
  final List<String> couriers = ['Courier 1', 'Courier 2', 'Courier 3'];
  final List<String> cities = ['City 1', 'City 2', 'City 3'];

  bool _isLoadingPlatforms = false;
  String? _platformError;

  void resetFilters() {
    setState(() {
      selectedOrder = null;
      selectedPlatform = null;
      selectedCourier = null;
      selectedCity = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPlatforms();
  }

  Future<void> _fetchPlatforms() async {
    setState(() {
      _isLoadingPlatforms = true;
      _platformError = null;
    });
    try {
      final service = StatementService();
      final shops = await service.fetchShopNames('OR-00009');
      setState(() {
        platforms = shops.map((e) => e['website_name']?.toString() ?? '').where((e) => e.isNotEmpty).toList();
        _isLoadingPlatforms = false;
      });
    } catch (e) {
      setState(() {
        _platformError = 'Failed to load platforms';
        _isLoadingPlatforms = false;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            _FilterDropdown(
              hint: 'Select Orders',
              value: selectedOrder,
              items: orders,
              onChanged: (val) => setState(() => selectedOrder = val),
            ),
            _isLoadingPlatforms
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _platformError != null
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
            _FilterDropdown(
              hint: 'Select Courier',
              value: selectedCourier,
              items: couriers,
              onChanged: (val) => setState(() => selectedCourier = val),
            ),
            _FilterDropdown(
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
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