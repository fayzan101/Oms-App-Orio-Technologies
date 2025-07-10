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
  });

  factory DashboardReportingModel.fromJson(Map<String, dynamic> json) {
    return DashboardReportingModel(
      acno: json['acno'] ?? '',
      orders: json['orders'] ?? 0,
      sales: json['sales'] ?? 0,
      customers: json['customers'] ?? 0,
      productsold: json['productsold'] ?? 0,
      totalOutstanding: json['total_outstanding'] ?? 0,
      totalCurrentOutstanding: json['total_current_outstanding'] ?? 0,
      orderGraph: List<String>.from(json['order_graph'] ?? []),
      revenueGraph: List<String>.from(json['revenue_graph'] ?? []),
      productsoldGraph: List<String>.from(json['productsold_graph'] ?? []),
      customerGraph: List<String>.from(json['customer_graph'] ?? []),
      outstandingGraph: List<String>.from(json['outstanding_graph'] ?? []),
      currentOutstandingGraph: List<String>.from(json['current_outstanding_graph'] ?? []),
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