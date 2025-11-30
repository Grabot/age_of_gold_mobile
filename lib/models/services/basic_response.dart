
class BasicResponse {
  bool? success;

  BasicResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("success") && json["success"]) {
      success = json["success"];
    }
  }
}
