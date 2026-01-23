import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/group.dart';
import '../models/services/basic_response.dart';
import 'auth_api.dart';

class GroupsApi {
  static final Dio _dio = AuthApi.createDio();

  static Future<int> createGroup({
    required String groupName,
    required String groupDescription,
    required String groupColour,
    required List<int> friendIds,
  }) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/group/create",
        data: jsonEncode({
          'group_name': groupName,
          'group_description': groupDescription,
          'group_colour': groupColour,
          'friend_ids': friendIds,
        }),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as int; // Return the created group ID
      }
      throw Exception('Failed to create group: Invalid response');
    } on DioException catch (e) {
      throw Exception('Failed to create group: ${e.message}');
    }
  }

  static Future<List<Group>> fetchGroups({List<int>? groupIds}) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/group/all",
        data: jsonEncode({'group_ids': groupIds}),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final groupsData = response.data['data'] as List;
        return groupsData.map((groupData) => Group.fromJson(groupData)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch groups: ${e.message}');
    }
  }

  static Future<BasicResponse> leaveGroup(int groupId) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/group/leave",
        data: jsonEncode({'group_id': groupId}),
      );
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to leave group: ${e.message}');
    }
  }

  static Future<BasicResponse> addGroupMember(int groupId, int userId) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/group/member/add",
        data: jsonEncode({'group_id': groupId, 'user_id': userId}),
      );
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to add group member: ${e.message}');
    }
  }

  static Future<BasicResponse> removeGroupMember(int groupId, int userId) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/group/member/remove",
        data: jsonEncode({'group_id': groupId, 'user_id': userId}),
      );
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to remove group member: ${e.message}');
    }
  }

  static Future<BasicResponse> promoteAdmin(int groupId, int userId, bool isAdmin) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/group/admin/promote",
        data: jsonEncode({'group_id': groupId, 'user_id': userId, 'is_admin': isAdmin}),
      );
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to promote admin: ${e.message}');
    }
  }

  static Future<BasicResponse> updateGroup({
    required int groupId,
    String? groupName,
    String? groupDescription,
    String? groupColour,
  }) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/group/update",
        data: jsonEncode({
          'group_id': groupId,
          'group_name': groupName,
          'group_description': groupDescription,
          'group_colour': groupColour,
        }),
      );
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update group: ${e.message}');
    }
  }

  static Future<BasicResponse> muteGroup({
    required int groupId,
    required bool mute,
    int? muteDurationHours,
  }) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/group/mute",
        data: jsonEncode({
          'group_id': groupId,
          'mute': mute,
          'mute_duration_hours': muteDurationHours,
        }),
      );
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to mute group: ${e.message}');
    }
  }

  static Future<Uint8List> getGroupAvatar(int groupId, {bool? getDefault}) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/group/avatar",
        data: jsonEncode({'group_id': groupId, 'get_default': getDefault}),
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to fetch group avatar: ${e.message}');
    }
  }

  static Future<int> getGroupAvatarVersion(int groupId) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/group/avatar/version",
        data: jsonEncode({'group_id': groupId}),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as int;
      }
      throw Exception('Failed to fetch group avatar version: Invalid response');
    } on DioException catch (e) {
      throw Exception('Failed to fetch group avatar version: ${e.message}');
    }
  }

  static Future<BasicResponse> changeGroupAvatar({
    required int groupId,
    Uint8List? newAvatar,
    bool useDefaultAvatar = false,
  }) async {
    try {
      final formData = FormData();
      if (!useDefaultAvatar && newAvatar != null) {
        formData.files.add(
          MapEntry(
            'avatar',
            MultipartFile.fromBytes(newAvatar, filename: 'avatar.png'),
          ),
        );
      }
      formData.fields.add(MapEntry('group_id', groupId.toString()));

      final response = await _dio.patch(
        "${dotenv.env['API_VERSION']}/group/avatar",
        data: formData,
      );
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to change group avatar: ${e.message}');
    }
  }
}
