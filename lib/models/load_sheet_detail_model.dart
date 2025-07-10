class LoadSheetDetailModel {
  final String id;
  final String loadsheetId;
  final String acno;
  final String orderId;
  final String consignmentNo;
  final String courierId;
  final String customerCourierId;
  final String status;
  final String isDeleted;
  final String createdAt;
  final String? updatedAt;
  final String orderLastStatusId;
  final String orderStatus;

  LoadSheetDetailModel({
    required this.id,
    required this.loadsheetId,
    required this.acno,
    required this.orderId,
    required this.consignmentNo,
    required this.courierId,
    required this.customerCourierId,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    this.updatedAt,
    required this.orderLastStatusId,
    required this.orderStatus,
  });

  factory LoadSheetDetailModel.fromJson(Map<String, dynamic> json) {
    return LoadSheetDetailModel(
      id: json['id']?.toString() ?? '',
      loadsheetId: json['loadsheet_id']?.toString() ?? '',
      acno: json['acno']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      consignmentNo: json['consignment_no']?.toString() ?? '',
      courierId: json['courier_id']?.toString() ?? '',
      customerCourierId: json['customer_courier_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
      orderLastStatusId: json['order_last_status_id']?.toString() ?? '',
      orderStatus: json['order_status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loadsheet_id': loadsheetId,
      'acno': acno,
      'order_id': orderId,
      'consignment_no': consignmentNo,
      'courier_id': courierId,
      'customer_courier_id': customerCourierId,
      'status': status,
      'is_deleted': isDeleted,
      'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      'order_last_status_id': orderLastStatusId,
      'order_status': orderStatus,
    };
  }

  @override
  String toString() {
    return 'LoadSheetDetailModel(id: $id, loadsheetId: $loadsheetId, acno: $acno, orderId: $orderId, consignmentNo: $consignmentNo, courierId: $courierId, customerCourierId: $customerCourierId, status: $status, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt, orderLastStatusId: $orderLastStatusId, orderStatus: $orderStatus)';
  }
} 