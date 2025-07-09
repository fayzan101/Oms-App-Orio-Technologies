import 'package:dio/dio.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://oms.getorio.com/api/'));

  Future<List<NotificationModel>> getNotifications(String acno) async {
    final response = await _dio.post(
      'notification/index',
      data: {"acno": acno},
    );
    if (response.statusCode == 200) {
      final List payload = response.data;
      return payload.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }
} 