class LoginResponse {
  String? accessToken;
  String? refreshToken;
  int? profileVersion;
  int? avatarVersion;

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
      }
    }
  }
}
