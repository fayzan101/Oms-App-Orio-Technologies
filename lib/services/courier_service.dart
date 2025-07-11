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

  Future<bool> deleteCourier(String id, String acno) async {
    try {
      // Parse ID to integer as the API expects
      final int courierId = int.parse(id);
      
      final response = await _dio.post(
        'courier/delete',
        data: {
          "id": courierId,
          "acno": acno,
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete courier');
      }
    } on FormatException {
      throw Exception('Invalid courier ID format');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Bad request: Invalid data provided');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden: Access denied or invalid credentials');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Courier not found');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> updateCourier({
    required String acno,
    required int userId,
    required String id,
    required String courierId,
    required String accountTitle,
    required String accountNo,
    required String accountUser,
    required String accountPassword,
    required String apikey,
    required String status,
    required String isDefault,
  }) async {
    try {
      // Parse ID to integer as the API expects
      final int courierAccountId = int.parse(id);
      final int courierIdInt = int.parse(courierId);
      
      final response = await _dio.post(
        'courier/update',
        data: {
          "acno": acno,
          "user_id": userId,
          "id": courierAccountId,
          "courier_id": courierIdInt,
          "account_title": accountTitle,
          "account_no": accountNo,
          "account_user": accountUser,
          "account_password": accountPassword,
          "apikey": apikey,
          "status": status,
          "default": isDefault,
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update courier');
      }
    } on FormatException {
      throw Exception('Invalid ID format');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Bad request: Invalid data provided');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden: Access denied or invalid credentials');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Courier not found');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> storeCourier({
    required String acno,
    required int userId,
    required String courierId,
    required String accountTitle,
    required String accountNo,
    required String accountUser,
    required String accountPassword,
    required String apikey,
    required String status,
    required String isDefault,
  }) async {
    try {
      // Parse courier ID to integer as the API expects
      final int courierIdInt = int.parse(courierId);
      
      final response = await _dio.post(
        'courier/store',
        data: {
          "acno": acno,
          "user_id": userId,
          "courier_id": courierIdInt,
          "account_title": accountTitle,
          "account_no": accountNo,
          "account_user": accountUser,
          "account_password": accountPassword,
          "apikey": apikey,
          "status": status,
          "default": isDefault,
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to store courier');
      }
    } on FormatException {
      throw Exception('Invalid courier ID format');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Bad request: Invalid data provided');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden: Access denied or invalid credentials');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Courier account already exists');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCouriers(String acno) async {
    try {
      final response = await _dio.post(
        'courier/index',
        data: {"acno": acno},
      );
      
      if (response.statusCode == 200) {
        final List payload = response.data;
        return payload.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to load couriers');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Bad request: Invalid data provided');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden: Access denied or invalid credentials');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
} 