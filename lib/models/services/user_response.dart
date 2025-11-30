
class UserResponse {
  int? id;
  String? username;

  UserResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("success") && json["success"]) {
      if (json.containsKey("data")) {
        Map<String, dynamic> data = json["data"];
        if (data.containsKey("user")) {
          Map<String, dynamic> user = data["user"];
          if (user.containsKey("id")) {
            id = user["id"];
          }
          if (user.containsKey("username")) {
            username = user["username"];
          }
        }
      }
    }
  }
}
