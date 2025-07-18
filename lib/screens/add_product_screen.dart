import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart' as dash;
import 'report.dart' as report;
import 'menu.dart' as menu;
import 'package:flutter/services.dart'; // Added for SystemChrome
import 'create_order.dart';
import '../services/statement_service.dart';
import '../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart'; // Added for GoogleFonts

class AddProductScreen extends StatefulWidget {
  final int? platformId;
  final int? customerPlatformId;
  
  const AddProductScreen({
    Key? key, 
    this.platformId,
    this.customerPlatformId,
  }) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  int quantity = 1;
  String selectedProduct = '';
  final TextEditingController skuController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  List<String> productList = [];
  final TextEditingController searchController = TextEditingController();
  bool _isLoadingProducts = false;
  String? _productError;
  final AuthService _authService = Get.find<AuthService>();
  List<Map<String, dynamic>> productData = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productError = null;
    });
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        setState(() {
          _productError = 'User not logged in';
          _isLoadingProducts = false;
        });
        return;
      }
      final service = StatementService();
      final data = await service.fetchProductSuggestions(
        acno: acno,
        platformId: widget.platformId ?? 0,
        customerPlatformId: widget.customerPlatformId,
      );
      setState(() {
        productData = data;
        productList = data.map((e) => e['product_name']?.toString() ?? '').where((e) => e.isNotEmpty).toList();
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _productError = 'Failed to load products: $e';
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _showProductPicker() async {
    if (_isLoadingProducts) {
      return;
    }
    if (_productError != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(_productError!),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchProducts();
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      return;
    }
    if (productList.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Products'),
          content: const Text('No products available. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchProducts();
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      return;
    }
    String? picked = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        List<String> filtered = List.from(productList);
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Product',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF0A253B)),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close, size: 24, color: Color(0xFF007AFF)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: searchController,
                    onChanged: (val) {
                      filtered = productList.where((p) => p.toLowerCase().contains(val.toLowerCase())).toList();
                      (context as Element).markNeedsBuild();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search product',
                      hintStyle: GoogleFonts.poppins(color: Color(0xFF6B6B6B), fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF007AFF)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF007AFF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF007AFF), width: 2),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 15, color: Color(0xFF0A253B)),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 250,
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No products found',
                                style: GoogleFonts.poppins(fontSize: 16, color: Color(0xFF6B6B6B)),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            separatorBuilder: (context, i) => const Divider(height: 1, color: Color(0xFFB3D4FC)),
                            itemBuilder: (context, i) {
                              return ListTile(
                                title: Text(filtered[i], style: GoogleFonts.poppins(fontSize: 15, color: Color(0xFF0A253B))),
                                onTap: () => Navigator.of(context).pop(filtered[i]),
                                contentPadding: EdgeInsets.zero,
                                trailing: Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF007AFF), size: 18),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedProduct = picked;
        // Optionally, update price/sku fields here if you want to auto-fill
      });
      // Do NOT pop here!
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Product Selection (modern style)
            GestureDetector(
              onTap: _showProductPicker,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedProduct.isEmpty ? 'Select Product' : selectedProduct,
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
                  ],
                ),
              ),
            ),
            // SKU Code
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[300]!, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: skuController,
                decoration: InputDecoration(
                  hintText: 'SKU Code',
                  hintStyle: GoogleFonts.poppins(color: Color(0xFF6B6B6B), fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 15, color: Colors.black),
              ),
            ),
            // Price
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[300]!, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Price',
                  hintStyle: GoogleFonts.poppins(color: Color(0xFF6B6B6B), fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 15, color: Colors.black),
              ),
            ),
            // Quantity (with + and - icons)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[300]!, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Color(0xFF222222)),
                    splashRadius: 20,
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) quantity--;
                      });
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF222222)),
                    splashRadius: 20,
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Add Button
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedProduct.isEmpty || skuController.text.isEmpty || priceController.text.isEmpty || quantity < 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields and select a product.')),
                    );
                    return;
                  }
                  final selectedProductObj = productData.firstWhere(
                    (p) => p['product_name']?.toString().trim().toLowerCase() == selectedProduct.trim().toLowerCase(),
                    orElse: () => <String, dynamic>{},
                  );
                  if (selectedProductObj.isNotEmpty) {
                    final productId = selectedProductObj['id']?.toString() ?? '';
                    final locationId = selectedProductObj['location_id']?.toString() ?? '';
                    final refCode = selectedProductObj['ref_code']?.toString() ?? '';
                    Navigator.of(context).pop(OrderItem(
                      name: selectedProduct,
                      sku: selectedProductObj['sku'] ?? '',
                      refCode: refCode,
                      qty: quantity,
                      price: double.tryParse(priceController.text) ?? 0,
                      productCode: selectedProductObj['id']?.toString() ?? '',
                      variationId: selectedProductObj['variation_id']?.toString() ?? '',
                      productId: productId,
                      locationId: locationId,
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add',
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
            Center(
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'Add Custom Item',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF222222),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            // Add more fields as needed...
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: dash.CustomBottomNavBar(
        selectedIndex: 3,
        onHomeTap: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onReportsTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => report.ReportsScreen()),
            (route) => false,
          );
        },
        onMenuTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => menu.MenuScreen()),
            (route) => false,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0A253B),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _ProductField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  const _ProductField({required this.hint, this.controller, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Color(0xFF6B6B6B), fontSize: 13),
          filled: true,
          fillColor: Color(0xFFF5F5F7),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }
} 