import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static const String _baseUrl = 'https://oms.getorio.com/api/order/order2';
  static const String _token = 'QoVDWMtOU9sUzi543rtAVcaeAiEoDH/lQMmuxj4JbjO54gmraIr8QwAloW2F8KEM4PEU9zibMkdCp5RMU3LFqg==';

  static Future<Map<String, dynamic>> fetchOrders({
    required int startLimit,
    required int endLimit,
    String acno = 'OR-00009',
    String startDate = '2025-01-24',
    String endDate = '2025-06-17',
    String filterOrders = '1',
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        "acno": acno,
        "start_date": startDate,
        "end_date": endDate,
        "start_limit": startLimit,
        "end_limit": endLimit,
        "filter_orders": filterOrders,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load orders');
    }
  }
} 