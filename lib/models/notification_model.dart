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
    );
  }
} 