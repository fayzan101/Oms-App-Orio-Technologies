import 'package:dio/dio.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://oms.getorio.com/api/'));

  Future<List<NotificationModel>> getNotifications(String acno) async {
    try {
      final response = await _dio.post(
        'notification/index',
        data: {"acno": acno},
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
              acno
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
      final response = await _dio.post(
        'notification/get_notification',
        data: {
          "id": id,
          "acno": acno,
        },
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
      final response = await _dio.post(
        'notification/create',
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
      final response = await _dio.post(
        'notification/edit',
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
      final response = await _dio.post(
        'notification/delete',
        data: {
          "id": id,
          "acno": acno,
        },
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
} 