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
import 'order_list_screen.dart';
import 'package:dio/dio.dart';

class OrderItem {
  final String name;
  final String sku;
  final String refCode;
  final int qty;
  final double price;
  final String productCode;
  final String variationId;
  final String productId;
  final String locationId;
  OrderItem({
    required this.name,
    required this.sku,
    required this.refCode,
    required this.qty,
    required this.price,
    required this.productCode,
    required this.variationId,
    required this.productId,
    required this.locationId,
  });
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
  // Keys for each order field for validation
  final List<GlobalKey<_OrderFieldState>> _orderFieldKeys = List.generate(11, (_) => GlobalKey<_OrderFieldState>());
  // In _CreateOrderScreenState, add controllers for each field
  final List<TextEditingController> _controllers = List.generate(11, (_) => TextEditingController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> cityListData = [];

  @override
  void initState() {
    super.initState();
    _fetchCities();
    _fetchPlatforms();
  }

  Future<void> _fetchCities() async {
    setState(() { _isLoadingCities = true; });
    try {
      // Use a default country_id for now, or make it dynamic if you have a country dropdown
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
          cityListData = cityObjs;
          if (cityList.isNotEmpty) selectedCity = cityList.first;
          _isLoadingCities = false;
        });
      } else {
        setState(() { _isLoadingCities = false; });
      }
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
              backgroundColor: Colors.white, // White background
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
                          child: const Icon(Icons.close, size: 24, color: Color(0xFF007AFF)), // Blue close icon
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select Platform',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(0xFF0A253B), // Dark blue text
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Platform',
                        hintStyle: GoogleFonts.poppins(color: Color(0xFF6B6B6B)),
                        prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF007AFF)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF007AFF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF007AFF), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      ),
                      style: GoogleFonts.poppins(fontSize: 16, color: Color(0xFF0A253B)),
                      onChanged: (val) {
                        setState(() {
                          search = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _isLoadingPlatforms
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF007AFF)))
                        : _platformError != null
                            ? Text(_platformError!, style: GoogleFonts.poppins(color: Colors.red))
                            : filteredPlatforms.isEmpty
                                ? Text('No platforms found.', style: GoogleFonts.poppins(color: Color(0xFF0A253B)))
                                : SizedBox(
                                    height: 200,
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: filteredPlatforms.length,
                                      separatorBuilder: (context, i) => const Divider(height: 1, color: Color(0xFFB3D4FC)),
                                      itemBuilder: (context, i) {
                                        final platform = filteredPlatforms[i];
                                        return ListTile(
                                          title: Text(
                                            platform['platform_name']?.toString() ?? 'Unknown Platform',
                                            style: GoogleFonts.poppins(fontSize: 15, color: Color(0xFF0A253B)),
                                          ),
                                          subtitle: Text(
                                            'ID: ${platform['id']}',
                                            style: GoogleFonts.poppins(fontSize: 12, color: Color(0xFF007AFF)),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedPlatform = platform;
                                            });
                                            Navigator.of(context).pop();
                                            _showAddProductScreen(context);
                                          },
                                          contentPadding: EdgeInsets.zero,
                                          trailing: Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF007AFF), size: 18),
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
    bool hasError = false;
    if (_orders.isEmpty) {
      customSnackBar('Error', 'Please add at least one product');
      hasError = true;
    }
    if (selectedCity == null || selectedCity!.isEmpty) {
      customSnackBar('Error', 'Please select a city');
      hasError = true;
    }
    // Validate all fields using Form
    if (_formKey.currentState != null) {
      if (!_formKey.currentState!.validate()) {
        hasError = true;
      }
    }
    if (hasError) return;
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
        Get.offAll(() => OrderListScreen());
      } else {
        customSnackBar('Error', response['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      customSnackBar('Error', 'Failed to create order: ${e.toString()}');
    } finally {
      setState(() { _isSaving = false; });
    }
  }

  Future<void> _createOrder() async {
    try {
      // Extract from form fields/controllers
      final remarks = _controllers[10].text.trim();
      final shippingCharges = double.tryParse(_controllers[9].text.trim()) ?? 0;
      final consigneeLatitude = double.tryParse(_controllers[6].text.trim()) ?? 0;
      final consigneeLongitude = double.tryParse(_controllers[7].text.trim()) ?? 0;
      final weight = double.tryParse(_controllers[8].text.trim()) ?? 0;
      final orderRef = _controllers[3].text.trim();
      final acno = _authService.getCurrentAcno();
      // Platform extraction with fallback to 0
      final platformId = int.tryParse(_selectedPlatform?['id']?.toString() ?? '') ?? 0;
      final storeName = _selectedPlatform?['platform_name']?.toString() ?? '';
      final dio = Dio();
      final product = _orders.isNotEmpty ? _orders.first : null;
      final productName = product?.name ?? '';
      final quantity = product?.qty ?? 0;
      final amount = product?.price ?? 0;
      final skuCode = product?.sku ?? '';
      final paymentMethodId = selectedPaymentType == 'CC' ? 2 : 1;
      // Shipper and billing details (hardcoded as per requirements)
      final shipperName = "DEMO";
      final shipperEmail = "demo@gmail.com";
      final shipperContact = "none";
      final shipperAddress = "Demo address";
      final billingName = "DEMO";
      final billingEmail = "demo@gmail.com";
      final billingContact = "none";
      final billingAddress = "Demo address";
      final orderDate = DateTime.now().toIso8601String().split('T')[0];
      // Product details, ensure all IDs are int, fallback to 0
      final productCode = product?.productCode ?? '';
      final variationId = int.tryParse(product?.variationId ?? '') ?? 0;
      final productId = int.tryParse(product?.productId ?? '') ?? 0;
      final locationId = int.tryParse(product?.locationId ?? '') ?? 0;
      final refcode = product?.refCode ?? '';
      // City extraction
      final cityName = selectedCity ?? '';
      final selectedCityObj = cityListData.firstWhere(
        (c) => c['city_name'] == cityName,
        orElse: () => <String, dynamic>{},
      );
      final originCountryId = int.tryParse(selectedCityObj['country_id']?.toString() ?? '') ?? 1;
      final originProvinceId = int.tryParse(selectedCityObj['province_id']?.toString() ?? '') ?? 1;
      final originCityId = int.tryParse(selectedCityObj['id']?.toString() ?? '') ?? 655;
      final destinationCountryId = int.tryParse(selectedCityObj['country_id']?.toString() ?? '') ?? 1;
      final destinationProvinceId = int.tryParse(selectedCityObj['province_id']?.toString() ?? '') ?? 1;
      final destinationCityId = int.tryParse(selectedCityObj['id']?.toString() ?? '') ?? 655;
      final piece = _orders.fold<int>(0, (sum, item) => sum + item.qty);
      final orderAmount = _orders.fold<double>(0, (sum, item) => sum + (item.qty * item.price));
      // Consignee details from form
      final consigneeName = _controllers[0].text.trim();
      final consigneeEmail = _controllers[1].text.trim();
      final consigneeContact = _controllers[2].text.trim();
      final consigneeAddress = _controllers[4].text.trim();
      final cnicNumber = "32323-2381822-3"; // Hardcoded as per requirements
      // Use a dynamic, valid token from AuthService if available
      final token = await _authService.getApiKey();
      final body = [
        {
          "acno": acno,
          "shipper_name": shipperName,
          "shipper_address": shipperAddress,
          "shipper_email": shipperEmail,
          "shipper_contact": shipperContact,
          "billingperson_name": billingName,
          "billingperson_address": billingAddress,
          "billingperson_email": billingEmail,
          "billingperson_contact": billingContact,
          "consignee_name": consigneeName,
          "consignee_address": consigneeAddress,
          "consignee_email": consigneeEmail,
          "consignee_contact": consigneeContact,
          "cnic_number": cnicNumber,
          "origin_country_id": originCountryId,
          "city_name": cityName,
          "origin_province_id": originProvinceId,
          "origin_city_id": originCityId,
          "destination_country_id": destinationCountryId,
          "destination_province_id": destinationProvinceId,
          "destination_city_id": destinationCityId,
          "piece": piece,
          "weight": weight,
          "order_amount": orderAmount,
          "order_ref": orderRef,
          "detail": [
            {
              "id": productCode,
              "product_code": productCode,
              "product_name": productName,
              "quantity": quantity,
              "amount": amount,
              "image_url": "none",
              "refcode": refcode,
              "variation": "XL",
              "sku_code": skuCode,
              "discount_amount": 0,
              "variation_id": variationId,
              "product_id": productId,
              "location_id": locationId
            }
          ],
          "platform_id": platformId,
          "store_name": storeName,
          "payment_method_id": paymentMethodId,
          "remarks": remarks,
          "shipping_charges": shippingCharges,
          "consignee_latitude": consigneeLatitude,
          "consignee_longitude": consigneeLongitude,
          "order_date": orderDate
        }
      ];
      // Debug: Print all key fields and their types
      print('--- DEBUG: ORDER CREATE REQUEST ---');
      print('acno: ${acno} (type: ${acno.runtimeType})');
      print('order_ref: ${orderRef} (type: ${orderRef.runtimeType})');
      print('consignee_contact: ${consigneeContact} (type: ${consigneeContact.runtimeType})');
      print('origin_country_id: ${originCountryId} (type: ${originCountryId.runtimeType})');
      print('origin_province_id: ${originProvinceId} (type: ${originProvinceId.runtimeType})');
      print('origin_city_id: ${originCityId} (type: ${originCityId.runtimeType})');
      print('destination_country_id: ${destinationCountryId} (type: ${destinationCountryId.runtimeType})');
      print('destination_province_id: ${destinationProvinceId} (type: ${destinationProvinceId.runtimeType})');
      print('destination_city_id: ${destinationCityId} (type: ${destinationCityId.runtimeType})');
      print('platform_id: ${platformId} (type: ${platformId.runtimeType})');
      print('payment_method_id: ${paymentMethodId} (type: ${paymentMethodId.runtimeType})');
      print('Headers:');
      print({'Content-Type': 'application/json', if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'});
      print('Request body:');
      print(body);
      print('--- END DEBUG ---');
      final response = await dio.post(
        'https://stagingoms.orio.digital/api/order/create',
        data: body,
        options: Options(headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        }),
      );
      print('Order create response: \nStatus: ${response.statusCode} \nData: ${response.data}');
      if (response.statusCode == 200 && (response.data['status'] == 1 || response.data['success'] == true)) {
        customSnackBar('Success', 'Order created successfully!');
        // Clear all form fields
        for (final controller in _controllers) {
          controller.clear();
        }
        // Reset dropdowns and selections
        setState(() {
          selectedCity = null;
          selectedPaymentType = 'COD';
          _selectedPlatform = null;
          _orders.clear();
          _expandedOrders.clear();
        });
        // Reset form validation state
        _formKey.currentState?.reset();
      } else {
        customSnackBar('Error', response.data['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      print('--- DEBUG: ERROR CAUGHT IN ORDER CREATE ---');
      print(e);
      customSnackBar('Error', 'Failed to create order: ${e.toString()}');
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
                  const SizedBox(height: 2),
                 Form(
                   key: _formKey,
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 16),
                     child: Column(
                       children: [
                         _OrderField(key: _orderFieldKeys[0], controller: _controllers[0], hint: 'Full Name', isRequired: true, prefixIcon: Icons.person_outline),
                         _OrderField(key: _orderFieldKeys[1], controller: _controllers[1], hint: 'Email', isRequired: true, keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
                         _OrderField(key: _orderFieldKeys[2], controller: _controllers[2], hint: 'Phone No', keyboardType: TextInputType.phone, isRequired: true, prefixIcon: Icons.phone_outlined),
                         _OrderField(key: _orderFieldKeys[3], controller: _controllers[3], hint: 'Order Reference Code', isRequired: true, prefixIcon: Icons.confirmation_number_outlined),
                         _OrderField(key: _orderFieldKeys[4], controller: _controllers[4], hint: 'Address', isRequired: true, prefixIcon: Icons.location_on_outlined),
                         _OrderField(key: _orderFieldKeys[5], controller: _controllers[5], hint: 'Landmark', isRequired: true, prefixIcon: Icons.landscape_outlined),
                         // Country (fixed)
                         Padding(
                           padding: const EdgeInsets.symmetric(vertical: 8),
                           child: Material(
                             elevation: 1.5,
                             shadowColor: Colors.black12,
                             borderRadius: BorderRadius.circular(12),
                             child: TextFormField(
                               enabled: false,
                               controller: TextEditingController(text: selectedCountry),
                               style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
                               decoration: InputDecoration(
                                 labelText: 'Country',
                                 labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.grey[700]),
                                 prefixIcon: Icon(Icons.flag_outlined, color: Colors.grey[600]),
                                 filled: true,
                                 fillColor: const Color(0xFFF5F5F7),
                                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                 isDense: true,
                               ),
                             ),
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
                                     child: Material(
                                       elevation: 1.5,
                                       shadowColor: Colors.black12,
                                       borderRadius: BorderRadius.circular(12),
                                       child: TextFormField(
                                         controller: TextEditingController(text: selectedCity ?? ''),
                                         style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
                                         decoration: InputDecoration(
                                           labelText: 'City',
                                           labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.grey[700]),
                                           prefixIcon: Icon(Icons.location_city_outlined, color: Colors.grey[600]),
                                           filled: true,
                                           fillColor: const Color(0xFFF5F5F7),
                                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                           isDense: true,
                                           suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
                                         ),
                                         readOnly: true,
                                       ),
                                     ),
                                   ),
                                 ),
                         ),
                         _OrderField(key: _orderFieldKeys[6], controller: _controllers[6], hint: 'Latitude', keyboardType: TextInputType.number, isRequired: true, prefixIcon: Icons.my_location_outlined),
                         _OrderField(key: _orderFieldKeys[7], controller: _controllers[7], hint: 'Longitude', keyboardType: TextInputType.number, isRequired: true, prefixIcon: Icons.my_location_outlined),
                         _OrderField(key: _orderFieldKeys[8], controller: _controllers[8], hint: 'Weight', keyboardType: TextInputType.number, isRequired: true, prefixIcon: Icons.scale_outlined),
                         _OrderField(key: _orderFieldKeys[9], controller: _controllers[9], hint: 'Shipping Charges', isRequired: true, prefixIcon: Icons.local_shipping_outlined),
                         _OrderDropdownField(
                           hint: 'Payment Type',
                           items: ['COD', 'CC'],
                           value: selectedPaymentType,
                           onChanged: (val) => setState(() => selectedPaymentType = val ?? 'COD'),
                           prefixIcon: Icons.payment,
                         ),
                         _OrderField(key: _orderFieldKeys[10], controller: _controllers[10], hint: 'Remarks', isRequired: true, prefixIcon: Icons.notes_outlined),
                       ],
                     ),
                   ),
                 ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _createOrder,
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
        onOrderListTap: () {
          Get.offAll(() => OrderListScreen());
        },
      ),
    );
  }
}

class _OrderField extends StatefulWidget {
  final String hint;
  final TextInputType? keyboardType;
  final bool isRequired;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  const _OrderField({Key? key, required this.hint, this.keyboardType, this.isRequired = false, this.controller, this.prefixIcon, this.suffixIcon}) : super(key: key);

  @override
  State<_OrderField> createState() => _OrderFieldState();
}

class _OrderFieldState extends State<_OrderField> {
  TextEditingController get _controller => widget.controller ?? _internalController;
  final TextEditingController _internalController = TextEditingController();
  bool _showError = false;

  @override
  void initState() {
    super.initState();
  }

  bool validate() {
    if (!widget.isRequired) return true;
    final isValid = _controller.text.trim().isNotEmpty;
    setState(() {
      _showError = !isValid;
    });
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // slightly reduced
      child: Material(
        elevation: 1.5,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        child: TextFormField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            labelText: widget.hint,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.grey[700]),
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: Colors.grey[600]) : null,
            suffixIcon: widget.suffixIcon != null ? Icon(widget.suffixIcon, color: Colors.grey[600]) : null,
            filled: true,
            fillColor: const Color(0xFFF5F5F7),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // reduced vertical padding
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF007AFF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (widget.isRequired && (value == null || value.trim().isEmpty)) {
              return 'Required';
            }
            return null;
          },
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
  final IconData? prefixIcon;
  const _OrderDropdownField({required this.hint, required this.items, this.value, this.onChanged, this.prefixIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // slightly reduced
      child: Material(
        elevation: 1.5,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        child: DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: GoogleFonts.poppins(fontSize: 16)),
          )).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: hint,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.grey[700]),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[600]) : null,
            filled: true,
            fillColor: const Color(0xFFF5F5F7),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // reduced vertical padding
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF007AFF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
        ),
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