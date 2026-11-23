import 'package:dio/dio.dart';
import '../models/auth_user_model.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'secure_token_storage.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  final Dio _dio = ApiClient.instance.dio;

  /// Sign in with email and password
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.signIn,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final result = SignInResult.fromJson(response.data as Map<String, dynamic>);
        if (result.success && result.session != null && result.user != null) {
          await SecureTokenStorage.instance.saveSession(
            accessToken: result.session!.accessToken,
            refreshToken: result.session!.refreshToken,
            userId: result.user!.id,
            email: result.user!.email,
          );
        }
        return result;
      }
      return SignInResult.failure('Authentication failed: Invalid server response.');
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Sign in failed. Please check your credentials.';
      return SignInResult.failure(message);
    } catch (e) {
      return SignInResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Register a new user
  Future<SignInResult> signUp({
    required String email,
    required String password,
    String? phone,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.signUp,
        data: {
          'email': email.trim(),
          'password': password,
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
          if (firstName != null && firstName.trim().isNotEmpty) 'firstName': firstName.trim(),
          if (lastName != null && lastName.trim().isNotEmpty) 'lastName': lastName.trim(),
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final result = SignInResult.fromJson(response.data as Map<String, dynamic>);
        if (result.success && result.session != null && result.user != null) {
          await SecureTokenStorage.instance.saveSession(
            accessToken: result.session!.accessToken,
            refreshToken: result.session!.refreshToken,
            userId: result.user!.id,
            email: result.user!.email,
          );
        }
        return result;
      }
      return SignInResult.failure('Registration failed.');
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Registration failed. Please check your information.';
      return SignInResult.failure(message);
    } catch (e) {
      return SignInResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Dispatch OTP via phone or email
  Future<Map<String, dynamic>> sendOtp({
    required String type,
    required String identifier,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.sendOtp,
        data: {
          'type': type,
          'identifier': identifier.trim(),
        },
      );
      return (response.data as Map<String, dynamic>?) ?? {'success': true};
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e) ?? 'Failed to dispatch verification code';
      throw Exception(msg);
    }
  }

  /// Verify OTP token
  Future<SignInResult> verifyOtp({
    required String type,
    required String identifier,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.verifyOtp,
        data: {
          'type': type,
          'identifier': identifier.trim(),
          'token': token.trim(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final result = SignInResult.fromJson(response.data as Map<String, dynamic>);
        if (result.success && result.session != null && result.user != null) {
          await SecureTokenStorage.instance.saveSession(
            accessToken: result.session!.accessToken,
            refreshToken: result.session!.refreshToken,
            userId: result.user!.id,
            email: result.user!.email,
          );
        }
        return result;
      }
      return SignInResult.failure('OTP verification failed.');
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Invalid or expired OTP token.';
      return SignInResult.failure(message);
    } catch (e) {
      return SignInResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Fetch full user profile & settings
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConfig.currentUser);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get onboarding status and completion progress
  Future<OnboardingStatusResult?> getOnboardingStatus(String userId) async {
    try {
      final response = await _dio.get('${ApiConfig.onboardingStatus}/$userId');
      if (response.statusCode == 200 && response.data != null) {
        return OnboardingStatusResult.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Save onboarding wizard step to backend
  Future<Map<String, dynamic>?> saveOnboardingWizard(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(
        ApiConfig.onboardingWizard,
        data: payload,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Request password reset
  Future<bool> forgotPassword({
    required String type,
    required String identifier,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.forgotPassword,
        data: {
          'type': type,
          'identifier': identifier.trim(),
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Confirm password reset
  Future<bool> resetPassword({
    required String type,
    required String identifier,
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.resetPassword,
        data: {
          'type': type,
          'identifier': identifier.trim(),
          'token': token.trim(),
          'newPassword': newPassword,
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await SecureTokenStorage.instance.clearSession();
  }

  String? _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final map = e.response!.data as Map;
      if (map['message'] != null) {
        if (map['message'] is List) {
          return (map['message'] as List).join(', ');
        }
        return map['message'].toString();
      }
      if (map['error'] != null) {
        return map['error'].toString();
      }
    }
    return e.message;
  }
}
