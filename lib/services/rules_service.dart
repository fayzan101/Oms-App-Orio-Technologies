import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../network/api_service.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';

class RulesService extends GetxService {
  final ApiService _apiService = ApiService();
  final AuthService _authService;
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> rules = <Map<String, dynamic>>[].obs;
  final RxString errorMessage = ''.obs;

  RulesService(this._authService);

  @override
  void onInit() {
    super.onInit();
    _apiService.init();
  }

  // Get rules list
  Future<bool> getRules({required String acno}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('RulesService: Fetching rules for acno: $acno');
      
      // Prepare request data
      final requestData = {
        'acno': acno,
      };

      // Make API call to rules/index endpoint
      final response = await _apiService.post('rules/index', data: requestData);
      
      print('RulesService: Response status: ${response.statusCode}');
      print('RulesService: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Check if the response has the expected structure
        if (data['status'] == 1 && data['payload'] != null) {
          final rulesList = data['payload'] as List;
          rules.value = rulesList.map((rule) => rule as Map<String, dynamic>).toList();
          print('RulesService: Successfully loaded ${rules.length} rules');
          return true;
        } else {
          // No rules found or empty response
          rules.value = [];
          print('RulesService: No rules found or empty response');
          return true;
        }
      } else {
        final data = response.data;
        errorMessage.value = data['message'] ?? 'Failed to load rules';
        print('RulesService: API error - ${errorMessage.value}');
        return false;
      }
      
    } on DioException catch (e) {
      print('RulesService: DioException: ${e.message}');
      if (e.response != null) {
        print('RulesService: Response status: ${e.response!.statusCode}');
        print('RulesService: Response data: ${e.response!.data}');
      }
      
      errorMessage.value = e.message ?? 'Network error occurred';
      return false;
    } catch (e) {
      print('RulesService: Unexpected error: $e');
      errorMessage.value = 'An unexpected error occurred';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new rule
  Future<bool> createRule({
    required String title,
    required String? statusIds,
    required String? weightType,
    required String weightValue,
    required String? paymentMethodId,
    required String? customerCitylistId,
    required String? orderType,
    required String orderValue,
    required String? platformType,
    required String platformValue,
    required String addressKeywords,
    required String? isContain,
    required String? courierId,
    required String? customerCourierId,
    required String? pickupId,
    required String serviceCode,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get current user's acno
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        errorMessage.value = 'User not logged in';
        return false;
      }

      print('RulesService: Creating rule for acno: $acno');
      
      // Prepare request data matching the API requirements
      final requestData = {
        'acno': acno,
        'rule_title': title,
        'status_ids': statusIds != null ? [statusIds] : [],
        'weight_type': weightType ?? '>=',
        'weight_value': int.tryParse(weightValue) ?? 1,
        'paymentmethod_id': int.tryParse(paymentMethodId ?? '1') ?? 1,
        'customer_citylist_id': int.tryParse(customerCitylistId ?? '27') ?? 27,
        'order_type': orderType ?? '>=',
        'order_value': int.tryParse(orderValue) ?? 4999,
        'platform_value': int.tryParse(platformValue) ?? 7,
        'platform_type': platformType ?? 'OMS',
        'address_keywords': int.tryParse(addressKeywords) ?? 3,
        'is_contain': isContain ?? '0',
        'courier_id': int.tryParse(courierId ?? '1') ?? 1,
        'customer_courier_id': int.tryParse(customerCourierId ?? '55') ?? 55,
        'pickup_id': int.tryParse(pickupId ?? '1') ?? 1,
        'service_code': serviceCode,
      };

      print('RulesService: Rule data: $requestData');

      // Make API call to rules/store endpoint
      final response = await _apiService.post('rules/store', data: requestData);
      
      print('RulesService: Create rule response status: ${response.statusCode}');
      print('RulesService: Create rule response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['status'] == 1) {
          print('RulesService: Rule created successfully');
          // Refresh the rules list
          await getRules(acno: acno);
          return true;
        } else {
          errorMessage.value = data['message'] ?? 'Failed to create rule';
          print('RulesService: Create rule failed - ${errorMessage.value}');
          return false;
        }
      } else {
        final data = response.data;
        errorMessage.value = data['message'] ?? 'Failed to create rule';
        print('RulesService: Create rule API error - ${errorMessage.value}');
        return false;
      }
      
    } on DioException catch (e) {
      print('RulesService: Create rule DioException: ${e.message}');
      errorMessage.value = e.message ?? 'Network error occurred';
      return false;
    } catch (e) {
      print('RulesService: Create rule unexpected error: $e');
      errorMessage.value = 'An unexpected error occurred';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing rule
  Future<bool> updateRule({
    required int ruleId,
    required String ruleTitle,
    required int courierId,
    required int customerCourierId,
    required int pickupId,
    required String serviceCode,
    required int status,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get current user's acno
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        errorMessage.value = 'User not logged in';
        return false;
      }

      print('RulesService: Updating rule for acno: $acno');
      
      // Prepare request data matching the API requirements
      final requestData = {
        'id': ruleId,
        'acno': acno,
        'rule_title': ruleTitle,
        'courier_id': courierId,
        'customer_courier_id': customerCourierId,
        'pickup_id': pickupId,
        'service_code': serviceCode,
        'status': status,
        'requestType': 'updateRule',
      };

      print('RulesService: Update rule data: $requestData');

      // Make API call to rules/update endpoint
      final response = await _apiService.post('rules/update', data: requestData);
      
      print('RulesService: Update rule response status: ${response.statusCode}');
      print('RulesService: Update rule response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['status'] == 1) {
          print('RulesService: Rule updated successfully');
          // Refresh the rules list
          await getRules(acno: acno);
          return true;
        } else {
          errorMessage.value = data['message'] ?? 'Failed to update rule';
          print('RulesService: Update rule failed - ${errorMessage.value}');
          return false;
        }
      } else {
        final data = response.data;
        errorMessage.value = data['message'] ?? 'Failed to update rule';
        print('RulesService: Update rule API error - ${errorMessage.value}');
        return false;
      }
      
    } on DioException catch (e) {
      print('RulesService: Update rule DioException: ${e.message}');
      errorMessage.value = e.message ?? 'Network error occurred';
      return false;
    } catch (e) {
      print('RulesService: Update rule unexpected error: $e');
      errorMessage.value = 'An unexpected error occurred';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a rule
  Future<bool> deleteRule({
    required String acno,
    required String ruleId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('RulesService: Deleting rule $ruleId for acno: $acno');
      
      final requestData = {
        'id': int.tryParse(ruleId) ?? 0,
        'acno': acno,
      };

      // Make API call to destroy rule endpoint
      final response = await _apiService.post('rules/destroy', data: requestData);
      
      print('RulesService: Destroy rule response status: ${response.statusCode}');
      print('RulesService: Destroy rule response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['status'] == 1) {
          print('RulesService: Rule destroyed successfully');
          // Refresh the rules list
          await getRules(acno: acno);
          return true;
        } else {
          errorMessage.value = data['message'] ?? 'Failed to destroy rule';
          return false;
        }
      } else {
        final data = response.data;
        errorMessage.value = data['message'] ?? 'Failed to destroy rule';
        return false;
      }
      
    } on DioException catch (e) {
      print('RulesService: Destroy rule DioException: ${e.message}');
      if (e.response != null) {
        print('RulesService: Response status: ${e.response!.statusCode}');
        print('RulesService: Response data: ${e.response!.data}');
      }
      errorMessage.value = e.message ?? 'Network error occurred';
      return false;
    } catch (e) {
      print('RulesService: Destroy rule unexpected error: $e');
      errorMessage.value = 'An unexpected error occurred';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Clear rules list
  void clearRules() {
    rules.value = [];
  }

  // Get keywords for address keywords dropdown
  Future<List<Map<String, dynamic>>> getKeywords() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get current user's acno
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        errorMessage.value = 'User not logged in';
        print('RulesService: No acno found - user not logged in');
        return [];
      }

      print('RulesService: Fetching keywords for acno: $acno');
      
      // Prepare request data
      final requestData = {
        'acno': acno,
      };

      // Make API call to rules/showkeywords endpoint
      final response = await _apiService.post('rules/showkeywords', data: requestData);
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle the API response structure
        List<Map<String, dynamic>> keywords = [];
        
        if (data['status'] == 1 && data['payload'] != null && data['payload'] is List) {
          final payloadList = data['payload'] as List;
          keywords = payloadList.map((item) => item as Map<String, dynamic>).toList();
        }
        
        return keywords;
      } else {
        final data = response.data;
        errorMessage.value = data['message'] ?? 'Failed to load keywords';
        print('RulesService: Keywords API error - ${errorMessage.value}');
        return [];
      }
      
    } on DioException catch (e) {
      errorMessage.value = e.message ?? 'Network error occurred';
      return [];
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      return [];
    } finally {
      isLoading.value = false;
    }
  }
} 