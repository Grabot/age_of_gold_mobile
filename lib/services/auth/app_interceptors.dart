import 'dart:async';
import 'package:dio/dio.dart';
import 'package:age_of_gold_mobile/constants/route_paths.dart' as routes;
import 'package:age_of_gold_mobile/utils/navigation_service.dart';
import 'package:age_of_gold_mobile/utils/secure_storage.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';
import 'package:age_of_gold_mobile/models/services/login_response.dart';

import '../../utils/auth_store.dart';
import 'auth_login.dart';

class AppInterceptors extends Interceptor {
  final Dio dio;
  final SecureStorage secureStorage;
  final NavigationService navigationService;
  bool _isRefreshing = false;
  final List<Function> _requestQueue = [];

  AppInterceptors(this.dio)
    : secureStorage = SecureStorage(),
      navigationService = locator<NavigationService>();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      String? accessToken = await secureStorage.getAccessToken();
      final expiration = await secureStorage.getAccessTokenExpiration();

      if (accessToken == null || expiration == null) {
        throw DioException(
          requestOptions: options,
          error: 'user not authorized',
        );
      }

      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (expiration - currentTime < 30) {
        if (!_isRefreshing) {
          try {
            _isRefreshing = true;
            final refreshToken = await secureStorage.getRefreshToken();
            if (refreshToken == null) {
              throw Exception("refresh token is null");
            }
            LoginResponse? loginResponse = await AuthLogin().refreshToken(
              accessToken,
              refreshToken,
            );
            await AuthStore().successfulLogin(loginResponse);
            accessToken = await secureStorage.getAccessToken();
            for (var request in _requestQueue) {
              request();
            }
            _requestQueue.clear();
          } catch (e) {
            throw DioException(
              requestOptions: options,
              error: 'Token could not be refreshed',
            );
          } finally {
            _isRefreshing = false;
          }
        } else {
          // Add the request to the queue
          _requestQueue.add(() async {
            options.headers['Authorization'] =
                'Bearer ${await secureStorage.getAccessToken()}';
            final response = await dio.request(
              options.path,
              data: options.data,
              queryParameters: options.queryParameters,
              options: Options(
                method: options.method,
                headers: options.headers,
              ),
            );
            handler.resolve(response);
          });
          return;
        }
      }

      options.headers['Authorization'] = 'Bearer $accessToken';
      return handler.next(options);
    } catch (e) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'Failed to attach token: $e',
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (!_isRefreshing) {
        try {
          _isRefreshing = true;
          final accessToken = await secureStorage.getAccessToken();
          final refreshToken = await secureStorage.getRefreshToken();
          if (refreshToken != null && accessToken != null) {
            try {
              LoginResponse? loginResponse = await AuthLogin().refreshToken(
                accessToken,
                refreshToken,
              );
              await AuthStore().successfulLogin(loginResponse);
              // Retry the original request with the new token
              final options = err.requestOptions;
              options.headers['Authorization'] =
                  'Bearer ${await secureStorage.getAccessToken()}';
              final response = await dio.request(
                options.path,
                data: options.data,
                queryParameters: options.queryParameters,
                options: Options(
                  method: options.method,
                  headers: options.headers,
                ),
              );
              return handler.resolve(response);
            } catch (e) {
              // Refresh token failed. Continue, which will clear the tokens and navigate to login
            }
          }
          // If refresh fails, navigate to login
          await secureStorage.clearTokens();
          showToastMessage("Session expired. Please log in again.");
          navigationService.navigateTo(routes.signInRoute);
          return;
        } finally {
          _isRefreshing = false;
        }
      } else {
        // If already refreshing, reject and let the queue handle it
        return handler.reject(err);
      }
    }

    switch (err.type) {
      case DioExceptionType.badResponse:
        String? errorMessage;
        if (err.response?.data is Map) {
          if (err.response!.data['detail'] != null) {
            errorMessage = err.response!.data['detail'].toString();
          }
        }
        switch (err.response?.statusCode) {
          case 400:
            return handler.next(
              BadRequestException(
                err.requestOptions,
                errorMessage ?? 'Bad request',
              ),
            );
          case 404:
            return handler.next(
              NotFoundException(
                err.requestOptions,
                errorMessage ?? 'Resource not found',
              ),
            );
          case 409:
            return handler.next(
              ConflictException(
                err.requestOptions,
                errorMessage ?? 'Conflict occurred',
              ),
            );
          case 500:
            return handler.next(
              InternalServerErrorException(
                err.requestOptions,
                errorMessage ?? 'Internal server error',
              ),
            );
          default:
            return handler.next(
              UnknownException(
                err.requestOptions,
                errorMessage ?? 'An unknown error occurred',
              ),
            );
        }
      case DioExceptionType.connectionTimeout:
        return handler.next(DeadlineExceededException(err.requestOptions));
      case DioExceptionType.sendTimeout:
        return handler.next(DeadlineExceededException(err.requestOptions));
      case DioExceptionType.receiveTimeout:
        return handler.next(DeadlineExceededException(err.requestOptions));
      case DioExceptionType.connectionError:
        return handler.next(NoInternetConnectionException(err.requestOptions));
      case DioExceptionType.unknown:
        return handler.next(NoInternetConnectionException(err.requestOptions));
      default:
        return handler.next(UnknownException(err.requestOptions));
    }
  }
}

class AppException extends DioException {
  AppException({
    required super.requestOptions,
    String super.message = "An error occurred",
    super.type = DioExceptionType.badResponse,
    dynamic super.error,
  });

  @override
  String toString() => message ?? 'An error occurred';
}

class UnauthorizedException extends AppException {
  UnauthorizedException(RequestOptions r, [String? message])
    : super(
        requestOptions: r,
        message: message ?? 'Unauthorized',
        type: DioExceptionType.badResponse,
      );
}

class BadRequestException extends AppException {
  BadRequestException(RequestOptions r, [String? message])
    : super(
        requestOptions: r,
        message: message ?? 'Invalid request',
        type: DioExceptionType.badResponse,
      );
}

class NotFoundException extends AppException {
  NotFoundException(RequestOptions r, [String? message])
    : super(
        requestOptions: r,
        message: message ?? 'The requested information could not be found',
        type: DioExceptionType.badResponse,
      );
}

class ConflictException extends AppException {
  ConflictException(RequestOptions r, [String? message])
    : super(
        requestOptions: r,
        message: message ?? 'Conflict occurred',
        type: DioExceptionType.badResponse,
      );
}

class InternalServerErrorException extends AppException {
  InternalServerErrorException(RequestOptions r, [String? message])
    : super(
        requestOptions: r,
        message: message ?? 'Unknown error occurred, please try again later.',
        type: DioExceptionType.badResponse,
      );
}

class NoInternetConnectionException extends AppException {
  NoInternetConnectionException(RequestOptions r, [String? message])
    : super(
        requestOptions: r,
        message:
            message ?? 'No internet connection detected, please try again.',
        type: DioExceptionType.connectionError,
      );
}

class DeadlineExceededException extends AppException {
  DeadlineExceededException(RequestOptions r, [String? message])
    : super(
        requestOptions: r,
        message: message ?? 'The connection has timed out, please try again.',
        type: DioExceptionType.connectionTimeout,
      );
}

class UnknownException extends AppException {
  UnknownException(RequestOptions r, [String? message])
    : super(
        requestOptions: r,
        message: message ?? 'An unknown error occurred.',
        type: DioExceptionType.unknown,
      );
}
