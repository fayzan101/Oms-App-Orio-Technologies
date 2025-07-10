import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../config/api_config.dart';

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
  
  // Use configurable base URL
  static String get baseUrl => ApiConfig.baseUrl;

  void init() {
    print('ApiService.init called with baseUrl: $baseUrl');
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(seconds: ApiConfig.receiveTimeout),
      headers: ApiConfig.defaultHeaders,
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      logPrint: (obj) => print('Dio Log: $obj'),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('Dio Request: ${options.method} ${options.path}');
        print('Dio Request Headers: ${options.headers}');
        handler.next(options);
      },
      onError: (error, handler) {
        print('Dio Error: ${error.message}');
        print('Dio Error Response: ${error.response?.data}');
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
  Future<ApiResponse> post(String endpoint, {dynamic data, Map<String, String>? headers}) async {
    try {
      print('ApiService.post called with endpoint: $endpoint');
      print('ApiService.post headers: $headers');
      
      final options = headers != null ? Options(headers: headers) : null;
      print('ApiService.post options: ${options?.headers}');
      
      final response = await _dio.post(endpoint, data: data, options: options);
      
      print('ApiService.post response status: ${response.statusCode}');
      print('ApiService.post response data: ${response.data}');
      
      return ApiResponse(
        data: response.data,
        statusCode: response.statusCode,
        headers: _convertHeaders(response.headers),
      );
    } on DioException catch (e) {
      print('ApiService.post DioException: ${e.message}');
      print('ApiService.post DioException response: ${e.response?.data}');
      print('ApiService.post DioException status: ${e.response?.statusCode}');
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