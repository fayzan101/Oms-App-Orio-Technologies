import 'package:dio/dio.dart';
import '../models/load_sheet_model.dart';
import '../models/load_sheet_detail_model.dart';
import '../network/api_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class LoadSheetService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  LoadSheetService() {
    _apiService.init();
  }

  Future<List<LoadSheetModel>> getLoadSheets({
    String? acno,
    String? startDate,
    String? endDate,
    int? courierId,
    int? customerCourierId,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // Get authentication token
      final apiKey = await _authService.getApiKey();
      
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'acno': acno ?? '',
      };

      // Add required date filters
      if (startDate != null && startDate.isNotEmpty) {
        requestData['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        requestData['end_date'] = endDate;
      }

      // Add optional filters
      if (courierId != null) {
        requestData['courier_id'] = courierId;
      }
      if (customerCourierId != null) {
        requestData['customer_courier_id'] = customerCourierId;
      }
      if (page > 1) {
        requestData['page'] = page;
      }
      if (limit != 20) {
        requestData['limit'] = limit;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        requestData['sort_by'] = sortBy;
      }
      if (sortOrder != null && sortOrder.isNotEmpty) {
        requestData['sort_order'] = sortOrder;
      }

      // Add authentication header
      final headers = <String, String>{};
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final response = await _apiService.post(
        ApiConfig.loadSheetEndpoint,
        data: requestData,
        headers: headers,
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final List payload = response.data['payload'];
        return payload.map((e) => LoadSheetModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load sheets');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<LoadSheetModel?> getLoadSheetById(String id, {String? acno}) async {
    try {
      final apiKey = await _authService.getApiKey();
      
      final headers = <String, String>{};
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final response = await _apiService.post(
        '${ApiConfig.loadSheetEndpoint}/$id',
        data: {
          'acno': acno ?? '',
        },
        headers: headers,
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        return LoadSheetModel.fromJson(response.data['payload']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load sheet details');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<LoadSheetDetailModel>> getLoadSheetDetails({
    required String sheetNo,
    String? acno,
  }) async {
    try {
      // Get authentication token
      final apiKey = await _authService.getApiKey();
      
      // Add authentication header
      final headers = <String, String>{};
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final requestData = {
        'sheet_no': int.tryParse(sheetNo) ?? 0, // Convert string to number
        if (acno != null && acno.isNotEmpty) 'acno': acno,
      };

      print('Request headers: $headers');
      print('Request data: $requestData');
      print('Endpoint: ${ApiConfig.loadSheetSingleEndpoint}');
      print('Full URL: ${ApiConfig.baseUrl}${ApiConfig.loadSheetSingleEndpoint}');
      print('Headers being sent: ${headers.toString()}');

      final response = await _apiService.post(
        ApiConfig.loadSheetSingleEndpoint,
        data: requestData,
        headers: headers,
      );

      print('Response received: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final List payload = response.data['payload'];
        return payload.map((e) => LoadSheetDetailModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load sheet details');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Convenience methods for common operations
  Future<List<LoadSheetModel>> getLoadSheetsByDateRange(
    String startDate, 
    String endDate, {
    String? acno,
    int? courierId,
    int? customerCourierId,
  }) async {
    return getLoadSheets(
      acno: acno,
      startDate: startDate,
      endDate: endDate,
      courierId: courierId,
      customerCourierId: customerCourierId,
    );
  }

  Future<List<LoadSheetModel>> getLoadSheetsByCourier(
    int courierId, {
    String? acno,
    String? startDate,
    String? endDate,
  }) async {
    return getLoadSheets(
      acno: acno,
      startDate: startDate,
      endDate: endDate,
      courierId: courierId,
    );
  }

  Future<List<LoadSheetModel>> getLoadSheetsByCustomerCourier(
    int customerCourierId, {
    String? acno,
    String? startDate,
    String? endDate,
  }) async {
    return getLoadSheets(
      acno: acno,
      startDate: startDate,
      endDate: endDate,
      customerCourierId: customerCourierId,
    );
  }

  Future<List<LoadSheetModel>> getRecentLoadSheets({
    String? acno,
    int days = 7,
  }) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days)).toIso8601String().split('T')[0];
    final endDate = now.toIso8601String().split('T')[0];
    
    return getLoadSheets(
      acno: acno,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<LoadSheetModel>> getTodayLoadSheets({String? acno}) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return getLoadSheets(
      acno: acno,
      startDate: today,
      endDate: today,
    );
  }

  Future<bool> deleteLoadSheet({
    required int orderId,
    required String consignmentNo,
    String? acno,
  }) async {
    try {
      print('Delete load sheet service called');
      print('Order ID: $orderId');
      print('Consignment No: $consignmentNo');
      print('ACNO: $acno');
      
      // Get authentication token
      final apiKey = await _authService.getApiKey();
      print('API Key: ${apiKey.isNotEmpty ? 'Present' : 'Missing'}');
      print('API Key length: ${apiKey.length}');
      print('API Key preview: ${apiKey.isNotEmpty ? apiKey.substring(0, apiKey.length > 10 ? 10 : apiKey.length) + '...' : 'Empty'}');
      
      // Add authentication header
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
        print('Authorization header: Bearer ${apiKey.substring(0, apiKey.length > 10 ? 10 : apiKey.length)}...');
      } else {
        print('Warning: API key is empty!');
      }

      // API expects arrays of IDs (plural field names) with correct data types
      final requestData = {
        'order_ids': [orderId.toString()], // Array of order IDs as strings
        'consignment_nos': [consignmentNo], // Array of consignment numbers
        if (acno != null && acno.isNotEmpty) 'acno': acno,
      };
      
      print('Request data: $requestData');
      print('Request data JSON: ${requestData.toString()}');
      print('order_id type: ${orderId.runtimeType}');
      print('consignment_no type: ${consignmentNo.runtimeType}');
      print('acno type: ${acno?.runtimeType}');
      print('Endpoint: ${ApiConfig.loadSheetDeleteEndpoint}');
      print('Full URL: ${ApiConfig.baseUrl}${ApiConfig.loadSheetDeleteEndpoint}');
      print('Headers being sent: $headers');

      print('About to make API call to: ${ApiConfig.baseUrl}${ApiConfig.loadSheetDeleteEndpoint}');
      print('With data: $requestData');
      print('With headers: $headers');
      
      final response = await _apiService.post(
        ApiConfig.loadSheetDeleteEndpoint,
        data: requestData,
        headers: headers,
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Check if the response indicates success
        if (response.data['status'] == 1 || response.data['success'] == true) {
          print('Delete successful');
          return true;
        } else {
          final errorMessage = response.data['message'] ?? 'Failed to delete load sheet';
          print('Delete failed: $errorMessage');
          throw Exception(errorMessage);
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        throw Exception('Failed to delete load sheet');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('DioException status code: ${e.response?.statusCode}');
      print('DioException response data: ${e.response?.data}');
      print('DioException response headers: ${e.response?.headers}');
      
      // Handle specific business logic errors
      if (e.response?.statusCode == 403 && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData['message'] != null) {
          throw Exception(responseData['message']);
        }
      }
      
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
} 