import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:age_of_gold_mobile/auth/auth_api.dart';
import 'package:age_of_gold_mobile/models/services/basic_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/services/avatar_version_response.dart';
import '../models/services/user_response.dart';

class UserApi {
  static final Dio _dio = AuthApi.createDio();

  static Future<Uint8List> getAvatar(int? userId, bool? isDefault) async {
    final Map<String, dynamic> data = {};

    if (userId != null) {
      data['user_id'] = userId;
    }

    if (isDefault != null) {
      data['is_default'] = isDefault;
    }
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/user/avatar",
        options: Options(
          responseType: ResponseType.bytes,
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: data.isNotEmpty ? data : null,
      );
      if (response.data == null) {
        throw Exception("Couldn't get avatar");
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  static Future<int> getAvatarVersion(int userId) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/user/avatar/version",
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: jsonEncode({'user_id': userId}),
      );
      final avatarVersionResponse = AvatarVersionResponse.fromJson(response.data);
      if (avatarVersionResponse.success == null || avatarVersionResponse.success! == false || avatarVersionResponse.avatarVersion == null) {
        throw Exception("Couldn't get avatar version details");
      }
      return avatarVersionResponse.avatarVersion!;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }


  static Future<UserResponse> getUser(int? userId) async {
    final Map<String, dynamic> data = {};

    if (userId != null) {
      data['user_id'] = userId;
    }
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/user",
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: data.isNotEmpty ? data : null,
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


}
