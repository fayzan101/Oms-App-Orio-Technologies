class StatementModel {
  final String acno;
  final String startDate;
  final String endDate;
  final int? courierId;
  final int? customerCourierId;
  final List<StatementItem> items;
  final StatementSummary summary;

  StatementModel({
    required this.acno,
    required this.startDate,
    required this.endDate,
    this.courierId,
    this.customerCourierId,
    required this.items,
    required this.summary,
  });

  factory StatementModel.fromJson(Map<String, dynamic> json) {
    return StatementModel(
      acno: json['acno'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      courierId: json['courier_id'],
      customerCourierId: json['customer_courier_id'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => StatementItem.fromJson(item))
          .toList() ?? [],
      summary: StatementSummary.fromJson(json['summary'] ?? {}),
    );
  }

  // Factory method to create from API response payload (List)
  factory StatementModel.fromApiResponse(List<dynamic> payload, {
    required String acno,
    required String startDate,
    required String endDate,
    int? courierId,
    int? customerCourierId,
  }) {
    return StatementModel(
      acno: acno,
      startDate: startDate,
      endDate: endDate,
      courierId: courierId,
      customerCourierId: customerCourierId,
      items: payload.map((item) => StatementItem.fromJson(item)).toList(),
      summary: StatementSummary.fromItems(payload),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acno': acno,
      'start_date': startDate,
      'end_date': endDate,
      'courier_id': courierId,
      'customer_courier_id': customerCourierId,
      'items': items.map((item) => item.toJson()).toList(),
      'summary': summary.toJson(),
    };
  }
}

class StatementItem {
  final String id;
  final String orderNumber;
  final String customerName;
  final String courierName;
  final String status;
  final double amount;
  final String date;
  final String? trackingNumber;
  final String? notes;

  StatementItem({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.courierName,
    required this.status,
    required this.amount,
    required this.date,
    this.trackingNumber,
    this.notes,
  });

  factory StatementItem.fromJson(Map<String, dynamic> json) {
    return StatementItem(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number'] ?? '',
      customerName: json['customer_name'] ?? '',
      courierName: json['courier_name'] ?? '',
      status: json['status'] ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      date: json['date'] ?? '',
      trackingNumber: json['tracking_number'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_name': customerName,
      'courier_name': courierName,
      'status': status,
      'amount': amount,
      'date': date,
      'tracking_number': trackingNumber,
      'notes': notes,
    };
  }
}

class StatementSummary {
  final int totalOrders;
  final double totalAmount;
  final int totalDelivered;
  final int totalPending;
  final int totalFailed;
  final double totalOutstanding;
  final double totalCollected;

  StatementSummary({
    required this.totalOrders,
    required this.totalAmount,
    required this.totalDelivered,
    required this.totalPending,
    required this.totalFailed,
    required this.totalOutstanding,
    required this.totalCollected,
  });

  factory StatementSummary.fromJson(Map<String, dynamic> json) {
    return StatementSummary(
      totalOrders: json['total_orders'] ?? 0,
      totalAmount: (json['total_amount'] is num) ? (json['total_amount'] as num).toDouble() : 0.0,
      totalDelivered: json['total_delivered'] ?? 0,
      totalPending: json['total_pending'] ?? 0,
      totalFailed: json['total_failed'] ?? 0,
      totalOutstanding: (json['total_outstanding'] is num) ? (json['total_outstanding'] as num).toDouble() : 0.0,
      totalCollected: (json['total_collected'] is num) ? (json['total_collected'] as num).toDouble() : 0.0,
    );
  }

  // Factory method to create summary from items list
  factory StatementSummary.fromItems(List<dynamic> items) {
    int totalOrders = items.length;
    double totalAmount = 0.0;
    int totalDelivered = 0;
    int totalPending = 0;
    int totalFailed = 0;
    double totalOutstanding = 0.0;
    double totalCollected = 0.0;

    for (var item in items) {
      final itemData = item as Map<String, dynamic>;
      final amount = (itemData['amount'] is num) ? (itemData['amount'] as num).toDouble() : 0.0;
      final status = (itemData['status'] as String?)?.toLowerCase() ?? '';
      
      totalAmount += amount;
      
      switch (status) {
        case 'delivered':
          totalDelivered++;
          totalCollected += amount;
          break;
        case 'pending':
          totalPending++;
          totalOutstanding += amount;
          break;
        case 'failed':
          totalFailed++;
          totalOutstanding += amount;
          break;
        default:
          totalPending++;
          totalOutstanding += amount;
          break;
      }
    }

    return StatementSummary(
      totalOrders: totalOrders,
      totalAmount: totalAmount,
      totalDelivered: totalDelivered,
      totalPending: totalPending,
      totalFailed: totalFailed,
      totalOutstanding: totalOutstanding,
      totalCollected: totalCollected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_orders': totalOrders,
      'total_amount': totalAmount,
      'total_delivered': totalDelivered,
      'total_pending': totalPending,
      'total_failed': totalFailed,
      'total_outstanding': totalOutstanding,
      'total_collected': totalCollected,
    };
  }
} 