import 'package:dio/dio.dart' show DioException;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../network/api_service.dart';

class AuthService extends GetxService {
  final ApiService _apiService = ApiService();
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService.init();
  }

  // Login method
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Prepare login data
      final loginData = {
        'email': email,
        'password': password,
      };

      // Make API call
      final response = await _apiService.post('login', data: loginData);
      
      // Parse response
      final loginResponse = LoginResponse.fromJson(response.data);
      
      if (loginResponse.status == 1 && loginResponse.payload.isNotEmpty) {
        // Login successful
        currentUser.value = loginResponse.payload.first;
        
        // Save user data to SharedPreferences
        await _saveUserData(loginResponse.payload.first);
        
        return true;
      } else {
        // Login failed
        errorMessage.value = loginResponse.message.isNotEmpty 
            ? loginResponse.message 
            : 'Login failed. Please check your credentials.';
        return false;
      }
      
    } on DioException catch (e) {
      errorMessage.value = e.message ?? 'Network error occurred';
      return false;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.userId);
      await prefs.setString('acno', user.acno);
      await prefs.setString('fullname', user.fullname);
      await prefs.setString('email', user.email);
      await prefs.setString('api_key', user.apiKey);
      await prefs.setString('customer_id', user.customerId);
      await prefs.setString('phone_no', user.phoneNo);
      await prefs.setString('otp', user.otp);
      await prefs.setBool('is_logged_in', true);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // Load user data from SharedPreferences
  Future<User?> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (!isLoggedIn) return null;
      
      final user = User(
        userId: prefs.getString('user_id') ?? '',
        acno: prefs.getString('acno') ?? '',
        fullname: prefs.getString('fullname') ?? '',
        email: prefs.getString('email') ?? '',
        apiKey: prefs.getString('api_key') ?? '',
        customerId: prefs.getString('customer_id') ?? '',
        phoneNo: prefs.getString('phone_no') ?? '',
        otp: prefs.getString('otp') ?? '',
      );
      
      currentUser.value = user;
      return user;
    } catch (e) {
      print('Error loading user data: $e');
      return null;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      currentUser.value = null;
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Get stored API key
  Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_key') ?? '';
  }
} 