import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:age_of_gold_mobile/models/services/user_response.dart';
import 'package:dio/dio.dart';
import '../../models/services/basic_response.dart';
import 'auth_api.dart';

class AuthSettings {
  static AuthSettings? _instance;
  factory AuthSettings() => _instance ??= AuthSettings._internal();
  AuthSettings._internal();

  Future<UserResponse> getUserDetails() async {
    try {
      final response = await AuthApi().dio.get(
        "${dotenv.env['API_VERSION']}/user/detail",
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
      );
      final userResponse = UserResponse.fromJson(response.data);
      if (userResponse.id == null || userResponse.username == null) {
        throw Exception("Couldn't get user details");
      }
      return userResponse;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Uint8List> getAvatar(bool isDefault) async {
    try {
      final uri = Uri.parse("${dotenv.env['API_VERSION']}/user/avatar").replace(
        queryParameters: isDefault == true ? {'get_default': 'true'} : null,
      );
      final response = await AuthApi().dio.get(
        uri.toString(),
        options: Options(
          responseType: ResponseType.bytes,
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
      );
      if (response.data == null) {
        throw Exception("Couldn't get avatar");
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<BasicResponse> updateUsername(String newUsername) async {
    try {
      final response = await AuthApi().dio.patch(
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

  Future<BasicResponse> updateAvatar(
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

      final response = await AuthApi().dio.patch(
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
}
