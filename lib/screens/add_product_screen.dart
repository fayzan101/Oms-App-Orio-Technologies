import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart' as dash;
import 'report.dart' as report;
import 'menu.dart' as menu;
import 'package:flutter/services.dart'; // Added for SystemChrome
import 'create_order.dart';
import '../services/statement_service.dart';
import '../services/auth_service.dart';

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
      final productData = await service.fetchProductSuggestions(
        acno: acno,
        platformId: widget.platformId ?? 0,
        customerPlatformId: widget.customerPlatformId,
      );
      final productNames = productData.map((e) => e['product_name']?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      setState(() {
        productList = productNames;
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
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Loading products...'),
            ],
          ),
        ),
      );
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
    String? picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        List<String> filtered = List.from(productList);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Product Name', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w700, fontSize: 18)),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close, size: 24, color: Color(0xFF222222)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (val) {
                            setState(() {
                              filtered = productList.where((p) => p.toLowerCase().contains(val.toLowerCase())).toList();
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search, color: Color(0xFF222222)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: filtered.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No products found',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro Display',
                                      fontSize: 16,
                                      color: Color(0xFF6B6B6B),
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: filtered.length,
                                separatorBuilder: (context, i) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
                                itemBuilder: (context, i) {
                                  return ListTile(
                                    title: Text(filtered[i], style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 15)),
                                    onTap: () => Navigator.of(context).pop(filtered[i]),
                                    contentPadding: EdgeInsets.zero,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedProduct = picked;
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
                decoration: const InputDecoration(
                  hintText: 'SKU Code',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                decoration: const InputDecoration(
                  hintText: 'Price',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                  final order = OrderItem(
                    name: selectedProduct,
                    sku: skuController.text,
                    refCode: '079586', // You can generate or get this from input
                    qty: quantity,
                    price: double.tryParse(priceController.text) ?? 0.0,
                  );
                  Navigator.of(context).pop(order);
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