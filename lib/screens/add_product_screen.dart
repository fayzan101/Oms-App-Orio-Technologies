import 'package:flutter/material.dart';
import 'dashboard_screen.dart' as dash;
import 'report.dart' as report;
import 'menu.dart' as menu;
import 'package:flutter/services.dart'; // Added for SystemChrome
import 'create_order.dart';
import '../services/statement_service.dart';

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
  String selectedProduct = 'Product Name';
  final TextEditingController skuController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  List<String> productList = [];
  final TextEditingController searchController = TextEditingController();
  
  // Platform data
  List<Map<String, dynamic>> platforms = [];
  Map<String, dynamic>? selectedPlatform;
  
  bool _isLoadingProducts = false;
  bool _isLoadingPlatforms = false;
  String? _productError;
  String? _platformError;

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
      final platformData = await service.fetchShopNames('OR-00009');
      print('Add product screen received platform data: $platformData');
      print('Platform data length: ${platformData.length}');
      
      setState(() {
        platforms = platformData;
        _isLoadingPlatforms = false;
      });
      print('Platforms list updated: $platforms');
    } catch (e) {
      print('Error fetching platforms: $e');
      setState(() {
        _platformError = 'Failed to load platforms: $e';
        _isLoadingPlatforms = false;
      });
    }
  }

  Future<void> _fetchProducts() async {
    if (selectedPlatform == null) {
      setState(() {
        _productError = 'Please select a platform first';
      });
      return;
    }
    
    setState(() {
      _isLoadingProducts = true;
      _productError = null;
    });
    
    try {
      final service = StatementService();
      final platformId = int.tryParse(selectedPlatform!['id']?.toString() ?? '');
      final customerPlatformId = selectedPlatform!['customer_platform_id'] != null 
          ? int.tryParse(selectedPlatform!['customer_platform_id']?.toString() ?? '')
          : null;
      
      if (platformId == null) {
        setState(() {
          _productError = 'Invalid platform ID';
          _isLoadingProducts = false;
        });
        return;
      }
      
      final productData = await service.fetchProductSuggestions(
        acno: 'OR-00009',
        platformId: platformId,
        customerPlatformId: customerPlatformId,
      );
      print('Add product screen received product data: $productData');
      print('Product data length: ${productData.length}');
      print('Using platform_id: $platformId, customer_platform_id: $customerPlatformId');
      
      final productNames = productData.map((e) => e['name']?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      print('Extracted product names: $productNames');
      print('Product names length: ${productNames.length}');
      
      setState(() {
        productList = productNames;
        _isLoadingProducts = false;
      });
      print('Product list updated: $productList');
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        _productError = 'Failed to load products: $e';
        _isLoadingProducts = false;
      });
    }
  }

  void _showPlatformPicker() async {
    if (_isLoadingPlatforms) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Loading platforms...'),
            ],
          ),
        ),
      );
      return;
    }

    if (_platformError != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(_platformError!),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchPlatforms(); // Retry
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

    if (platforms.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Platforms'),
          content: const Text('No platforms available. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchPlatforms(); // Retry
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

    Map<String, dynamic>? picked = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                  const Text('Select Platform', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w700, fontSize: 18)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, size: 24, color: Color(0xFF222222)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: platforms.length,
                  separatorBuilder: (context, i) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
                  itemBuilder: (context, i) {
                    final platform = platforms[i];
                    return ListTile(
                      title: Text(
                        platform['platform_name']?.toString() ?? 'Unknown Platform',
                        style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 15)
                      ),
                      subtitle: Text(
                        'ID: ${platform['id']}',
                        style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 12, color: Color(0xFF6B6B6B))
                      ),
                      onTap: () => Navigator.of(context).pop(platform),
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        selectedPlatform = picked;
        selectedProduct = 'Product Name'; // Reset product selection
        productList = []; // Clear previous products
      });
      // Fetch products for the selected platform
      _fetchProducts();
    }
  }

  void _showProductPicker() async {
    if (_isLoadingProducts) {
      // Show loading dialog
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
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(_productError!),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchProducts(); // Retry
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
      // Show empty state dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Products'),
          content: const Text('No products available. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchProducts(); // Retry
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
        return StatefulBuilder(
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform Selection
            if (_isLoadingPlatforms)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (_platformError != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _platformError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              )
            else
              GestureDetector(
                onTap: _showPlatformPicker,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedPlatform?['platform_name'] ?? 'Select Platform',
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
            
            // Product Selection (only show if platform is selected)
            if (selectedPlatform != null)
              GestureDetector(
                onTap: _showProductPicker,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedProduct,
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
            _ProductField(hint: 'SKU Code', controller: skuController),
            _ProductField(
              hint: 'Price',
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(10),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final order = OrderItem(
                    name: selectedProduct,
                    sku: skuController.text,
                    refCode: '079586', // You can generate or get this from input
                    qty: quantity,
                    price: double.tryParse(priceController.text) ?? 0.0,
                  );
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 48),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF5FF),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(24),
                              child: const Icon(Icons.check, color: Color(0xFF007AFF), size: 56),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Success!',
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Product add successfully',
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Color(0xFF222222),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // close dialog
                                  Navigator.of(context).pop(order); // close add product and return order
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF007AFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Ok',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
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
          ],
        ),
      ),
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
        child: const Icon(Icons.edit, color: Colors.white, size: 28),
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