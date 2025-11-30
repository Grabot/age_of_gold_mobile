class SignInRequest {
  late String emailOrUsername;
  late String password;

  SignInRequest({required this.emailOrUsername, required this.password});

  Map<String, dynamic> toJson() {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    final isEmail = emailRegex.hasMatch(emailOrUsername);

    return {
      if (isEmail) 'email': emailOrUsername,
      if (!isEmail) 'username': emailOrUsername,
      'password': password,
    };
  }
}
