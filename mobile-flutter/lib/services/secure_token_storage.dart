import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  static final SecureTokenStorage instance = SecureTokenStorage._internal();
  SecureTokenStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _keyAccessToken = 'younme_access_token';
  static const String _keyRefreshToken = 'younme_refresh_token';
  static const String _keyUserId = 'younme_user_id';
  static const String _keyUserEmail = 'younme_user_email';

  // In-memory cache for fast synchronous access & headless fallback
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  String? _cachedUserId;
  String? _cachedUserEmail;

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    String? email,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    _cachedUserId = userId;
    _cachedUserEmail = email;

    try {
      await Future.wait([
        _storage.write(key: _keyAccessToken, value: accessToken),
        _storage.write(key: _keyRefreshToken, value: refreshToken),
        _storage.write(key: _keyUserId, value: userId),
        if (email != null) _storage.write(key: _keyUserEmail, value: email),
      ]);
    } catch (_) {
      // Memory fallback remains active if secure storage fails on desktop
    }
  }

  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null && _cachedAccessToken!.isNotEmpty) {
      return _cachedAccessToken;
    }
    try {
      _cachedAccessToken = await _storage.read(key: _keyAccessToken);
      return _cachedAccessToken;
    } catch (_) {
      return _cachedAccessToken;
    }
  }

  Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null && _cachedRefreshToken!.isNotEmpty) {
      return _cachedRefreshToken;
    }
    try {
      _cachedRefreshToken = await _storage.read(key: _keyRefreshToken);
      return _cachedRefreshToken;
    } catch (_) {
      return _cachedRefreshToken;
    }
  }

  Future<String?> getUserId() async {
    if (_cachedUserId != null && _cachedUserId!.isNotEmpty) {
      return _cachedUserId;
    }
    try {
      _cachedUserId = await _storage.read(key: _keyUserId);
      return _cachedUserId;
    } catch (_) {
      return _cachedUserId;
    }
  }

  Future<String?> getUserEmail() async {
    if (_cachedUserEmail != null && _cachedUserEmail!.isNotEmpty) {
      return _cachedUserEmail;
    }
    try {
      _cachedUserEmail = await _storage.read(key: _keyUserEmail);
      return _cachedUserEmail;
    } catch (_) {
      return _cachedUserEmail;
    }
  }

  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedUserId = null;
    _cachedUserEmail = null;

    try {
      await Future.wait([
        _storage.delete(key: _keyAccessToken),
        _storage.delete(key: _keyRefreshToken),
        _storage.delete(key: _keyUserId),
        _storage.delete(key: _keyUserEmail),
      ]);
    } catch (_) {
      // Memory cache is already cleared
    }
  }
}
