import 'dart:convert';
import 'package:dio/dio.dart';

class OrderService {
  static const String _baseUrl = '';
  static const String _token = ''

  static final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    ),
  );

  static Future<Map<String, dynamic>> fetchOrders({
    required int startLimit,
    required int endLimit,
    String acno = 'OR-00009',
    String startDate = '2025-01-24',
    String endDate = '2025-06-17',
    String filterOrders = '1',
  }) async {
    final body = {
      "acno": acno,
      "start_date": startDate,
      "end_date": endDate,
      "start_limit": startLimit,
      "end_limit": endLimit,
      "filter_orders": filterOrders,
    };
    try {
      final response = await _dio.post(_baseUrl, data: jsonEncode(body));
      if (response.statusCode == 200) {
        return response.data is String ? jsonDecode(response.data) : response.data;
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchReportSummary({
    required String acno,
    required String startDate,
    required String endDate,
    String module = 'order_report',
  }) async {
    final body = {
      "acno": acno,
      "start_date": startDate,
      "end_date": endDate,
      "module": module,
    };
    try {
      final response = await _dio.post(
        'https://oms.getorio.com/api/common/report_summary',
        data: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        if (data['status'] == 1 && data['payload'] != null) {
          return data['payload'] as Map<String, dynamic>;
        } else {
          throw Exception('API error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load report summary');
      }
    } catch (e) {
      throw Exception('Failed to load report summary: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAgeingReport({
    required String acno,
    required int startLimit,
    required int endLimit,
    required String startDate,
    required String endDate,
    String ageingType = 'order',
    String? filterCourierId,
    String? filterStatusId,
    String? filterDestinationCity,
  }) async {
    const String url = 'https://oms.getorio.com/api/report/ageingreport';
    final body = {
      "acno": acno,
      "start_limit": startLimit,
      "end_limit": endLimit,
      "start_date": startDate,
      "end_date": endDate,
      "ageing_type": ageingType,
      if (filterCourierId != null) "filter_courier_id": filterCourierId,
      if (filterStatusId != null) "filter_status_id": filterStatusId,
      if (filterDestinationCity != null) "filter_destination_city": filterDestinationCity,
    };
    try {
      final response = await _dio.post(url, data: jsonEncode(body));
      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data['payload'] != null && data['payload'] is List) {
          return List<Map<String, dynamic>>.from(data['payload']);
        } else if (data['data'] != null && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load ageing report');
      }
    } catch (e) {
      throw Exception('Failed to load ageing report: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCourierInsights({
    required String acno,
    required int startLimit,
    required int endLimit,
    required String startDate,
    required String endDate,
    String? filterCourierId,
    String? filterStatusId,
    String? filterDestinationCity,
    String? filterPaymentStatus,
    String? filterPaymentMethod,
  }) async {
    const String url = 'https://oms.getorio.com/api/report/courierinsights';
    final body = {
      "acno": acno,
      "start_limit": startLimit,
      "end_limit": endLimit,
      "start_date": startDate,
      "end_date": endDate,
      if (filterCourierId != null) "filter_courier_id": filterCourierId,
      if (filterStatusId != null) "filter_status_id": filterStatusId,
      if (filterDestinationCity != null) "filter_destination_city": filterDestinationCity,
      if (filterPaymentStatus != null) "filter_payment_status": filterPaymentStatus,
      if (filterPaymentMethod != null) "filter_payment_method": filterPaymentMethod,
    };
    try {
      final response = await _dio.post(url, data: jsonEncode(body));
      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data['payload'] != null && data['payload'] is List) {
          return List<Map<String, dynamic>>.from(data['payload']);
        } else if (data['data'] != null && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load courier insights');
      }
    } catch (e) {
      throw Exception('Failed to load courier insights: $e');
    }
  }
} 
