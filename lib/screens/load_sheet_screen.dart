import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'report.dart' as report;
import 'dashboard_screen.dart' as dash;
import 'menu.dart' as menu;
import 'order_list_screen.dart' as order_list;
import 'search_screen.dart';
import '../utils/Layout/app_bottom_bar.dart';
import '../services/load_sheet_service.dart';
import '../services/auth_service.dart';
import '../models/load_sheet_model.dart';
import '../models/load_sheet_detail_model.dart';
import '../utils/custom_snackbar.dart';
import 'calendar_screen.dart';
import '../widgets/custom_date_selector.dart';

class LoadSheetScreen extends StatefulWidget {
  const LoadSheetScreen({Key? key}) : super(key: key);

  @override
  State<LoadSheetScreen> createState() => _LoadSheetScreenState();
}

class _LoadSheetScreenState extends State<LoadSheetScreen> {
  final LoadSheetService _loadSheetService = LoadSheetService();
  final AuthService _authService = Get.find<AuthService>();
  
  List<LoadSheetModel> _loadSheets = [];
  bool _isLoading = true;
  String? _error;
  String? _currentAcno;
  // Search state
  String? _searchQuery;
  List<LoadSheetModel> _filteredLoadSheets = [];
  final TextEditingController _searchController = TextEditingController();
  
  // Date range for filtering
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAcno();
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

  Future<void> _loadCurrentUserAcno() async {
    final user = _authService.currentUser.value;
    if (user != null) {
      setState(() {
        _currentAcno = user.acno;
      });
      await _loadLoadSheets();
    } else {
      setState(() {
        _error = 'User not found';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLoadSheets() async {
    if (_currentAcno == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final loadSheets = await _loadSheetService.getLoadSheets(
        acno: _currentAcno,
        startDate: _startDate.toIso8601String().split('T')[0],
        endDate: _endDate.toIso8601String().split('T')[0],
      );

      setState(() {
        _loadSheets = loadSheets;
        _applySearch();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      customSnackBar('Error', 'Failed to load sheets: ${e.toString()}');
    }
  }

  void _applySearch() {
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      print('Search query: \' ${_searchQuery}\'');
      for (final sheet in _loadSheets) {
        print('sheetNo: \' ${sheet.sheetNo}\', courierName: \' ${sheet.courierName}\', courierId: \' ${sheet.courierId}\', consignmentNo: \' ${sheet.consignmentNo}\', accountTitle: \' ${sheet.accountTitle}\'');
      }
      _filteredLoadSheets = _loadSheets.where((sheet) {
        final query = _searchQuery!.toLowerCase();
        return sheet.sheetNo.toLowerCase().contains(query) ||
               sheet.courierName.toLowerCase().contains(query) ||
               (sheet.courierId?.toLowerCase() ?? '').contains(query) ||
               (sheet.consignmentNo ?? '').toLowerCase().contains(query) ||
               sheet.accountTitle.toLowerCase().contains(query);
      }).toList();
    } else {
      _filteredLoadSheets = _loadSheets;
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadLoadSheets();
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Load Sheet',
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
                await _loadLoadSheets();
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
                  hintText: 'Search by sheet no, courier, account, CN, ...',
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
              bottomNavigationBar: const AppBottomBar(selectedIndex: 2),
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? FloatingActionButton(
              onPressed: () {
                // Add new load sheet functionality
                customSnackBar('Info', 'Add load sheet functionality not implemented yet');
              },
              backgroundColor: const Color(0xFF0A253B),
              child: const Icon(Icons.edit_rounded, color: Colors.white),
              elevation: 4,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLoadSheets,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final list = (_searchQuery != null && _searchQuery!.isNotEmpty) ? _filteredLoadSheets : _loadSheets;
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No load sheets found for the selected date range.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 90), // Extra space for bottom nav and FAB
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Load Sheet: ${list.length.toString().padLeft(2, '0')}',
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, i) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final sheet = list[i];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Table(
                        columnWidths: const {
                          0: FixedColumnWidth(100), // Adjust width as needed
                          1: FlexColumnWidth(),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(children: [
                            Text('S.No', style: _labelStyle),
                            Text('${i + 1}', style: _valueStyle),
                          ]),
                          TableRow(children: [
                            Text('Sheet No', style: _labelStyle),
                            Text(sheet.sheetNo, style: _valueStyle),
                          ]),
                          TableRow(children: [
                            Text('Date', style: _labelStyle),
                            Text(_formatDate(sheet.createdAt), style: _valueStyle),
                          ]),
                          TableRow(children: [
                            Text('Shipments', style: _labelStyle),
                            Text(sheet.shipmentCount, style: _valueStyle),
                          ]),
                          TableRow(children: [
                            Text('Account', style: _labelStyle),
                            Text(sheet.accountTitle, style: _valueStyle),
                          ]),
                          TableRow(children: [
                            Text('Courier', style: _labelStyle),
                            Text(sheet.courierName, style: _valueStyle),
                          ]),
                          if (sheet.consignmentNo != null && sheet.consignmentNo!.isNotEmpty)
                            TableRow(children: [
                              Text('CN', style: _labelStyle),
                              Text(sheet.consignmentNo!, style: _valueStyle),
                            ]),
                          TableRow(children: [
                            Text('Action', style: _labelStyle),
                            GestureDetector(
                              onTap: () {
                                _showLoadSheetDetails(sheet);
                              },
                              child: Row(
                                children: const [
                                  Icon(Icons.edit_rounded, color: Color(0xFF007AFF)),
                                  SizedBox(width: 4),
                                  Text('Edit', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}-${date.month}-${date.year}';
    } catch (e) {
      return dateString;
    }
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

  void _showLoadSheetDetails(LoadSheetModel sheet) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _LoadsheetDetailsBottomSheet(
          sheet: sheet,
          onDelete: () async {
            Navigator.of(context).pop();
            await _deleteLoadSheet(sheet);
          },
        );
      },
    );
  }

  Future<void> _deleteLoadSheet(LoadSheetModel sheet) async {
    try {
      print('Delete load sheet called for sheet: ${sheet.id}');
      print('Current acno: $_currentAcno');
      
      // Get the consignment number from the detailed API
      List<LoadSheetDetailModel> details = [];
      try {
        details = await _loadSheetService.getLoadSheetDetails(
          sheetNo: sheet.sheetNo,
          acno: _currentAcno,
        );
      } catch (e) {
        print('Error fetching details for deletion: $e');
        customSnackBar('Error', 'Failed to fetch load sheet details for deletion');
        return;
      }

      if (details.isEmpty) {
        customSnackBar('Error', 'No items found in load sheet for deletion');
        return;
      }

      // Use the first item's consignment number for deletion
      final consignmentNo = details.first.consignmentNo;
      final orderId = int.tryParse(details.first.orderId);
      
      if (consignmentNo.isEmpty) {
        customSnackBar('Error', 'Consignment number not available for deletion');
        print('Error: Consignment number is empty');
        return;
      }

      if (orderId == null) {
        customSnackBar('Error', 'Invalid order ID for deletion');
        print('Error: Invalid order ID: ${details.first.orderId}');
        return;
      }

      print('Calling delete API with orderId: $orderId, consignmentNo: $consignmentNo');

      final success = await _loadSheetService.deleteLoadSheet(
        orderId: orderId,
        consignmentNo: consignmentNo,
        acno: _currentAcno,
      );

      print('Delete API response: $success');

      if (success) {
        customSnackBar('Success', 'Load sheet deleted successfully!');
        // Refresh the load sheets list
        await _loadLoadSheets();
      } else {
        customSnackBar('Error', 'Failed to delete load sheet');
      }
    } catch (e) {
      print('Exception in delete load sheet: $e');
      customSnackBar('Error', 'Failed to delete load sheet: ${e.toString()}');
    }
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(width: 32),
          Text(value, style: _valueStyle),
        ],
      ),
    );
  }
}

const _labelStyle = TextStyle(
  fontFamily: 'SF Pro Display',
  fontWeight: FontWeight.w500,
  fontSize: 14,
  color: Colors.black,
);

const _valueStyle = TextStyle(
  fontFamily: 'SF Pro Display',
  fontWeight: FontWeight.w400,
  fontSize: 14,
  color: Colors.black,
);

class _LoadsheetDetailsBottomSheet extends StatefulWidget {
  final LoadSheetModel sheet;
  final VoidCallback onDelete;

  const _LoadsheetDetailsBottomSheet({
    Key? key,
    required this.sheet,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<_LoadsheetDetailsBottomSheet> createState() => _LoadsheetDetailsBottomSheetState();
}

class _LoadsheetDetailsBottomSheetState extends State<_LoadsheetDetailsBottomSheet> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Loadsheet Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow('Sheet ID', widget.sheet.id),
          _detailRow('Sheet No', widget.sheet.sheetNo),
          _detailRow('Courier', widget.sheet.courierName),
          _detailRow('Account', widget.sheet.accountTitle),
          _detailRow('Shipments', widget.sheet.shipmentCount),
          if (widget.sheet.consignmentNo != null && widget.sheet.consignmentNo!.isNotEmpty)
            _detailRow('Consignment No', widget.sheet.consignmentNo!),
          _detailRow('Created At', _formatDate(widget.sheet.createdAt)),
          if (widget.sheet.consignmentNo != null && widget.sheet.consignmentNo!.isNotEmpty)
            _detailRow('Consignment No', widget.sheet.consignmentNo!),
          
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Action', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () async {
                  final confirmed = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _DeleteConfirmationBottomSheet(),
                  );
                  if (confirmed == true) {
                    Navigator.of(context).pop(); // Close the details bottom sheet
                    // Call the actual delete function
                    widget.onDelete();
                  }
                },
                child: Row(
                  children: const [
                    Icon(Icons.delete_rounded, color: Color(0xFF007AFF)),
                    SizedBox(width: 4),
                    Text('Delete', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro Display',
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontFamily: 'SF Pro Display',
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}-${date.month}-${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class _DeleteConfirmationBottomSheet extends StatelessWidget {
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
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(24),
              child: Icon(Icons.delete_rounded, size: 56, color: Color(0xFF007AFF)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Are you Sure',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'SF Pro Display',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'You want to delete this load sheet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                fontFamily: 'SF Pro Display',
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: const Color(0xFF111827),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('No', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteSuccessBottomSheet extends StatelessWidget {
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
              'You have successfully deleted load sheet',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Color(0xFF8E8E93)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
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