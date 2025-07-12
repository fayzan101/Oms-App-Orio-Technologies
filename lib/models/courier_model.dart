class Courier {
  final String courierName;
  final String logo;
  final String png;
  final String status;

  Courier({
    required this.courierName,
    required this.logo,
    required this.png,
    required this.status,
  });

  factory Courier.fromJson(Map<String, dynamic> json) {
    // Get the base URL from the API service configuration
    final baseUrl = 'https://oms.getorio.com/';
    final logoPath = json['logo']?.toString() ?? '';
    final pngPath = json['png']?.toString() ?? '';
    
    // Construct full URLs by merging base URL with relative paths
    final logoUrl = logoPath.isNotEmpty ? '$baseUrl$logoPath' : '';
    final pngUrl = pngPath.isNotEmpty ? '$baseUrl$pngPath' : '';
    
    print('Courier.fromJson: Logo path: "$logoPath" -> URL: "$logoUrl"');
    print('Courier.fromJson: PNG path: "$pngPath" -> URL: "$pngUrl"');
    
    return Courier(
      courierName: json['courier_name']?.toString() ?? '',
      logo: logoUrl,
      png: pngUrl,
      status: json['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courier_name': courierName,
      'logo': logo,
      'png': png,
      'status': status,
    };
  }
}

class CourierPaymentResponse {
  final List<Courier> paymentCourierPayment;

  CourierPaymentResponse({
    required this.paymentCourierPayment,
  });

  factory CourierPaymentResponse.fromJson(Map<String, dynamic> json) {
    final courierList = <Courier>[];
    if (json['paymentcourierpayment'] != null) {
      final courierData = json['paymentcourierpayment'] as List;
      for (var item in courierData) {
        courierList.add(Courier.fromJson(item));
      }
    }
    
    return CourierPaymentResponse(
      paymentCourierPayment: courierList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentcourierpayment': paymentCourierPayment.map((e) => e.toJson()).toList(),
    };
  }
} 