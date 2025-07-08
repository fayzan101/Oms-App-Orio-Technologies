import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart' as dash;
import 'menu.dart' as menu;
import 'report.dart' as report;
import 'package:flutter/services.dart';
import 'add_product_screen.dart';

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

  void _addOrder(OrderItem item) {
    setState(() {
      _orders.add(item);
    });
  }

  void _showSelectStoreDialog(BuildContext context) {
    String selectedStore = 'OMS';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      'Select Store',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedStore,
                        items: const [
                          DropdownMenuItem(value: 'OMS', child: Text('OMS')),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedStore = val ?? 'OMS';
                          });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
                        dropdownColor: Color(0xFFF5F5F7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddProductScreen(),
                            ),
                          );
                          if (result is OrderItem) {
                            _addOrder(result);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF007AFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Next',
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
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Create Order',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 1,
            color: Color(0xFFE0E0E0),
          ),
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
                                              onPressed: () {
                                                setState(() {
                                                  _orders.removeAt(i);
                                                  _expandedOrders.remove(i);
                                                });
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
                            onPressed: () => _showSelectStoreDialog(context),
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
                                onPressed: () => _showSelectStoreDialog(context),
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
                       _OrderField(hint: 'Phone'),
                       _OrderField(hint: 'Order Reference Code'),
                       _OrderField(hint: 'Address'),
                       _OrderField(hint: 'Landmark'),
                       _OrderDropdownField(hint: 'Destination Country', items: const ['USA', 'Canada', 'UK'], value: 'USA', onChanged: (val) {}),
                       _OrderDropdownField(hint: 'Destination City', items: const ['New York', 'Los Angeles', 'Chicago'], value: 'New York', onChanged: (val) {}),
                       _OrderField(hint: 'Latitude'),
                       _OrderField(hint: 'Longitude'),
                       _OrderField(hint: 'Weight'),
                       _OrderField(hint: 'Shipping Charges'),
                       _OrderDropdownField(hint: 'Payment Type', items: const ['Cash', 'Bank Transfer', 'Online Payment'], value: 'Cash', onChanged: (val) {}),
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF007AFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
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
      bottomNavigationBar: dash.CustomBottomNavBar(
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

class _OrderField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  const _OrderField({required this.hint, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
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
          disabledBorder: OutlineInputBorder(
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