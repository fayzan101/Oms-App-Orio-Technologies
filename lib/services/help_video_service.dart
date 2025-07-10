import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/help_video_model.dart';
import '../network/api_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class HelpVideoService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<List<HelpVideoModel>> getHelpVideos({
    String? searchQuery,
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // Get authentication token and account number
      final apiKey = await _authService.getApiKey();
      
      // Get account number from current user or stored preferences
      String acno = '';
      final user = _authService.currentUser.value;
      if (user?.acno != null && user!.acno.isNotEmpty) {
        acno = user.acno;
      } else {
        // Fallback to getting from stored preferences
        final prefs = await SharedPreferences.getInstance();
        acno = prefs.getString('acno') ?? '';
      }
      
      print('Help videos acno: $acno');
      print('Help videos user: ${user?.acno}');
      
      // Validate account number
      if (acno.isEmpty) {
        throw Exception('Account number is required but not available');
      }
      
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'acno': acno,
      };

      // Add optional filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        requestData['search'] = searchQuery;
      }
      if (type != null && type.isNotEmpty) {
        requestData['type'] = type;
      }
      if (status != null && status.isNotEmpty) {
        requestData['status'] = status;
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
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      print('Help videos request data: $requestData');
      print('Help videos headers: $headers');

      final response = await _apiService.post(
        ApiConfig.helpVideosEndpoint,
        data: requestData,
        headers: headers,
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final List payload = response.data['payload'];
        return payload.map((e) => HelpVideoModel.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load help videos');
      }
    } on DioException catch (e) {
      print('Help videos DioException: ${e.message}');
      print('Help videos DioException status: ${e.response?.statusCode}');
      print('Help videos DioException response: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<HelpVideoModel?> getHelpVideoById(String id) async {
    try {
      final apiKey = await _authService.getApiKey();
      
      final headers = <String, String>{};
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final response = await _apiService.get('${ApiConfig.helpVideoDetailEndpoint}/$id');

      if (response.statusCode == 200 && response.data['status'] == 1) {
        return HelpVideoModel.fromJson(response.data['payload']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load help video');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<HelpVideoModel>> getHelpVideosByType(String type) async {
    return getHelpVideos(type: type);
  }

  Future<List<HelpVideoModel>> searchHelpVideos(String query) async {
    return getHelpVideos(searchQuery: query);
  }

  Future<List<HelpVideoModel>> getActiveHelpVideos() async {
    return getHelpVideos(status: 'active');
  }
} 