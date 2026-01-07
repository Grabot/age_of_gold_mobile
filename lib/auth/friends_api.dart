import 'dart:convert';
import 'package:age_of_gold_mobile/auth/auth_api.dart';
import 'package:age_of_gold_mobile/models/friend.dart';
import 'package:age_of_gold_mobile/models/services/basic_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FriendsApi {
  static final Dio _dio = AuthApi.createDio();

  static Future<BasicResponse> searchFriend(String username) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/friend/search",
        data: jsonEncode({'username': username}),
      );
      print("reseponse");
      print(response.data);
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to search friend: ${e.message}');
    }
  }

  static Future<BasicResponse> addFriend(int friendId) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/friend/add",
        data: jsonEncode({'user_id': friendId}),
      );
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to add friend: ${e.message}');
    }
  }

  static Future<BasicResponse> acceptFriendRequest(int friendId) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/friend/respond",
        data: jsonEncode({'friend_id': friendId, 'accept': true}),
      );
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to accept friend request: ${e.message}');
    }
  }

  static Future<BasicResponse> rejectFriendRequest(int friendId) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/friend/respond",
        data: jsonEncode({'friend_id': friendId, 'accept': false}),
      );
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to reject friend request: ${e.message}');
    }
  }

  static Future<BasicResponse> cancelFriendRequest(int friendId) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/friend/cancel",
        data: jsonEncode({'friend_id': friendId}),
      );
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to cancel friend request: ${e.message}');
    }
  }

  static Future<BasicResponse> removeFriend(int friendId) async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/friend/remove",
        data: jsonEncode({'friend_id': friendId}),
      );
      return BasicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to remove friend: ${e.message}');
    }
  }

  static Future<List<Friend>> fetchAllFriends() async {
    try {
      final response = await _dio.post(
        "${dotenv.env['API_VERSION']}/friend/all",
        data: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final friendsData = data['data'] as List;
          return friendsData
              .map((friendData) => Friend.fromJson(friendData))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch friends: ${e.message}');
    }
  }
}
