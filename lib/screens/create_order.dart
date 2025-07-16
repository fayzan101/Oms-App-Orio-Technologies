import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart' as dash;
import 'menu.dart' as menu;
import 'report.dart' as report;
import 'package:flutter/services.dart';
import 'add_product_screen.dart';
import '../services/statement_service.dart';
import '../services/auth_service.dart';
import 'dart:async';
import '../network/order_service.dart';
import '../utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderItem {
  final String name;
  final String sku;
  final String refCode;
  final int qty;
  final double price;
  OrderItem({required this.name, required this.sku, required this.refCode, required this.qty, required this.price});
}

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final List<OrderItem> _orders = [];
  final Set<int> _expandedOrders = {};
  bool _isDialogOpen = false;
  String selectedCountry = 'Pakistan';
  String? selectedCity;
  List<String> cityList = [];
  String selectedPaymentType = 'COD';
  final List<String> paymentTypes = ['COD', 'JazzCash', 'EasyPaisa', 'CC'];
  bool _isLoadingCities = false;
  final AuthService _authService = Get.find<AuthService>();
  bool _isSaving = false;
  // Add these state variables for platform selection
  List<Map<String, dynamic>> _platforms = [];
  Map<String, dynamic>? _selectedPlatform;
  bool _isLoadingPlatforms = false;
  String? _platformError;
  String _platformSearch = '';

  @override
  void initState() {
    super.initState();
    _fetchCities();
    _fetchPlatforms();
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
        cityList = cities.map((c) => c['name']?.toString() ?? '').where((c) => c.isNotEmpty).toList();
        if (cityList.isNotEmpty) selectedCity = cityList.first;
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() { _isLoadingCities = false; });
    }
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
      final platformData = await service.fetchShopNames(acno);
      // Only keep platforms with a non-empty platform_name, just like filter screen
      final filtered = platformData.where((e) => (e['platform_name']?.toString() ?? '').isNotEmpty).toList();
      setState(() {
        _platforms = filtered;
        _isLoadingPlatforms = false;
      });
    } catch (e) {
      setState(() {
        _platformError = 'Failed to load platforms: $e';
        _isLoadingPlatforms = false;
      });
    }
  }

  void _addOrder(OrderItem item) {
    setState(() {
      _orders.add(item);
    });
  }

  void _showSelectPlatformDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String search = '';
        List<Map<String, dynamic>> filteredPlatforms = _platforms;
        return StatefulBuilder(
          builder: (context, setState) {
            filteredPlatforms = _platforms.where((p) => (p['platform_name']?.toString().toLowerCase() ?? '').contains(search.toLowerCase())).toList();
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close, size: 24, color: Color(0xFF222222)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select Platform',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Platform',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      ),
                      onChanged: (val) {
                        setState(() {
                          search = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _isLoadingPlatforms
                        ? const Center(child: CircularProgressIndicator())
                        : _platformError != null
                            ? Text(_platformError!, style: const TextStyle(color: Colors.red))
                            : filteredPlatforms.isEmpty
                                ? const Text('No platforms found.')
                                : SizedBox(
                                    height: 200,
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: filteredPlatforms.length,
                                      separatorBuilder: (context, i) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
                                      itemBuilder: (context, i) {
                                        final platform = filteredPlatforms[i];
                                        return ListTile(
                                          title: Text(
                                            platform['platform_name']?.toString() ?? 'Unknown Platform',
                                            style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 15),
                                          ),
                                          subtitle: Text(
                                            'ID: ${platform['id']}',
                                            style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 12, color: Color(0xFF6B6B6B)),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedPlatform = platform;
                                            });
                                            Navigator.of(context).pop();
                                            _showAddProductScreen(context);
                                          },
                                          contentPadding: EdgeInsets.zero,
                                        );
                                      },
                                    ),
                                  ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddProductScreen(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddProductScreen(
          platformId: int.tryParse(_selectedPlatform?['id']?.toString() ?? ''),
          customerPlatformId: _selectedPlatform?['customer_platform_id'] != null
              ? int.tryParse(_selectedPlatform?['customer_platform_id']?.toString() ?? '')
              : null,
        ),
      ),
    );
    if (result is OrderItem) {
      _addOrder(result);
    }
  }

  Future<bool?> showDeleteProductDialog(BuildContext context) {
    return showModalBottomSheet<bool>(
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
                    color: Color(0xFFF5F5F7),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(32),
                  child: Icon(Icons.delete_outline, color: Color(0xFF007AFF), size: 64),
                ),
                SizedBox(height: 24),
                Text(
                  'Are you Sure',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You want to delete this product',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF2F2F7),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'No',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF007AFF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Yes',
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
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showSuccessDialog(BuildContext context) {
    return showModalBottomSheet(
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
                    color: Color(0xFFF5F5F7),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(32),
                  child: Icon(Icons.check_circle_outline, color: Color(0xFF007AFF), size: 64),
                ),
                SizedBox(height: 24),
                Text(
                  'Deleted!',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Product has been deleted successfully.',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007AFF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'OK',
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
          ),
        );
      },
    );
  }

  Future<void> _submitOrder() async {
    if (_orders.isEmpty) {
      customSnackBar('Error', 'Please add at least one product');
      return;
    }
    if (selectedCity == null || selectedCity!.isEmpty) {
      customSnackBar('Error', 'Please select a city');
      return;
    }
    setState(() { _isSaving = true; });
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null || acno.isEmpty) {
        customSnackBar('Error', 'User not logged in');
        setState(() { _isSaving = false; });
        return;
      }
      // Build order data (simplified, expand as needed)
      final orderList = [
        {
          'acno': acno,
          'city': selectedCity,
          'country': selectedCountry,
          'payment_type': selectedPaymentType,
          'products': _orders.map((o) => {
            'name': o.name,
            'sku': o.sku,
            'ref_code': o.refCode,
            'qty': o.qty,
            'price': o.price,
          }).toList(),
        },
      ];
      final response = await OrderService.createOrder(orderList: orderList);
      if (response['status'] == 1 || response['success'] == true) {
        customSnackBar('Success', 'Order created successfully!');
        // Optionally navigate to order list screen here
      } else {
        customSnackBar('Error', response['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      customSnackBar('Error', 'Failed to create order: ${e.toString()}');
    } finally {
      setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Get.offAll(() => menu.MenuScreen()),
        ),
        title: const Text('Create Order', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_orders.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        children: _orders.asMap().entries.map((entry) {
                          final i = entry.key;
                          final order = entry.value;
                          final expanded = _expandedOrders.contains(i);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: expanded
                                ? Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F7),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Color(0xFFE0E0E0)),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Text('S.No', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'SF Pro Display', fontSize: 14)),
                                                  const SizedBox(width: 6),
                                                  Text((i + 1).toString(), style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 14)),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF222222)),
                                              onPressed: () {
                                                setState(() {
                                                  _expandedOrders.remove(i);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        _OrderDetailRow(label: 'Image', value: 'None'),
                                        _OrderDetailRow(label: 'Name', value: order.name),
                                        _OrderDetailRow(label: 'SKU', value: order.sku),
                                        _OrderDetailRow(label: 'REF-Code', value: order.refCode),
                                        _OrderDetailRow(label: 'QTY', value: order.qty.toString()),
                                        _OrderDetailRow(label: 'Price', value: order.price.toStringAsFixed(2)),
                                        Row(
                                          children: [
                                            const Text('Action', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'SF Pro Display', fontSize: 14)),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Color(0xFF007AFF)),
                                              onPressed: () async {
                                                setState(() => _isDialogOpen = true);
                                                final confirm = await showDeleteProductDialog(context);
                                                setState(() => _isDialogOpen = false);
                                                if (confirm == true) {
                                                  setState(() {
                                                    _orders.removeAt(i);
                                                    // Rebuild expanded set to match new indices
                                                    final updatedExpanded = <int>{};
                                                    for (final idx in _expandedOrders) {
                                                      if (idx < i) updatedExpanded.add(idx);
                                                      if (idx > i) updatedExpanded.add(idx - 1);
                                                    }
                                                    _expandedOrders
                                                      ..clear()
                                                      ..addAll(updatedExpanded);
                                                  });
                                                  setState(() => _isDialogOpen = true);
                                                  await showSuccessDialog(context);
                                                  setState(() => _isDialogOpen = false);
                                                }
                                              },
                                            ),
                                            const Text('Delete', style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 14)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _expandedOrders.add(i);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text('S.No', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'SF Pro Display', fontSize: 14)),
                                          const SizedBox(width: 8),
                                          Text((i + 1).toString(), style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 14)),
                                          const Spacer(),
                                          const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
                                        ],
                                      ),
                                    ),
                                  ),
                          );
                        }).toList(),
                      ),
                    ),
                  // Add Product Button or Customer Detail Row
                  _orders.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: OutlinedButton(
                            onPressed: () => _showSelectPlatformDialog(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5F5F7),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Please add Product',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.add_circle_outline, color: Color(0xFF222222), size: 22),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              const Text(
                                'Customer Detail',
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF222222), size: 22),
                                onPressed: () => _showSelectPlatformDialog(context),
                              ),
                            ],
                          ),
                        ),
                  // Customer Detail Section Header (if no product, show header as part of form)
                  if (_orders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Customer Detail',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   child: Column(
                     children: [
                       _OrderField(hint: 'Full Name'),
                       _OrderField(hint: 'Email'),
                       _OrderField(hint: 'Phone No', keyboardType: TextInputType.number),
                       _OrderField(hint: 'Order Reference Code'),
                       _OrderField(hint: 'Address'),
                       _OrderField(hint: 'Landmark'),
                       // Country (fixed)
                       Padding(
                         padding: const EdgeInsets.symmetric(vertical: 8),
                         child: TextField(
                           enabled: false,
                           controller: TextEditingController(text: selectedCountry),
                           decoration: InputDecoration(
                             labelText: 'Country',
                             filled: true,
                             fillColor: const Color(0xFFF5F5F7),
                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                             isDense: true,
                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                           ),
                           style: const TextStyle(fontSize: 16, color: Colors.black),
                         ),
                       ),
                       // City (from API)
                       Padding(
                         padding: const EdgeInsets.symmetric(vertical: 8),
                         child: _isLoadingCities
                             ? const Center(child: CircularProgressIndicator())
                             : GestureDetector(
                                 onTap: () async {
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
                                 },
                                 child: AbsorbPointer(
                                   child: TextFormField(
                                     controller: TextEditingController(text: selectedCity ?? ''),
                                     decoration: InputDecoration(
                                       labelText: 'City',
                                       filled: true,
                                       fillColor: const Color(0xFFF5F5F7),
                                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                       isDense: true,
                                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                       suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
                                     ),
                                     style: const TextStyle(fontSize: 16, color: Colors.black),
                                     readOnly: true,
                                   ),
                                 ),
                               ),
                       ),
                       _OrderField(hint: 'Latitude', keyboardType: TextInputType.number),
                       _OrderField(hint: 'Longitude', keyboardType: TextInputType.number),
                       _OrderField(hint: 'Weight', keyboardType: TextInputType.number),
                       _OrderField(hint: 'Shipping Charges'),
                       // Payment Type (fixed options)
                       Padding(
                         padding: const EdgeInsets.symmetric(vertical: 8),
                         child: DropdownButtonFormField<String>(
                           value: selectedPaymentType,
                           items: paymentTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                           onChanged: (val) => setState(() => selectedPaymentType = val ?? 'COD'),
                           decoration: InputDecoration(
                             labelText: 'Payment Type',
                             filled: true,
                             fillColor: const Color(0xFFF5F5F7),
                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                             isDense: true,
                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                           ),
                           style: const TextStyle(fontSize: 16, color: Colors.black),
                           icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
                         ),
                       ),
                       _OrderField(hint: 'Remarks'),
                     ],
                   ),
                 ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF007AFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32), // Extra padding for FAB/nav bar
                  SafeArea(child: SizedBox()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0A253B),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _isDialogOpen ? null : dash.CustomBottomNavBar(
        selectedIndex: 3,
        onHomeTap: () {
          Get.offAll(() => dash.DashboardScreen());
        },
        onMenuTap: () {
          Get.offAll(() => menu.MenuScreen());
        },
        onReportsTap: () {
          Get.offAll(() => report.ReportsScreen());
        },
      ),
    );
  }
}

class _OrderField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  const _OrderField({required this.hint, this.controller, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
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
      ),
    );
  }
}

class _OrderDropdownField extends StatelessWidget {
  final String hint;
  final List<String> items;
  final String? value;
  final void Function(String?)? onChanged;
  const _OrderDropdownField({required this.hint, required this.items, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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

class _OrderDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _OrderDetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'SF Pro Display', fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 14))),
        ],
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
            const Text('Select City', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search city...',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: filteredCities.isEmpty
                  ? const Center(child: Text('No cities found.'))
                  : ListView.builder(
                      itemCount: filteredCities.length,
                      itemBuilder: (context, i) {
                        final city = filteredCities[i];
                        return ListTile(
                          title: Text(city),
                          selected: city == selected,
                          onTap: () {
                            Navigator.of(context).pop(city);
                          },
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