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
        print('🔐 Login API response successful');
        currentUser.value = loginResponse.payload.first;
        
        // Save user data to SharedPreferences
        await _saveUserData(loginResponse.payload.first);
        
        print('🔐 Login method returning true');
        return true;
      } else {
        // Login failed
        print('🔐 Login API response failed: ${loginResponse.message}');
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

  // Forgot Password method
  Future<bool> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = {'email': email};
      final response = await _apiService.post('forgetpassword', data: data);

      // You can check for a status/message in response.data if needed
      if (response.statusCode == 200) {
        return true;
      } else {
        errorMessage.value = response.data['message'] ?? 'Failed to send reset email.';
        return false;
      }
    } on DioException catch (e) {
      errorMessage.value = e.message ?? 'Network error occurred';
      return false;
    } catch (e) {
      errorMessage.value = 'Invalid email address';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Change Password method
  Future<bool> changePassword({
    required String userId,
    required String acno,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = {
        'userid': int.tryParse(userId) ?? 0,
        'acno': acno,
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };

      final response = await _apiService.post('auth/change_password', data: data);

      if (response.statusCode == 200) {
        // Check if the response indicates success
        if (response.data['status'] == 1 || response.data['success'] == true) {
          return true;
        } else {
          errorMessage.value = response.data['message'] ?? 'Failed to change password.';
          return false;
        }
      } else {
        errorMessage.value = response.data['message'] ?? 'Failed to change password.';
        return false;
      }
    } on DioException catch (e) {
      errorMessage.value = e.message ?? 'Network error occurred';
      return false;
    } catch (e) {
      errorMessage.value = 'Old password is incorrect';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update Customer Profile method
  Future<bool> updateCustomerProfile(CustomerProfile profile) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.post('customer/updateProfile', data: profile.toJson());

      if (response.statusCode == 200) {
        // Check if the response indicates success
        if (response.data['status'] == 1 || response.data['success'] == true) {
          return true;
        } else {
          errorMessage.value = response.data['message'] ?? 'Failed to update profile.';
          return false;
        }
      } else {
        errorMessage.value = response.data['message'] ?? 'Failed to update profile.';
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
      
      
      
      // Verify the data was saved
      final savedLoginStatus = prefs.getBool('is_logged_in') ?? false;
      
    } catch (e) {
      
    }
  }

  // Load user data from SharedPreferences
  Future<User?> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      
      
      if (!isLoggedIn) {
        
        return null;
      }
      
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
      
      return null;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if "Remember Me" is enabled
      final rememberMe = prefs.getBool('remember_me') ?? false;
      
      if (rememberMe) {
        // If "Remember Me" is enabled, only clear login status but keep credentials
        await prefs.setBool('is_logged_in', false);
        currentUser.value = null;
      } else {
        // If "Remember Me" is not enabled, clear everything
        await prefs.clear();
        currentUser.value = null;
      }
    } catch (e) {
      
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

  // Utility methods for getting current user data for API calls
  String? getCurrentAcno() {
    return currentUser.value?.acno;
  }

  int? getCurrentUserId() {
    final userId = currentUser.value?.userId;
    return userId != null ? int.tryParse(userId) : null;
  }

  int? getCurrentCustomerId() {
    final customerId = currentUser.value?.customerId;
    return customerId != null ? int.tryParse(customerId) : null;
  }

  // Get current user data as a map for API calls
  Map<String, dynamic>? getCurrentUserData() {
    final user = currentUser.value;
    if (user == null) return null;
    
    return {
      'acno': user.acno,
      'userid': int.tryParse(user.userId) ?? 0,
      'customer_id': int.tryParse(user.customerId) ?? 0,
    };
  }

  // Check if user is logged in and has valid data
  bool hasValidUserData() {
    final user = currentUser.value;
    return user != null && 
           user.acno.isNotEmpty && 
           user.userId.isNotEmpty && 
           user.customerId.isNotEmpty;
  }

  // Clear Remember Me data
  Future<void> clearRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_email');
      await prefs.remove('remember_password');
      await prefs.setBool('remember_me', false);
      await prefs.setBool('is_logged_in', false);
    } catch (e) {
      print('Error clearing Remember Me data: $e');
    }
  }
} 