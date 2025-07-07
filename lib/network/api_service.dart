import 'package:dio/dio.dart';
import 'package:get/get.dart';

// Custom response type to avoid conflicts
class ApiResponse {
  final dynamic data;
  final int? statusCode;
  final Map<String, dynamic>? headers;

  ApiResponse({
    required this.data,
    this.statusCode,
    this.headers,
  });
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  
  // Replace with your actual API base URL
  static const String baseUrl = 'https://oms.getorio.com/api/';

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        print('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  // Generic GET request
  Future<ApiResponse> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return ApiResponse(
        data: response.data,
        statusCode: response.statusCode,
        headers: _convertHeaders(response.headers),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic POST request
  Future<ApiResponse> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return ApiResponse(
        data: response.data,
        statusCode: response.statusCode,
        headers: _convertHeaders(response.headers),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Convert headers to Map<String, dynamic>
  Map<String, dynamic>? _convertHeaders(Headers? headers) {
    if (headers == null) return null;
    final Map<String, dynamic> result = {};
    headers.forEach((key, values) {
      result[key] = values.join(', ');
    });
    return result;
  }

  // Handle Dio errors without enum switches
  String _handleDioError(DioException error) {
    final errorType = error.type.toString();
    
    if (errorType.contains('connectionTimeout') || 
        errorType.contains('sendTimeout') || 
        errorType.contains('receiveTimeout')) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (errorType.contains('badResponse')) {
      return 'Server error: ${error.response?.statusCode}';
    } else if (errorType.contains('cancel')) {
      return 'Request cancelled';
    } else if (errorType.contains('connectionError')) {
      return 'No internet connection';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
} 