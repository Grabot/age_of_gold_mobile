
class LoginResponse {
  late bool result;
  String? accessToken;
  String? refreshToken;

  LoginResponse(this.result, this.accessToken, this.refreshToken);

  bool getResult() {
    return result;
  }

  String? getAccessToken() {
    return accessToken;
  }

  String? getRefreshToken() {
    return refreshToken;
  }

  LoginResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("result")) {
      result = json["result"];
      if (result) {
        accessToken = json["access_token"];
        refreshToken = json["refresh_token"];
      }
    }
  }
}