import 'dart:convert';

/// Sign-in response DTO mapping to POST /v1/auth/signin response
class SignInResponseDto {
  final bool success;
  final String message;
  final SignInUserDto user;
  final dynamic session;

  SignInResponseDto({
    required this.success,
    required this.message,
    required this.user,
    this.session,
  });

  factory SignInResponseDto.fromJson(Map<String, dynamic> json) {
    return SignInResponseDto(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: SignInUserDto.fromJson(json['user'] as Map<String, dynamic>),
      session: json['session'],
    );
  }
}

/// Sign-in user DTO
class SignInUserDto {
  final String uid;
  final String id;
  final String email;
  final String phone;

  SignInUserDto({
    required this.uid,
    required this.id,
    required this.email,
    required this.phone,
  });

  factory SignInUserDto.fromJson(Map<String, dynamic> json) {
    return SignInUserDto(
      uid: json['uid'] as String,
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }
}

/// OTP send response DTO
class OtpSendResponse {
  final bool success;
  final String message;
  final String type;
  final String identifier;

  OtpSendResponse({
    required this.success,
    required this.message,
    required this.type,
    required this.identifier,
  });

  factory OtpSendResponse.fromJson(Map<String, dynamic> json) {
    return OtpSendResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      type: json['type'] as String,
      identifier: json['identifier'] as String,
    );
  }
}

/// OTP verify response DTO
class OtpVerifyResponse {
  final bool success;
  final String message;
  final UserAuthDto user;
  final dynamic session;

  OtpVerifyResponse({
    required this.success,
    required this.message,
    required this.user,
    this.session,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: UserAuthDto.fromJson(json['user'] as Map<String, dynamic>),
      session: json['session'],
    );
  }
}

/// User auth DTO from OTP/Google/Apple response
class UserAuthDto {
  final String id;
  final String uid;
  final String email;
  final String phone;
  final String role;
  final String accountStatus;

  UserAuthDto({
    required this.id,
    required this.uid,
    required this.email,
    required this.phone,
    required this.role,
    required this.accountStatus,
  });

  factory UserAuthDto.fromJson(Map<String, dynamic> json) {
    return UserAuthDto(
      id: json['id'] as String,
      uid: json['uid'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      accountStatus: json['account_status'] as String,
    );
  }
}

/// OAuth response DTO (Google/Apple)
class OAuthResponse {
  final bool success;
  final String message;
  final UserAuthDto user;
  final dynamic session;

  OAuthResponse({
    required this.success,
    required this.message,
    required this.user,
    this.session,
  });

  factory OAuthResponse.fromJson(Map<String, dynamic> json) {
    return OAuthResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: UserAuthDto.fromJson(json['user'] as Map<String, dynamic>),
      session: json['session'],
    );
  }
}

/// Forgot password response DTO
class ForgotPasswordResponse {
  final bool success;
  final String message;

  ForgotPasswordResponse({
    required this.success,
    required this.message,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }
}

/// Reset password response DTO
class ResetPasswordResponse {
  final bool success;
  final String message;

  ResetPasswordResponse({
    required this.success,
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }
}