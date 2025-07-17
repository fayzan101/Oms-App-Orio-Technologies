import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class BulkTrackingScreen extends StatefulWidget {
  final String? acno;
  final String? orderIds;
  final String? consignmentNos;
  const BulkTrackingScreen({Key? key, this.acno, this.orderIds, this.consignmentNos}) : super(key: key);

  @override
  State<BulkTrackingScreen> createState() => _BulkTrackingScreenState();
}

class _BulkTrackingScreenState extends State<BulkTrackingScreen> {
  bool isLoading = false;
  String? errorMessage;
  dynamic result;
  Set<int> expanded = {};

  @override
  void initState() {
    super.initState();
    // Automatically call API if all fields are present
    if ((widget.acno ?? '').isNotEmpty && (widget.orderIds ?? '').isNotEmpty && (widget.consignmentNos ?? '').isNotEmpty) {
      _autoTrack();
    }
  }

  Future<void> _autoTrack() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      result = null;
    });
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://oms.getorio.com/api/shipment/bulktracking',
        data: {
          'acno': widget.acno,
          'order_id': widget.orderIds,
          'consigment_no': widget.consignmentNos,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      setState(() {
        result = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch tracking info.';
        isLoading = false;
      });
    }
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Bulk Shipment Tracking',
        style: TextStyle(color: Colors.black), // Title text color
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.white,
      foregroundColor: Colors.black, // Icon (like back button) color
      surfaceTintColor: Colors.white,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : result != null
                  ? _buildResultList()
                  : const Center(
                      child: Text('No tracking results found.'),
                    ),
    ),
  );
}



  Widget _buildResultList() {
    List<dynamic> shipments;
    if (result is Map && result['payload'] is List) {
      shipments = result['payload'];
    } else if (result is List) {
      shipments = result;
    } else if (result is Map && result['data'] is List) {
      shipments = result['data'];
    } else if (result is Map && result['shipments'] is List) {
      shipments = result['shipments'];
    } else if (result != null) {
      shipments = [result];
    } else {
      return const Text('No tracking results found.');
    }
    if (shipments.isEmpty) {
      return const Text('No tracking results found.');
    }
    return ListView.separated(
      itemCount: shipments.length,
      separatorBuilder: (context, i) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final shipment = shipments[i];
        final status = shipment['status_name']?.toString() ?? shipment['status']?.toString() ?? '-';
        final consignmentNo = shipment['consigment_no']?.toString() ?? '-';
        final date = shipment['booking_date']?.toString() ?? shipment['created_at']?.toString() ?? '-';
        final consignee = shipment['consignee_name']?.toString() ?? '-';
        final amount = shipment['order_amount']?.toString() ?? '-';
        final origin = shipment['origin']?.toString() ?? '-';
        final destination = shipment['destination']?.toString() ?? '-';
        final detailList = shipment['detail'] as List<dynamic>? ?? [];
        Color statusColor = (status.toLowerCase() == 'booked' || status.toLowerCase() == 'pickup ready')
            ? const Color(0xFF1DA1F2)
            : Colors.grey;
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _infoRow('CN#', consignmentNo),
                _infoRow('Date', date),
                _infoRow('Customer', consignee),
                _infoRow('Amount', amount),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('From To', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 16),
                    Text('$origin   $destination', style: const TextStyle(fontWeight: FontWeight.w400)),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Courier Shipping Label: $consignmentNo', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                if (detailList.isEmpty)
                  const Text('No tracking history available.', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Color(0xFF6B7280))),
                ...detailList.map<Widget>((d) {
                  final status = d['status'] ?? '-';
                  final date = d['dateTime'] ?? '-';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '$date - $status',
                      style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF007AFF),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
} 