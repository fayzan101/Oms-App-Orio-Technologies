class DashboardReportingModel {
  final String acno;
  final int orders;
  final int sales;
  final int customers;
  final int productsold;
  final int totalOutstanding;
  final int totalCurrentOutstanding;
  final List<String> orderGraph;
  final List<String> revenueGraph;
  final List<String> productsoldGraph;
  final List<String> customerGraph;
  final List<String> outstandingGraph;
  final List<String> currentOutstandingGraph;
  final List<CourierPaymentData> paymentCourierPayment;
  final StatusSummary statusSummary;

  DashboardReportingModel({
    required this.acno,
    required this.orders,
    required this.sales,
    required this.customers,
    required this.productsold,
    required this.totalOutstanding,
    required this.totalCurrentOutstanding,
    required this.orderGraph,
    required this.revenueGraph,
    required this.productsoldGraph,
    required this.customerGraph,
    required this.outstandingGraph,
    required this.currentOutstandingGraph,
    required this.paymentCourierPayment,
    required this.statusSummary,
  });

  factory DashboardReportingModel.fromJson(Map<String, dynamic> json) {
    print('DashboardReportingModel.fromJson: Raw JSON: $json');
    
    final acno = json['acno']?.toString() ?? '';
    final orders = int.tryParse(json['orders']?.toString() ?? '0') ?? 0;
    final sales = int.tryParse(json['sales']?.toString() ?? '0') ?? 0;
    final customers = int.tryParse(json['customers']?.toString() ?? '0') ?? 0;
    final productsold = int.tryParse(json['productsold']?.toString() ?? '0') ?? 0;
    final totalOutstanding = int.tryParse(json['total_outstanding']?.toString() ?? '0') ?? 0;
    final totalCurrentOutstanding = int.tryParse(json['total_current_outstanding']?.toString() ?? '0') ?? 0;
    
    // Parse courier payment data
    final courierPaymentList = <CourierPaymentData>[];
    if (json['paymentcourierpayment'] != null) {
      final courierData = json['paymentcourierpayment'] as List;
      for (var item in courierData) {
        courierPaymentList.add(CourierPaymentData.fromJson(item));
      }
    }
    
    // Parse status summary data
    StatusSummary statusSummary = StatusSummary.empty();
    if (json['status_summary'] != null) {
      statusSummary = StatusSummary.fromJson(json['status_summary']);
    }
    
    print('DashboardReportingModel.fromJson: Parsed values:');
    print('  acno: $acno');
    print('  orders: $orders');
    print('  sales: $sales');
    print('  customers: $customers');
    print('  productsold: $productsold');
    print('  totalOutstanding: $totalOutstanding');
    print('  totalCurrentOutstanding: $totalCurrentOutstanding');
    print('  courierPaymentCount: ${courierPaymentList.length}');
    print('  statusSummary: ${statusSummary.orderStatusSummary.totalOrders} total orders');
    
    return DashboardReportingModel(
      acno: acno,
      orders: orders,
      sales: sales,
      customers: customers,
      productsold: productsold,
      totalOutstanding: totalOutstanding,
      totalCurrentOutstanding: totalCurrentOutstanding,
      orderGraph: List<String>.from(json['order_graph'] ?? []),
      revenueGraph: List<String>.from(json['revenue_graph'] ?? []),
      productsoldGraph: List<String>.from(json['productsold_graph'] ?? []),
      customerGraph: List<String>.from(json['customer_graph'] ?? []),
      outstandingGraph: List<String>.from(json['outstanding_graph'] ?? []),
      currentOutstandingGraph: List<String>.from(json['current_outstanding_graph'] ?? []),
      paymentCourierPayment: courierPaymentList,
      statusSummary: statusSummary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acno': acno,
      'orders': orders,
      'sales': sales,
      'customers': customers,
      'productsold': productsold,
      'total_outstanding': totalOutstanding,
      'total_current_outstanding': totalCurrentOutstanding,
      'order_graph': orderGraph,
      'revenue_graph': revenueGraph,
      'productsold_graph': productsoldGraph,
      'customer_graph': customerGraph,
      'outstanding_graph': outstandingGraph,
      'current_outstanding_graph': currentOutstandingGraph,
      'paymentcourierpayment': paymentCourierPayment.map((e) => e.toJson()).toList(),
      'status_summary': statusSummary.toJson(),
    };
  }

  // Helper methods to convert string values to numbers for charts
  List<double> get orderGraphAsNumbers => 
      orderGraph.map((e) => double.tryParse(e) ?? 0.0).toList();
  
  List<double> get revenueGraphAsNumbers => 
      revenueGraph.map((e) => double.tryParse(e) ?? 0.0).toList();
  
  List<double> get productsoldGraphAsNumbers => 
      productsoldGraph.map((e) => double.tryParse(e) ?? 0.0).toList();
  
  List<double> get customerGraphAsNumbers => 
      customerGraph.map((e) => double.tryParse(e) ?? 0.0).toList();
  
  List<double> get outstandingGraphAsNumbers => 
      outstandingGraph.map((e) => double.tryParse(e) ?? 0.0).toList();
  
  List<double> get currentOutstandingGraphAsNumbers => 
      currentOutstandingGraph.map((e) => double.tryParse(e) ?? 0.0).toList();
}

class StatusSummary {
  final OrderStatusSummary orderStatusSummary;
  final OrderStatusSummary failedStatusSummary;

  StatusSummary({
    required this.orderStatusSummary,
    required this.failedStatusSummary,
  });

  factory StatusSummary.fromJson(Map<String, dynamic> json) {
    return StatusSummary(
      orderStatusSummary: OrderStatusSummary.fromJson(json['orderstatus_summary'] ?? {}),
      failedStatusSummary: OrderStatusSummary.fromJson(json['failedstatus_summary'] ?? {}),
    );
  }

  factory StatusSummary.empty() {
    return StatusSummary(
      orderStatusSummary: OrderStatusSummary.empty(),
      failedStatusSummary: OrderStatusSummary.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderstatus_summary': orderStatusSummary.toJson(),
      'failedstatus_summary': failedStatusSummary.toJson(),
    };
  }
}

class OrderStatusSummary {
  final int totalOrders;
  final int totalAmount;
  final List<OrderStatusDetail> detail;

  OrderStatusSummary({
    required this.totalOrders,
    required this.totalAmount,
    required this.detail,
  });

  factory OrderStatusSummary.fromJson(Map<String, dynamic> json) {
    final detailList = <OrderStatusDetail>[];
    if (json['detail'] != null) {
      final detailData = json['detail'] as List;
      for (var item in detailData) {
        detailList.add(OrderStatusDetail.fromJson(item));
      }
    }

    return OrderStatusSummary(
      totalOrders: int.tryParse(json['total_orders']?.toString() ?? '0') ?? 0,
      totalAmount: int.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      detail: detailList,
    );
  }

  factory OrderStatusSummary.empty() {
    return OrderStatusSummary(
      totalOrders: 0,
      totalAmount: 0,
      detail: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_orders': totalOrders,
      'total_amount': totalAmount,
      'detail': detail.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderStatusDetail {
  final String id;
  final String name;
  final int quantity;
  final int amount;

  OrderStatusDetail({
    required this.id,
    required this.name,
    required this.quantity,
    required this.amount,
  });

  factory OrderStatusDetail.fromJson(Map<String, dynamic> json) {
    return OrderStatusDetail(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      amount: int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'amount': amount,
    };
  }
}

class CourierPaymentData {
  final String courierName;
  final String logo;
  final String png;
  final String width;
  final int shipments;
  final int pendingPayment;
  final String status;

  CourierPaymentData({
    required this.courierName,
    required this.logo,
    required this.png,
    required this.width,
    required this.shipments,
    required this.pendingPayment,
    required this.status,
  });

  factory CourierPaymentData.fromJson(Map<String, dynamic> json) {
    final courierName = json['courier_name']?.toString() ?? '';
    final logo = json['logo']?.toString() ?? '';
    final png = json['png']?.toString() ?? '';
    final width = json['width']?.toString() ?? '60';
    final shipments = int.tryParse(json['shipments']?.toString() ?? '0') ?? 0;
    final pendingPayment = int.tryParse(json['pending_payment']?.toString() ?? '0') ?? 0;
    final status = json['status']?.toString() ?? 'active';
    
    print('CourierPaymentData.fromJson: Parsing courier: "$courierName"');
    print('  Logo: $logo');
    print('  PNG: $png');
    print('  Shipments: $shipments');
    print('  Pending Payment: $pendingPayment');
    
    return CourierPaymentData(
      courierName: courierName,
      logo: logo,
      png: png,
      width: width,
      shipments: shipments,
      pendingPayment: pendingPayment,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courier_name': courierName,
      'logo': logo,
      'png': png,
      'width': width,
      'shipments': shipments,
      'pending_payment': pendingPayment,
      'status': status,
    };
  }
} 