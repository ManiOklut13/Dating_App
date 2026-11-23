import 'package:dio/dio.dart';
import 'api_config.dart';
import 'secure_token_storage.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Do not attach token to public auth endpoints
          final isPublicAuth = options.path.contains('/v1/auth/signin') ||
              options.path.contains('/v1/auth/signup') ||
              options.path.contains('/v1/auth/refresh') ||
              options.path.contains('/v1/auth/otp/send') ||
              options.path.contains('/v1/auth/otp/verify');

          if (!isPublicAuth) {
            final token = await SecureTokenStorage.instance.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final isRefreshRequest = error.requestOptions.path.contains('/v1/auth/refresh');
            final isSignInRequest = error.requestOptions.path.contains('/v1/auth/signin');

            if (!isRefreshRequest && !isSignInRequest) {
              final refreshToken = await SecureTokenStorage.instance.getRefreshToken();
              if (refreshToken != null && refreshToken.isNotEmpty) {
                try {
                  // Attempt refresh
                  final refreshResponse = await Dio(
                    BaseOptions(
                      baseUrl: ApiConfig.baseUrl,
                      connectTimeout: const Duration(seconds: 10),
                      receiveTimeout: const Duration(seconds: 10),
                    ),
                  ).post(
                    ApiConfig.refresh,
                    data: {'refresh_token': refreshToken},
                  );

                  if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
                    final data = refreshResponse.data;
                    final session = data['session'];
                    final user = data['user'];

                    if (session != null && session['access_token'] != null) {
                      final newAccessToken = session['access_token'].toString();
                      final newRefreshToken = (session['refresh_token'] ?? refreshToken).toString();
                      final userId = (user?['id'] ?? user?['uid'] ?? await SecureTokenStorage.instance.getUserId() ?? '').toString();

                      await SecureTokenStorage.instance.saveSession(
                        accessToken: newAccessToken,
                        refreshToken: newRefreshToken,
                        userId: userId,
                      );

                      // Retry the failed original request with new token
                      final retryOptions = error.requestOptions;
                      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

                      final retryResponse = await dio.fetch(retryOptions);
                      return handler.resolve(retryResponse);
                    }
                  }
                } catch (_) {
                  // Refresh failed, clean up session
                  await SecureTokenStorage.instance.clearSession();
                }
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
