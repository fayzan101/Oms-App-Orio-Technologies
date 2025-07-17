import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/courier_model.dart';

class CourierPaymentService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://oms.getorio.com/api/'));

  Future<CourierPaymentResponse> getCourierPaymentData({
    required String startDate,
    required String endDate,
    String? acno,
  }) async {
    try {
    
      final response = await _dio.post(
        'dashboard-reporting/img/shipping-icons/',
        data: {
          "start_date": startDate,
          "end_date": endDate,
          if (acno != null) "acno": acno,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        
        
        // Debug: Print the actual image paths from API
        if (data['paymentcourierpayment'] != null) {
          final courierList = data['paymentcourierpayment'] as List;
          for (var courier in courierList) {
            
          }
        }
        
        final courierResponse = CourierPaymentResponse.fromJson(data);

        
        return courierResponse;
      } else {
        
        // Return mock data for testing
        final mockData = {
          "paymentcourierpayment": [
            {
              "courier_name": "Leopards",
              "logo": "https://example.com/assets/img/shipping-icons/Leopards.svg",
              "png": "https://example.com/assets/img/shipping-icons/png/Leopards.png",
              "status": "active"
            },
            {
              "courier_name": "M&P",
              "logo": "https://example.com/assets/img/shipping-icons/M&P.svg",
              "png": "https://example.com/assets/img/shipping-icons/png/M&P.png",
              "status": "active"
            }
          ]
        };
        
        final courierResponse = CourierPaymentResponse.fromJson(mockData);
        
        
        return courierResponse;
      }
    } on DioException catch (e) {
      print('CourierPaymentService: DioException: ${e.message}');
      if (e.response != null) {
        
        
        // If the API endpoint doesn't exist yet, return mock data for testing
        if (e.response!.statusCode == 404) {
          
          final mockData = {
            "paymentcourierpayment": [
              {
                "courier_name": "Leopards",
                "logo": "https://example.com/assets/img/shipping-icons/Leopards.svg",
                "png": "https://example.com/assets/img/shipping-icons/png/Leopards.png",
                "status": "active"
              },
              {
                "courier_name": "M&P",
                "logo": "https://example.com/assets/img/shipping-icons/M&P.svg",
                "png": "https://example.com/assets/img/shipping-icons/png/M&P.png",
                "status": "active"
              },
              {
                "courier_name": "TCS",
                "logo": "https://example.com/assets/img/shipping-icons/TCS.svg",
                "png": "https://example.com/assets/img/shipping-icons/png/TCS.png",
                "status": "active"
              }
            ]
          };
          
          final courierResponse = CourierPaymentResponse.fromJson(mockData);
          
          
          return courierResponse;
        }
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      
      throw Exception('Unexpected error: $e');
    }
  }
} 