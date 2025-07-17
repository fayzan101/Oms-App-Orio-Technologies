import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/statement_service.dart';
import '../services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kBlue = Color(0xFF007AFF);

class CustomMultiSelectDialog<T> extends StatefulWidget {
  final List<MultiSelectItem<T>> items;
  final List<T> initialValue;
  final void Function(List<T>) onConfirm;
  final String title;

  const CustomMultiSelectDialog({
    required this.items,
    required this.initialValue,
    required this.onConfirm,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  _CustomMultiSelectDialogState<T> createState() => _CustomMultiSelectDialogState<T>();
}

class _CustomMultiSelectDialogState<T> extends State<CustomMultiSelectDialog<T>> {
  late List<T> _selected;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items
        .where((item) => item.label.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kBlue)),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search_rounded, color: kBlue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: ListView.separated(
                itemCount: filteredItems.length,
                separatorBuilder: (_, __) => Container(
                  height: 1,
                  color: kBlue.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                itemBuilder: (context, i) {
                  final item = filteredItems[i];
                  final isChecked = _selected.contains(item.value);
                  return ListTile(
                    title: Text(item.label),
                    trailing: Checkbox(
                      value: isChecked,
                      activeColor: kBlue,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selected.add(item.value);
                          } else {
                            _selected.remove(item.value);
                          }
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        if (isChecked) {
                          _selected.remove(item.value);
                        } else {
                          _selected.add(item.value);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kBlue),
              onPressed: () {
                Navigator.of(context).pop(_selected);
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? selectedOrder;
  List<String> selectedPlatforms = [];
  List<String> selectedCouriers = [];
  List<String> selectedCities = [];
  List<String> selectedStatuses = [];

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
      selectedPlatforms = [];
      selectedCouriers = [];
      selectedCities = [];
      selectedStatuses = [];
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

  Widget _customMultiSelectField({
    required BuildContext context,
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required void Function(List<String>) onConfirm,
  }) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<List<String>>(
          context: context,
          builder: (ctx) => CustomMultiSelectDialog<String>(
            items: items.map((e) => MultiSelectItem(e, e)).toList(),
            initialValue: selectedItems,
            onConfirm: (values) {
              Navigator.of(ctx).pop(values);
            },
            title: title,
          ),
        );
        if (result != null) {
          onConfirm(result);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                selectedItems.isEmpty ? title : selectedItems.join(', '),
                style: GoogleFonts.poppins(fontSize: 15, color: selectedItems.isEmpty ? Colors.grey : Colors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
          ],
        ),
      ),
    );
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
                      : _customMultiSelectField(
                          context: context,
                          title: 'Select Status',
                          items: statuses,
                          selectedItems: selectedStatuses,
                          onConfirm: (values) {
                            setState(() {
                              selectedStatuses = List<String>.from(values);
                            });
                          },
                        ),
                  _platformError != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(_platformError!, style: const TextStyle(color: Colors.red)),
                        )
                      : _customMultiSelectField(
                          context: context,
                          title: 'Select Platforms',
                          items: platforms,
                          selectedItems: selectedPlatforms,
                          onConfirm: (values) {
                            setState(() {
                              selectedPlatforms = List<String>.from(values);
                            });
                          },
                        ),
                  _courierError != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(_courierError!, style: const TextStyle(color: Colors.red)),
                        )
                      : _customMultiSelectField(
                          context: context,
                          title: 'Select Courier',
                          items: couriers,
                          selectedItems: selectedCouriers,
                          onConfirm: (values) {
                            setState(() {
                              selectedCouriers = List<String>.from(values);
                            });
                          },
                        ),
                  _cityError != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(_cityError!, style: const TextStyle(color: Colors.red)),
                        )
                      : _customMultiSelectField(
                          context: context,
                          title: 'Select Cities',
                          items: cities,
                          selectedItems: selectedCities,
                          onConfirm: (values) {
                            setState(() {
                              selectedCities = List<String>.from(values);
                            });
                          },
                        ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Return selected filters to the calling screen
                        final filters = {
                          'order': selectedOrder,
                          'status': selectedStatuses,
                          'platform': selectedPlatforms,
                          'courier': selectedCouriers,
                          'city': selectedCities,
                        };
                        Navigator.of(context).pop(filters);
                      },
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
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 15, color: Colors.black))))
            .toList(),
        onChanged: items.isNotEmpty ? onChanged : null,
        decoration: InputDecoration(
          hintText: items.isNotEmpty ? hint : 'No items available',
          hintStyle: GoogleFonts.poppins(fontSize: 15, color: Color(0xFF6B6B6B)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.blue[300]!, width: 1.5),
          ),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
        style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
      ),
    );
  }
} 