import 'package:dio/dio.dart';
import 'package:younme_mobile/config/env_config.dart';

class NetworkService {
  final Dio _dio = Dio();

  NetworkService() {
    _dio.options.baseUrl = EnvConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
  }

  Dio get dio => _dio;
}