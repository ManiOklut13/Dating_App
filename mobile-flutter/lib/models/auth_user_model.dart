class AuthUserModel {
  final String id;
  final String? email;
  final String? phone;
  final String? role;
  final String? accountStatus;

  const AuthUserModel({
    required this.id,
    this.email,
    this.phone,
    this.role,
    this.accountStatus,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: (json['id'] ?? json['uid'] ?? '').toString(),
      email: json['email'] as String?,
      phone: (json['phone'] ?? json['phone_number']) as String?,
      role: json['role'] as String?,
      accountStatus: json['account_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'role': role,
      'account_status': accountStatus,
    };
  }
}

class AuthSessionModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int? expiresIn;
  final int? expiresAt;

  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
    this.expiresIn,
    this.expiresAt,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: (json['access_token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      tokenType: (json['token_type'] ?? 'bearer').toString(),
      expiresIn: json['expires_in'] as int?,
      expiresAt: json['expires_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'expires_at': expiresAt,
    };
  }
}

class SignInResult {
  final bool success;
  final String message;
  final bool requiresEmailConfirmation;
  final AuthUserModel? user;
  final AuthSessionModel? session;
  final String? error;

  const SignInResult({
    required this.success,
    required this.message,
    this.requiresEmailConfirmation = false,
    this.user,
    this.session,
    this.error,
  });

  factory SignInResult.fromJson(Map<String, dynamic> json) {
    return SignInResult(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      requiresEmailConfirmation: json['requiresEmailConfirmation'] == true,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? AuthUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      session: json['session'] != null && json['session'] is Map<String, dynamic>
          ? AuthSessionModel.fromJson(json['session'] as Map<String, dynamic>)
          : null,
    );
  }

  factory SignInResult.failure(String errorMessage) {
    return SignInResult(
      success: false,
      message: errorMessage,
      requiresEmailConfirmation: false,
      error: errorMessage,
    );
  }
}

class OnboardingStatusResult {
  final String userId;
  final int progress;
  final bool isVerified;
  final List<String> missingItems;

  const OnboardingStatusResult({
    required this.userId,
    required this.progress,
    required this.isVerified,
    required this.missingItems,
  });

  bool get isComplete => progress >= 70;

  factory OnboardingStatusResult.fromJson(Map<String, dynamic> json) {
    final rawMissing = json['missing_items'] ?? json['missingRequirements'];
    final List<String> missing = [];
    if (rawMissing is List) {
      for (final item in rawMissing) {
        if (item != null) missing.add(item.toString());
      }
    }

    return OnboardingStatusResult(
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      progress: (json['progress'] ?? json['profile_progress'] ?? 0) as int,
      isVerified: json['is_verified'] == true || json['isVerified'] == true,
      missingItems: missing,
    );
  }
}
