import 'package:dio/dio.dart';
import '../models/help_video_model.dart';

class HelpVideoService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://oms.getorio.com/api/'));

  Future<List<HelpVideoModel>> getHelpVideos() async {
    final response = await _dio.get('helps/list');
    if (response.statusCode == 200 && response.data['status'] == 1) {
      final List payload = response.data['payload'];
      return payload.map((e) => HelpVideoModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load help videos');
    }
  }
} 