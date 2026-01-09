import 'dart:convert';
import 'dart:io';
import 'package:age_of_gold_mobile/auth/auth_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/services/basic_response.dart';
import '../models/services/user_response.dart';

class SettingsApi {
  static final Dio _dio = AuthApi.createDio();

  static Future<BasicResponse> updateUsername(String newUsername) async {
    try {
      final response = await _dio.patch(
        "${dotenv.env['API_VERSION']}/user/username",
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: jsonEncode(<String, String>{"new_username": newUsername}),
      );
      final basicResponse = BasicResponse.fromJson(response.data);
      if (basicResponse.success == null || basicResponse.success == false) {
        throw Exception("Couldn't change username");
      }
      return basicResponse;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  static Future<BasicResponse> updatePassword(String newPassword) async {
    try {
      final response = await _dio.patch(
        "${dotenv.env['API_VERSION']}/password/reset",
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: jsonEncode(<String, String>{"new_password": newPassword}),
      );
      final basicResponse = BasicResponse.fromJson(response.data);
      if (basicResponse.success == null || basicResponse.success == false) {
        throw Exception("Couldn't change password");
      }
      return basicResponse;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  static Future<BasicResponse> updateAvatar(
      String filePath,
      bool defaultAvatar,
      ) async {
    try {
      FormData? formData;
      if (!defaultAvatar) {
        String fileName = filePath.split("/").last;
        final formMap = <String, dynamic>{
          "avatar": await MultipartFile.fromFile(filePath, filename: fileName),
        };
        formData = FormData.fromMap(formMap);
      }

      final response = await _dio.patch(
        "${dotenv.env['API_VERSION']}/user/avatar",
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: formData,
      );
      final basicResponse = BasicResponse.fromJson(response.data);
      if (basicResponse.success == null || basicResponse.success == false) {
        throw Exception("Couldn't change avatar");
      }
      return basicResponse;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  static Future<BasicResponse> deleteAccount() async {
    try {
      final response = await _dio.delete(
        "${dotenv.env['API_VERSION']}/delete/account",
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
      );
      final basicResponse = BasicResponse.fromJson(response.data);
      if (basicResponse.success == null || basicResponse.success == false) {
        throw Exception("Couldn't change password");
      }
      return basicResponse;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}
