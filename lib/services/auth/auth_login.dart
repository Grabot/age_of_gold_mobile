import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:dio/dio.dart';
import '../../models/services/sign_in_request.dart';
import '../../models/services/login_response.dart';
import '../../models/services/sign_up_request.dart';
import 'app_interceptors.dart';
import 'auth_api.dart';

class AuthLogin {
  static AuthLogin? _instance;
  factory AuthLogin() => _instance ??= AuthLogin._internal();
  AuthLogin._internal();

  Future<LoginResponse> signUp(SignUpRequest signUpRequest) async {
    try {
      final response = await CleanApi().dio.post(
        "${dotenv.env['API_VERSION']}/register",
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: signUpRequest.toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      if (loginResponse.accessToken == null ||
          loginResponse.refreshToken == null) {
        throw UnauthorizedException(
          response.requestOptions,
          "Invalid login response",
        );
      }
      return loginResponse;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<LoginResponse> signIn(SignInRequest signInRequest) async {
    try {
      final response = await CleanApi().dio.post(
        "${dotenv.env['API_VERSION']}/login",
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: signInRequest.toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      if (loginResponse.accessToken == null ||
          loginResponse.refreshToken == null) {
        throw UnauthorizedException(
          response.requestOptions,
          "Invalid login response",
        );
      }
      return loginResponse;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<LoginResponse> refreshToken(
    String accessToken,
    String refreshToken,
  ) async {
    try {
      final response = await CleanApi().dio.post(
        "${dotenv.env['API_VERSION']}/login/token/refresh",
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: jsonEncode(<String, String>{
          "access_token": accessToken,
          "refresh_token": refreshToken,
        }),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      if (loginResponse.accessToken == null ||
          loginResponse.refreshToken == null) {
        throw Exception("Refresh token is not valid");
      }
      return loginResponse;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<LoginResponse> loginToken() async {
    try {
      final response = await AuthApi().dio.post(
        "${dotenv.env['API_VERSION']}/login/token",
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      if (loginResponse.accessToken == null ||
          loginResponse.refreshToken == null) {
        throw UnauthorizedException(
          response.requestOptions,
          "Invalid login response",
        );
      }
      return loginResponse;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}
