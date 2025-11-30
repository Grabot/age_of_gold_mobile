import 'package:dio/dio.dart';
import 'app_interceptors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class AuthApi {
  final dio = createDio();

  AuthApi._internal();

  static final _singleton = AuthApi._internal();

  factory AuthApi() => _singleton;

  static Dio createDio() {
    var dio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['BASEURL'] ?? "",
          receiveTimeout: const Duration(seconds: 10),
          connectTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        )
    );

    dio.interceptors.add(AppInterceptors(dio));

    return dio;
  }
}

class CleanApi {
  static final CleanApi _singleton = CleanApi._internal();
  factory CleanApi() => _singleton;
  CleanApi._internal();
  final Dio dio = createDio();

  static Dio createDio() {
    return Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASEURL'] ?? "",
        receiveTimeout: const Duration(seconds: 10),
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );
  }
}