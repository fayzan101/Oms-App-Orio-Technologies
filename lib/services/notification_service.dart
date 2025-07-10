import 'package:dio/dio.dart';
import '../models/notification_model.dart';
import '../network/api_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class NotificationService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  NotificationService() {
    _apiService.init();
  }

  Future<List<NotificationModel>> getNotifications({
    String? acno,
    String? searchQuery,
    String? status,
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

      // Add optional filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        requestData['search'] = searchQuery;
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
      final headers = <String, String>{};
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final response = await _apiService.post(
        ApiConfig.notificationsEndpoint,
        data: requestData,
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List payload = response.data;
        List<NotificationModel> notifications = [];
        
        // Fetch detailed information for each notification
        for (var notificationData in payload) {
          try {
            // Get basic notification data
            final basicNotification = NotificationModel.fromJson(notificationData);
            
            // Fetch detailed information using get_notification endpoint
            final detailedNotification = await getNotification(
              int.tryParse(basicNotification.id) ?? 0, 
              acno ?? ''
            );
            
            notifications.add(detailedNotification);
          } catch (e) {
            // If detailed fetch fails, use basic notification data
            notifications.add(NotificationModel.fromJson(notificationData));
          }
        }
        
        return notifications;
      } else {
        throw Exception('Failed to load notifications');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<NotificationModel> getNotification(int id, String acno) async {
    try {
      // Get authentication token
      final apiKey = await _authService.getApiKey();
      
      // Add authentication header
      final headers = <String, String>{};
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final response = await _apiService.post(
        ApiConfig.notificationDetailEndpoint,
        data: {
          "id": id,
          "acno": acno,
        },
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get notification');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<bool> createNotification({
    required String acno,
    required String message,
    required int statusId,
    required String subject,
    required String isEmail,
    required String isWhatsapp,
    required String isSms,
    required String status,
  }) async {
    try {
      // Get authentication token
      final apiKey = await _authService.getApiKey();
      
      // Add authentication header
      final headers = <String, String>{};
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final response = await _apiService.post(
        ApiConfig.notificationCreateEndpoint,
        data: {
          "acno": acno,
          "message": message,
          "status_id": statusId,
          "subject": subject,
          "is_email": isEmail,
          "is_whatsapp": isWhatsapp,
          "is_sms": isSms,
          "status": status,
        },
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        // Check if the response indicates success
        if (response.data['status'] == 1 || response.data['success'] == true) {
          return true;
        } else {
          throw Exception(response.data['message'] ?? 'Failed to create notification');
        }
      } else {
        throw Exception('Failed to create notification');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<bool> editNotification({
    required int id,
    required String acno,
    required String message,
    required int statusId,
    required String subject,
    required String isEmail,
    required String isWhatsapp,
    required String isSms,
    required String status,
  }) async {
    try {
      // Get authentication token
      final apiKey = await _authService.getApiKey();
      
      // Add authentication header
      final headers = <String, String>{};
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final response = await _apiService.post(
        ApiConfig.notificationEditEndpoint,
        data: {
          "id": id,
          "acno": acno,
          "message": message,
          "status_id": statusId,
          "subject": subject,
          "is_email": isEmail,
          "is_whatsapp": isWhatsapp,
          "is_sms": isSms,
          "status": status,
        },
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        // Check if the response indicates success
        if (response.data['status'] == 1 || response.data['success'] == true) {
          return true;
        } else {
          throw Exception(response.data['message'] ?? 'Failed to edit notification');
        }
      } else {
        throw Exception('Failed to edit notification');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<bool> deleteNotification(int id, String acno) async {
    try {
      // Get authentication token
      final apiKey = await _authService.getApiKey();
      
      // Add authentication header
      final headers = <String, String>{};
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final response = await _apiService.post(
        ApiConfig.notificationDeleteEndpoint,
        data: {
          "id": id,
          "acno": acno,
        },
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        // Check if the response indicates success
        if (response.data['status'] == 1 || response.data['success'] == true) {
          return true;
        } else {
          throw Exception(response.data['message'] ?? 'Failed to delete notification');
        }
      } else {
        throw Exception('Failed to delete notification');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Convenience methods for common operations
  Future<List<NotificationModel>> getNotificationsByStatus(String status, {String? acno}) async {
    return getNotifications(status: status, acno: acno);
  }

  Future<List<NotificationModel>> searchNotifications(String query, {String? acno}) async {
    return getNotifications(searchQuery: query, acno: acno);
  }

  Future<List<NotificationModel>> getActiveNotifications({String? acno}) async {
    return getNotifications(status: 'active', acno: acno);
  }

  Future<List<NotificationModel>> getInactiveNotifications({String? acno}) async {
    return getNotifications(status: 'inactive', acno: acno);
  }
} 