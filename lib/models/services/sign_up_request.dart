
class SignUpRequest {
  late String email;
  late String username;
  late String password;

  SignUpRequest({required this.email, required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
    };
  }
}
