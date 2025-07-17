import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard_reporting_model.dart';
import '../network/api_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class DashboardService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // Helper function to format date in proper ISO 8601 format (YYYY-MM-DD)
  String _formatDateToISO(DateTime date) {
    String year = date.year.toString();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<DashboardReportingModel> getDashboardReporting({
    required String startDate,
    required String endDate,
    String? acno,
  }) async {
    try {
      // Validate and format dates
      final formattedStartDate = _validateAndFormatDate(startDate);
      final formattedEndDate = _validateAndFormatDate(endDate);
      
     
      
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
      if (formattedStartDate.isEmpty || formattedEndDate.isEmpty) {
        throw Exception('Start date and end date are required');
      }
      
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'acno': accountNumber,
        'start_date': formattedStartDate,
        'end_date': formattedEndDate,
      };

      

      // Add authentication header
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      

      final response = await _apiService.post(
        ApiConfig.dashboardEndpoint,
        data: requestData,
        headers: headers,
      );

    

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final dashboardData = DashboardReportingModel.fromJson(response.data['payload']);
        
        // Store the account number from the API response for future use
        if (dashboardData.acno.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('acno', dashboardData.acno);
          
        }
        
        return dashboardData;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load dashboard reporting data');
      }
    } on DioException catch (e) {
      
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Helper function to validate and format date string
  String _validateAndFormatDate(String dateStr) {
    try {
      // If the date is already in YYYY-MM-DD format, return it
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
        return dateStr;
      }
      
      // If it's in DD-MM-YYYY format, convert it
      if (RegExp(r'^\d{1,2}-\d{1,2}-\d{4}$').hasMatch(dateStr)) {
        final parts = dateStr.split('-');
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
      
      // If it's a DateTime object string, try to parse and format
      final date = DateTime.parse(dateStr);
      return _formatDateToISO(date);
    } catch (e) {
      
      // Return the original string if we can't parse it
      return dateStr;
    }
  }

  // Helper method to get current date range (last 7 days)
  Future<DashboardReportingModel> getCurrentWeekReporting({String? acno}) async {
    final now = DateTime.now();
    final startDate = _formatDateToISO(now.subtract(const Duration(days: 6)));
    final endDate = _formatDateToISO(now);
    
    return getDashboardReporting(
      startDate: startDate,
      endDate: endDate,
      acno: acno,
    );
  }

  // Helper method to get current month reporting
  Future<DashboardReportingModel> getCurrentMonthReporting({String? acno}) async {
    final now = DateTime.now();
    final startDate = _formatDateToISO(DateTime(now.year, now.month, 1));
    final endDate = _formatDateToISO(now);
    
    return getDashboardReporting(
      startDate: startDate,
      endDate: endDate,
      acno: acno,
    );
  }

  // Helper method to get custom date range reporting
  Future<DashboardReportingModel> getCustomDateRangeReporting({
    required DateTime startDate,
    required DateTime endDate,
    String? acno,
  }) async {
    final startDateStr = _formatDateToISO(startDate);
    final endDateStr = _formatDateToISO(endDate);
    
    return getDashboardReporting(
      startDate: startDateStr,
      endDate: endDateStr,
      acno: acno,
    );
  }
} 