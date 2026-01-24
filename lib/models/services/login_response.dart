import '../friend.dart';
import '../group.dart';

class LoginResponse {
  String? accessToken;
  String? refreshToken;
  int? profileVersion;
  int? avatarVersion;
  List<Friend>? friends;
  List<Group>? groups;

  LoginResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("success") && json["success"]) {
      if (json.containsKey("data")) {
        Map<String, dynamic> data = json["data"];
        if (data.containsKey("access_token")) {
          accessToken = data["access_token"];
        }
        if (data.containsKey("refresh_token")) {
          refreshToken = data["refresh_token"];
        }
        if (data.containsKey("profile_version")) {
          profileVersion = data["profile_version"];
        }
        if (data.containsKey("avatar_version")) {
          avatarVersion = data["avatar_version"];
        }
        if (data.containsKey("friends")) {
          friends = List<Friend>.from(data["friends"].map((x) => Friend.fromJson(x)));
        }
        if (data.containsKey("groups")) {
          groups = List<Group>.from(data["groups"].map((x) => Group.fromJson(x)));
        }
        // TODO: How to do groups? They only give group_versions. How to handle this?
      }
    }
  }
}
