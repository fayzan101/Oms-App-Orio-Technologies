class User {
  final String userId;
  final String acno;
  final String fullname;
  final String email;
  final String apiKey;
  final String customerId;
  final String phoneNo;
  final String otp;

  User({
    required this.userId,
    required this.acno,
    required this.fullname,
    required this.email,
    required this.apiKey,
    required this.customerId,
    required this.phoneNo,
    required this.otp,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      acno: json['acno'] ?? '',
      fullname: json['fullname'] ?? '',
      email: json['email'] ?? '',
      apiKey: json['api_key'] ?? '',
      customerId: json['customer_id'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      otp: json['otp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'acno': acno,
      'fullname': fullname,
      'email': email,
      'api_key': apiKey,
      'customer_id': customerId,
      'phone_no': phoneNo,
      'otp': otp,
    };
  }
}

class CustomerProfile {
  final String customerId;
  final String acno;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final String cnic;
  final String cnicExpiry;
  final String cnicImage;
  final String hostingReceipt;
  final String businessName;
  final String businessAddress;
  final String ntn;
  final String accountTitle;
  final String accountNumber;
  final String iban;
  final int bankId;

  CustomerProfile({
    required this.customerId,
    required this.acno,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.cnic,
    required this.cnicExpiry,
    required this.cnicImage,
    required this.hostingReceipt,
    required this.businessName,
    required this.businessAddress,
    required this.ntn,
    required this.accountTitle,
    required this.accountNumber,
    required this.iban,
    required this.bankId,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      customerId: json['customer_id']?.toString() ?? '',
      acno: json['acno'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      cnic: json['cnic'] ?? '',
      cnicExpiry: json['cnic_expiry'] ?? '',
      cnicImage: json['cnic_image'] ?? '',
      hostingReceipt: json['hosting_receipt'] ?? '',
      businessName: json['business_name'] ?? '',
      businessAddress: json['business_address'] ?? '',
      ntn: json['ntn'] ?? '',
      accountTitle: json['account_title'] ?? '',
      accountNumber: json['account_number'] ?? '',
      iban: json['iban'] ?? '',
      bankId: json['bank_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': int.tryParse(customerId) ?? 0,
      'acno': acno,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'address': address,
      'cnic': cnic,
      'cnic_expiry': cnicExpiry,
      'cnic_image': cnicImage,
      'hosting_receipt': hostingReceipt,
      'business_name': businessName,
      'business_address': businessAddress,
      'ntn': ntn,
      'account_title': accountTitle,
      'account_number': accountNumber,
      'iban': iban,
      'bank_id': bankId,
    };
  }

  CustomerProfile copyWith({
    String? customerId,
    String? acno,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? cnic,
    String? cnicExpiry,
    String? cnicImage,
    String? hostingReceipt,
    String? businessName,
    String? businessAddress,
    String? ntn,
    String? accountTitle,
    String? accountNumber,
    String? iban,
    int? bankId,
  }) {
    return CustomerProfile(
      customerId: customerId ?? this.customerId,
      acno: acno ?? this.acno,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      cnic: cnic ?? this.cnic,
      cnicExpiry: cnicExpiry ?? this.cnicExpiry,
      cnicImage: cnicImage ?? this.cnicImage,
      hostingReceipt: hostingReceipt ?? this.hostingReceipt,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      ntn: ntn ?? this.ntn,
      accountTitle: accountTitle ?? this.accountTitle,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
      bankId: bankId ?? this.bankId,
    );
  }
}

class LoginResponse {
  final int status;
  final String message;
  final List<User> payload;

  LoginResponse({
    required this.status,
    required this.message,
    required this.payload,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      payload: (json['payload'] as List?)
          ?.map((userJson) => User.fromJson(userJson))
          .toList() ?? [],
    );
  }
} 