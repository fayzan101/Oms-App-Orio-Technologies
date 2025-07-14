import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/Layout/app_bottom_bar.dart';
import '../services/rules_service.dart';
import '../services/auth_service.dart';
import 'create_rule_screen.dart';
import 'edit_rule_screen.dart';
import '../widgets/custom_date_selector.dart';
import '../utils/custom_snackbar.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({Key? key}) : super(key: key);

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  late RulesService _rulesService;
  String? _acno;
  
  // Search state
  String? _searchQuery;
  List<Map<String, dynamic>> _filteredRules = [];
  final TextEditingController _searchController = TextEditingController();
  
  // Date range for filtering
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // Expanded state for dropdown
  final Set<int> expanded = {};

  @override
  void initState() {
    super.initState();
    _initializeService();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applySearch();
    });
  }

  void _initializeService() {
    try {
      _rulesService = Get.find<RulesService>();
    } catch (e) {
      // If service is not found, create it
      _rulesService = Get.put(RulesService(Get.find<AuthService>()), permanent: true);
    }
    _loadAcnoAndFetchRules();
  }

  Future<void> _loadAcnoAndFetchRules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _acno = prefs.getString('acno');
      
      if (_acno != null) {
        await _rulesService.getRules(acno: _acno!);
      } else {
        print('RulesScreen: No acno found in SharedPreferences');
      }
    } catch (e) {
      print('RulesScreen: Error loading acno: $e');
    }
  }

  void _applySearch() {
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      _filteredRules = _rulesService.rules.where((rule) {
        final query = _searchQuery!.toLowerCase();
        return (rule['rule_name'] ?? '').toLowerCase().contains(query) ||
               (rule['rule_title'] ?? '').toLowerCase().contains(query) ||
               (rule['courier_name'] ?? '').toLowerCase().contains(query) ||
               (rule['service_code'] ?? '').toLowerCase().contains(query) ||
               (rule['platform_name'] ?? '').toLowerCase().contains(query);
      }).toList();
    } else {
      _filteredRules = _rulesService.rules;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 22),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Rules',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          if (_searchQuery != null && _searchQuery!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = null;
                  _applySearch();
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF007AFF)),
            onPressed: () {
              Get.to(() => const CreateRuleScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded, color: Colors.black),
            onPressed: () async {
              final picked = await showDialog<DateTimeRange>(
                context: context,
                barrierDismissible: true,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(24),
                    child: CustomDateSelector(
                      initialStartDate: _startDate,
                      initialEndDate: _endDate,
                    ),
                  ),
                ),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked.start;
                  _endDate = picked.end;
                });
                // Refresh rules with new date range
                if (_acno != null) {
                  await _rulesService.getRules(acno: _acno!);
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // --- Search Bar ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by rule name, title, courier, service...',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
            ),
            // --- End Search Bar ---
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? FloatingActionButton(
              onPressed: () {
                Get.to(() => const CreateRuleScreen());
              },
              backgroundColor: const Color(0xFF0A253B),
              child: const Icon(Icons.add_rounded, color: Colors.white),
              elevation: 4,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const AppBottomBar(selectedIndex: 2),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (_rulesService.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
          ),
        );
      }

      if (_rulesService.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Failed to load rules',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
              Text(
                _rulesService.errorMessage.value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _rulesService.clearError();
                  if (_acno != null) {
                    _rulesService.getRules(acno: _acno!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final list = (_searchQuery != null && _searchQuery!.isNotEmpty) ? _filteredRules : _rulesService.rules;
      
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rule_rounded, size: 120, color: Colors.grey[300]),
              const SizedBox(height: 24),
              Text(
                'No rules available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first rule to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => const CreateRuleScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Create Rule'),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Rules: ${list.length.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Text(
                _getDateRangeText(),
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (context, i) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final rule = list[i];
                final isExpanded = expanded.contains(i);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        expanded.remove(i);
                      } else {
                        expanded.add(i);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text('${rule['rule_name'] ?? 'Unnamed Rule'}'),
                          subtitle: Text(
                            '${rule['courier_name'] ?? 'N/A'} • ${rule['status'] == '1' ? 'Active' : 'Inactive'}',
                            style: TextStyle(
                              color: rule['status'] == '1' ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_rounded, color: Color(0xFF007AFF)),
                                onPressed: () {
                                  Get.to(() => EditRuleScreen(ruleData: rule));
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_rounded, color: Colors.red),
                                onPressed: () => _showDeleteConfirmation(rule),
                              ),
                              Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                            ],
                          ),
                        ),
                        if (isExpanded)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow('Rule ID', rule['id']),
                                _infoRow('Rule Title', rule['rule_title']),
                                _infoRow('Status', rule['status'] == '1' ? 'Active' : 'Inactive'),
                                _infoRow('Courier', rule['courier_name']),
                                _infoRow('Service Code', rule['service_code']),
                                _infoRow('Platform', rule['platform_name']),
                                _infoRow('Order Value', '${rule['order_value_type'] ?? ''} ${rule['order_value'] ?? '0'}'),
                                _infoRow('Weight', '${rule['weight_type'] ?? ''} ${rule['weight_value'] ?? '0'} kg'),
                                _infoRow('Courier ID', rule['courier_id']),
                                _infoRow('Customer Courier ID', rule['customer_courier_id']),
                                _infoRow('Status ID', rule['status_id']),
                                _infoRow('City List ID', rule['customer_citylist_id']),
                                _infoRow('Payment Method ID', rule['paymentmethod_id']),
                                _infoRow('Platform ID', rule['platform_id']),
                                _infoRow('Pickup ID', rule['pickup_id']),
                                if (rule['keywords_id'] != null)
                                  _infoRow('Keywords ID', rule['keywords_id']),
                                if (rule['is_contain'] != null)
                                  _infoRow('Is Contain', rule['is_contain']),
                              ],
              ),
            ),
          ],
        ),
      ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label: ',
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateRangeText() {
    final now = DateTime.now();
    final difference = now.difference(_startDate).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Last 1 day';
    } else if (difference <= 7) {
      return 'Last $difference days';
    } else if (difference <= 30) {
      final weeks = (difference / 7).round();
      return 'Last $weeks week${weeks > 1 ? 's' : ''}';
    } else if (difference <= 365) {
      final months = (difference / 30).round();
      return 'Last $months month${months > 1 ? 's' : ''}';
    } else {
      final years = (difference / 365).round();
      return 'Last $years year${years > 1 ? 's' : ''}';
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> rule) {
    showModalBottomSheet(
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F0FF),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(32),
                  child: const Icon(Icons.delete_rounded, color: Color(0xFF007AFF), size: 64),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Are you Sure',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  'You want to delete "${rule['rule_name'] ?? 'this rule'}"',
                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Color(0xFF8E8E93)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F2F7),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('No', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          if (_acno != null && rule['id'] != null) {
                            // Show processing snackbar
                            customSnackBar('Processing', 'Deleting rule...');
                            
                            final success = await _rulesService.deleteRule(
                              acno: _acno!,
                              ruleId: rule['id'].toString(),
                            );
                            
                            if (success) {
                              customSnackBar('Success', 'Rule deleted successfully');
                            } else {
                              customSnackBar('Error', _rulesService.errorMessage.value);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white)),
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
} 