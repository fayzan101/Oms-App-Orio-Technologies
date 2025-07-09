import 'package:dio/dio.dart';
import '../models/courier_account.dart';

class CourierService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://oms.getorio.com/api/'));

  Future<List<CourierAccount>> getCourierAccounts(String acno) async {
    final response = await _dio.post(
      'courier/getcourieraccounts',
      data: {"acno": acno},
    );
    if (response.statusCode == 200) {
      final List payload = response.data;
      return payload.map((e) => CourierAccount.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load courier accounts');
    }
  }
} 