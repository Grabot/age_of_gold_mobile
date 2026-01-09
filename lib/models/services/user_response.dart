import '../auth/user.dart';
import 'basic_response.dart';

class UserResponse extends BasicResponse{
  int? id;
  String? username;
  int? profileVersion;
  int? avatarVersion;
  User? user;

  UserResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json.containsKey("success") && json["success"]) {
      if (json.containsKey("data")) {
        Map<String, dynamic> data = json["data"];
        if (data.containsKey("id")) {
          id = data["id"];
        }
        if (data.containsKey("username")) {
          username = data["username"];
        }
        if (data.containsKey("profile_version")) {
          profileVersion = data["profile_version"];
        }
        if (data.containsKey("avatar_version")) {
          avatarVersion = data["avatar_version"];
        }
      }
    }
  }
}
