import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Resolves the appropriate base URL for the current runtime environment.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080';
      }
    } catch (_) {
      // Fallback if Platform is not available
    }
    return 'http://localhost:8080';
  }

  // Auth endpoints
  static const String signIn = '/v1/auth/signin';
  static const String signUp = '/v1/auth/signup';
  static const String refresh = '/v1/auth/refresh';
  static const String sendOtp = '/v1/auth/otp/send';
  static const String verifyOtp = '/v1/auth/otp/verify';
  static const String forgotPassword = '/v1/auth/forgot-password';
  static const String resetPassword = '/v1/auth/reset-password';
  static const String currentUser = '/v1/auth/me';

  // Onboarding endpoints
  static const String onboardingWizard = '/v1/onboarding/wizard';
  static const String onboardingStatus = '/v1/onboarding/status';
  static const String onboardingDemographics = '/v1/onboarding/demographics';
}
