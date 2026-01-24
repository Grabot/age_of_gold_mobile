import 'basic_response.dart';

class AvatarVersionResponse extends BasicResponse{
  int? avatarVersion;

  AvatarVersionResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json.containsKey("success") && json["success"]) {
      if (json.containsKey("data")) {
        avatarVersion = json["data"];
      }
    }
  }
}
