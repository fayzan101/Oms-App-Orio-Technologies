class NotificationModel {
  final String id;
  final String acno;
  final String message;
  final String statusId;
  final String isSms;
  final String isWhatsapp;
  final String isEmail;
  final String subject;
  final String isDeleted;
  final String status;
  final String statusName;
  
  // Additional fields for detailed order information
  final String customerName;
  final String orderStatus;
  final String storeName;
  final String orderAmount;
  final String orderRef;
  final String consigneeContact;
  final String consigneeEmail;
  final String courierName;

  NotificationModel({
    required this.id,
    required this.acno,
    required this.message,
    required this.statusId,
    required this.isSms,
    required this.isWhatsapp,
    required this.isEmail,
    required this.subject,
    required this.isDeleted,
    required this.status,
    required this.statusName,
    this.customerName = '',
    this.orderStatus = '',
    this.storeName = '',
    this.orderAmount = '',
    this.orderRef = '',
    this.consigneeContact = '',
    this.consigneeEmail = '',
    this.courierName = '',
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      acno: json['acno'] ?? '',
      message: json['message'] ?? '',
      statusId: json['status_id'] ?? '',
      isSms: json['is_sms'] ?? '',
      isWhatsapp: json['is_whatsapp'] ?? '',
      isEmail: json['is_email'] ?? '',
      subject: json['subject'] ?? '',
      isDeleted: json['is_deleted'] ?? '',
      status: json['status'] ?? '',
      statusName: json['status_name'] ?? '',
      // Additional fields from detail API
      customerName: json['consignee_name'] ?? json['customer_name'] ?? '',
      orderStatus: json['status_name'] ?? json['order_status'] ?? '',
      storeName: json['store_name'] ?? json['account_title'] ?? '',
      orderAmount: json['order_amount'] ?? '',
      orderRef: json['order_ref'] ?? '',
      consigneeContact: json['consignee_contact'] ?? json['contact'] ?? '',
      consigneeEmail: json['consignee_email'] ?? '',
      courierName: json['courier_name'] ?? '',
    );
  }
} 