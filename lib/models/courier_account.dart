class CourierAccount {
  final String id;
  final String acno;
  final String courierId;
  final String accountTitle;
  final String courierApikey;
  final String courierAcno;
  final String courierUser;
  final String courierPassword;
  final String status;
  final String isDefault;
  final String courierName;

  CourierAccount({
    required this.id,
    required this.acno,
    required this.courierId,
    required this.accountTitle,
    required this.courierApikey,
    required this.courierAcno,
    required this.courierUser,
    required this.courierPassword,
    required this.status,
    required this.isDefault,
    required this.courierName,
  });

  factory CourierAccount.fromJson(Map<String, dynamic> json) {
    return CourierAccount(
      id: json['id'] ?? '',
      acno: json['acno'] ?? '',
      courierId: json['courier_id'] ?? '',
      accountTitle: json['account_title'] ?? '',
      courierApikey: json['courier_apikey'] ?? '',
      courierAcno: json['courier_acno'] ?? '',
      courierUser: json['courier_user'] ?? '',
      courierPassword: json['courier_password'] ?? '',
      status: json['status'] ?? '',
      isDefault: json['default'] ?? '',
      courierName: json['courier_name'] ?? '',
    );
  }
} 