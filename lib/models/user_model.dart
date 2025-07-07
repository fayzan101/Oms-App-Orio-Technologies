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