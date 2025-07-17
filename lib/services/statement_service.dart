import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/statement_model.dart';
import '../network/api_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StatementService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<StatementModel> getStatement({
    required String startDate,
    required String endDate,
    String? acno,
    int? courierId,
    int? customerCourierId,
  }) async {
    try {
      // Get authentication token
      final apiKey = await _authService.getApiKey();
      
      // Get account number from current user or stored preferences
      String accountNumber = acno ?? '';
      if (accountNumber.isEmpty) {
        final user = _authService.currentUser.value;
        if (user?.acno != null && user!.acno.isNotEmpty) {
          accountNumber = user.acno;
        } else {
          // Fallback to getting from stored preferences
          final prefs = await SharedPreferences.getInstance();
          accountNumber = prefs.getString('acno') ?? '';
        }
      }
      
      
      
      // Validate account number
      if (accountNumber.isEmpty) {
        throw Exception('Account number is required but not available');
      }
      
      // Validate dates
      if (startDate.isEmpty || endDate.isEmpty) {
        throw Exception('Start date and end date are required');
      }
      
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'acno': accountNumber,
        'start_date': startDate,
        'end_date': endDate,
      };

      // Add optional filters
      if (courierId != null) {
        requestData['courier_id'] = courierId;
      }
      if (customerCourierId != null) {
        requestData['customer_courier_id'] = customerCourierId;
      }

      

      // Add authentication header
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      

      final response = await _apiService.post(
        ApiConfig.statementEndpoint,
        data: requestData,
        headers: headers,
      );

      

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final payload = response.data['payload'];
        
        // Handle both List and Map response formats
        if (payload is List) {
          return StatementModel.fromApiResponse(
            payload,
            acno: accountNumber,
            startDate: startDate,
            endDate: endDate,
            courierId: courierId,
            customerCourierId: customerCourierId,
          );
        } else if (payload is Map<String, dynamic>) {
          return StatementModel.fromJson(payload);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load statement data');
      }
    } on DioException catch (e) {
      print('Statement DioException: ${e.message}');
      print('Statement DioException status: ${e.response?.statusCode}');
      print('Statement DioException response: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Statement error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchShopNames(String acno) async {
    final url = Uri.parse('https://oms.getorio.com/api/platform/shopnames');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'acno': acno}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      } else if (data is Map && data['payload'] is List) {
        return (data['payload'] as List).cast<Map<String, dynamic>>();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load shop names');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCityList(String acno) async {
    final url = Uri.parse('https://oms.getorio.com/api/rules/citylist');
    
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'acno': acno}),
    );
    
    
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      
      if (data is List) {
        print('City list is List, length: ${data.length}');
        return data.cast<Map<String, dynamic>>();
      } else if (data is Map && data['payload'] is List) {
        print('City list has payload, length: ${(data['payload'] as List).length}');
        return (data['payload'] as List).cast<Map<String, dynamic>>();
      } else {
        print('City list unexpected format: $data');
        throw Exception('Unexpected response format');
      }
    } else {
      print('City list failed with status: ${response.statusCode}');
      throw Exception('Failed to load city list');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBanks(int countryId) async {
    final url = Uri.parse('https://oms.getorio.com/api/banks');
   
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'country_id': countryId}),
    );
    
    
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      
      if (data is List) {
        
        return data.cast<Map<String, dynamic>>();
      } else if (data is Map && data['payload'] is List) {
        
        return (data['payload'] as List).cast<Map<String, dynamic>>();
      } else {
        print('Banks unexpected format: $data');
        throw Exception('Unexpected response format');
      }
    } else {
      print('Banks failed with status: ${response.statusCode}');
      throw Exception('Failed to load banks');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductSuggestions({
    required String acno,
    required int platformId,
    int? customerPlatformId,
  }) async {
    final url = Uri.parse('https://stagingoms.orio.digital/api/product/suggestproduct');
    
    
    final Map<String, dynamic> requestBody = {
      'acno': acno,
      'platform_id': platformId,
    };
    
    // Add customer_platform_id if platform_id is 3
    if (platformId == 3 && customerPlatformId != null) {
      requestBody['customer_platform_id'] = customerPlatformId;
    }
    
    
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    
    
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      
      if (data is List) {
        print('Product suggestions is List, length: ${data.length}');
        return data.cast<Map<String, dynamic>>();
      } else if (data is Map && data['payload'] is List) {
        print('Product suggestions has payload, length: ${(data['payload'] as List).length}');
        return (data['payload'] as List).cast<Map<String, dynamic>>();
      } else {
        print('Product suggestions unexpected format: $data');
        throw Exception('Unexpected response format');
      }
    } else {
    
      throw Exception('Failed to load product suggestions');
    }
  }

  // Helper method to get current month statement
  Future<StatementModel> getCurrentMonthStatement({
    String? acno,
    int? courierId,
    int? customerCourierId,
  }) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
    final endDate = now.toIso8601String().split('T')[0];
    
    return getStatement(
      startDate: startDate,
      endDate: endDate,
      acno: acno,
      courierId: courierId,
      customerCourierId: customerCourierId,
    );
  }

  // Helper method to get last 30 days statement
  Future<StatementModel> getLast30DaysStatement({
    String? acno,
    int? courierId,
    int? customerCourierId,
  }) async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 29)).toIso8601String().split('T')[0];
    final endDate = now.toIso8601String().split('T')[0];
    
    return getStatement(
      startDate: startDate,
      endDate: endDate,
      acno: acno,
      courierId: courierId,
      customerCourierId: customerCourierId,
    );
  }

  // Helper method to get custom date range statement
  Future<StatementModel> getCustomDateRangeStatement({
    required DateTime startDate,
    required DateTime endDate,
    String? acno,
    int? courierId,
    int? customerCourierId,
  }) async {
    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];
    
    return getStatement(
      startDate: startDateStr,
      endDate: endDateStr,
      acno: acno,
      courierId: courierId,
      customerCourierId: customerCourierId,
    );
  }

  // Helper method to get statement by courier
  Future<StatementModel> getStatementByCourier({
    required int courierId,
    required String startDate,
    required String endDate,
    String? acno,
  }) async {
    return getStatement(
      startDate: startDate,
      endDate: endDate,
      acno: acno,
      courierId: courierId,
    );
  }

  // Helper method to get statement by customer courier
  Future<StatementModel> getStatementByCustomerCourier({
    required int customerCourierId,
    required String startDate,
    required String endDate,
    String? acno,
  }) async {
    return getStatement(
      startDate: startDate,
      endDate: endDate,
      acno: acno,
      customerCourierId: customerCourierId,
    );
  }
} 