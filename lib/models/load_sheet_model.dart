class LoadSheetModel {
  final String id;
  final String acno;
  final String sheetNo;
  final String courierId;
  final String customerCourierId;
  final String shipmentCount;
  final String createdAt;
  final String courierName;
  final String preferredAcno;
  final String accountTitle;
  final String? consignmentNo;

  LoadSheetModel({
    required this.id,
    required this.acno,
    required this.sheetNo,
    required this.courierId,
    required this.customerCourierId,
    required this.shipmentCount,
    required this.createdAt,
    required this.courierName,
    required this.preferredAcno,
    required this.accountTitle,
    this.consignmentNo,
  });

  factory LoadSheetModel.fromJson(Map<String, dynamic> json) {
    return LoadSheetModel(
      id: json['id']?.toString() ?? '',
      acno: json['acno']?.toString() ?? '',
      sheetNo: json['sheet_no']?.toString() ?? '',
      courierId: json['courier_id']?.toString() ?? '',
      customerCourierId: json['customer_courier_id']?.toString() ?? '',
      shipmentCount: json['shipment_count']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      courierName: json['courier_name']?.toString() ?? '',
      preferredAcno: json['preferred_acno']?.toString() ?? '',
      accountTitle: json['account_title']?.toString() ?? '',
      consignmentNo: json['consignment_no']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'acno': acno,
      'sheet_no': sheetNo,
      'courier_id': courierId,
      'customer_courier_id': customerCourierId,
      'shipment_count': shipmentCount,
      'created_at': createdAt,
      'courier_name': courierName,
      'preferred_acno': preferredAcno,
      'account_title': accountTitle,
      if (consignmentNo != null) 'consignment_no': consignmentNo,
    };
  }

  @override
  String toString() {
    return 'LoadSheetModel(id: $id, acno: $acno, sheetNo: $sheetNo, courierId: $courierId, customerCourierId: $customerCourierId, shipmentCount: $shipmentCount, createdAt: $createdAt, courierName: $courierName, preferredAcno: $preferredAcno, accountTitle: $accountTitle, consignmentNo: $consignmentNo)';
  }
} 