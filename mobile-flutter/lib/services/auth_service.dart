import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:younme_mobile/models/chat_profile_models.dart';
import 'package:younme_mobile/services/network_service.dart';
import 'package:younme_mobile/services/auth_dto.dart';

class AuthService {
  final NetworkService _network = NetworkService();

  /// POST /v1/auth/signin - Validates email/password and returns Supabase JWT session
  Future<SignInResponseDto> signIn(String email, String password) async {
    final response = await _network.dio.post(
      '/v1/auth/signin',
      data: {
        'email': email,
        'password': password,
      },
    );
    return SignInResponseDto.fromJson(response.data);
  }

  /// POST /v1/auth/otp/send - Dispatch OTP
  Future<OtpSendResponse> sendOtp(String type, String identifier) async {
    final response = await _network.dio.post(
      '/v1/auth/otp/send',
      data: {
        'type': type,
        'identifier': identifier,
      },
    );
    return OtpSendResponse.fromJson(response.data);
  }

  /// POST /v1/auth/otp/verify - Verify OTP token
  Future<OtpVerifyResponse> verifyOtp(String type, String identifier, String token) async {
    final response = await _network.dio.post(
      '/v1/auth/otp/verify',
      data: {
        'type': type,
        'identifier': identifier,
        'token': token,
      },
    );
    return OtpVerifyResponse.fromJson(response.data);
  }

  /// POST /v1/auth/google - Google OAuth
  Future<OAuthResponse> signInWithGoogle(String idToken, [String? accessToken]) async {
    final response = await _network.dio.post(
      '/v1/auth/google',
      data: {
        'id_token': idToken,
        'access_token': accessToken,
      },
    );
    return OAuthResponse.fromJson(response.data);
  }

  /// POST /v1/auth/apple - Apple OAuth
  Future<OAuthResponse> signInWithApple(String idToken, [String? nonce]) async {
    final response = await _network.dio.post(
      '/v1/auth/apple',
      data: {
        'id_token': idToken,
        'nonce': nonce,
      },
    );
    return OAuthResponse.fromJson(response.data);
  }

  /// POST /v1/auth/forgot-password - Password reset request
  Future<ForgotPasswordResponse> forgotPassword(String identifier, {String? type}) async {
    final response = await _network.dio.post(
      '/v1/auth/forgot-password',
      data: {
        'identifier': identifier,
        if (type != null) 'type': type,
      },
    );
    return ForgotPasswordResponse.fromJson(response.data);
  }

  /// POST /v1/auth/reset-password - Reset password
  Future<ResetPasswordResponse> resetPassword(
      {required String newPassword,
      required String token,
      required String identifier,
      String? type}) async {
    final response = await _network.dio.post(
      '/v1/auth/reset-password',
      data: {
        'new_password': newPassword,
        'token': token,
        'identifier': identifier,
        if (type != null) 'type': type,
      },
    );
    return ResetPasswordResponse.fromJson(response.data);
  }
}