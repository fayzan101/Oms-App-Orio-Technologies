import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../network/api_service.dart';
import '../config/api_config.dart';

class RulesService extends GetxService {
  final ApiService _apiService = ApiService();
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> rules = <Map<String, dynamic>>[].obs;
  final RxString errorMessage = ''.obs;

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
    required String acno,
    required Map<String, dynamic> ruleData,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('RulesService: Creating rule for acno: $acno');
      print('RulesService: Rule data: $ruleData');
      
      // Add acno to the rule data
      final requestData = {
        'acno': acno,
        ...ruleData,
      };

      // Make API call to create rule endpoint
      final response = await _apiService.post('rules/create', data: requestData);
      
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
    required String acno,
    required String ruleId,
    required Map<String, dynamic> ruleData,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('RulesService: Updating rule $ruleId for acno: $acno');
      
      // Add acno and ruleId to the rule data
      final requestData = {
        'acno': acno,
        'rule_id': ruleId,
        ...ruleData,
      };

      // Make API call to update rule endpoint
      final response = await _apiService.post('rules/update', data: requestData);
      
      print('RulesService: Update rule response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['status'] == 1) {
          print('RulesService: Rule updated successfully');
          // Refresh the rules list
          await getRules(acno: acno);
          return true;
        } else {
          errorMessage.value = data['message'] ?? 'Failed to update rule';
          return false;
        }
      } else {
        final data = response.data;
        errorMessage.value = data['message'] ?? 'Failed to update rule';
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
} 