import 'dart:io';

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../auth/app_interceptors.dart';
import '../../auth/auth_login.dart';
import '../../models/services/login_response.dart';
import '../../models/services/sign_in_request.dart';
import '../../models/services/sign_up_request.dart';
import '../../utils/auth_store.dart';
import '../../utils/utils.dart';
import '../components/custom_form_button.dart';
import '../components/custom_input_field.dart';
import '../components/oauth_buttons.dart';
import '../components/page_header.dart';
import '../components/page_heading.dart';
import '../age_of_gold_home/age_of_gold_home.dart';
import 'dialog/oauth_webview_dialog.dart';
import 'package:age_of_gold_mobile/views/login/service/google_sign_in_service.dart';

class AuthPage extends StatefulWidget {

  final bool showSignUp;

  const AuthPage(
      {
        super.key,
        this.showSignUp = false,
      }
    );

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLogin = true;

  final TextEditingController _emailOrUsernameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isLogin = !widget.showSignUp;
  }

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xffEEF1F3),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                reverse: true,
                controller: _scrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            const PageHeader(),
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 10),
                                        PageHeading(title: _isLogin ? 'Sign in' : 'Sign up'),
                                        const SizedBox(height: 16),
                                        if (!_isLogin) ...[
                                          CustomInputField(
                                            labelText: 'Username',
                                            hintText: 'Your username',
                                            isDense: true,
                                            controller: _usernameController,
                                            validator: (textValue) {
                                              if (textValue == null || textValue.trim().isEmpty) {
                                                return 'Username is required!';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          CustomInputField(
                                            labelText: 'Email',
                                            hintText: 'Your email',
                                            isDense: true,
                                            controller: _emailController,
                                            validator: (textValue) {
                                              if (textValue == null || textValue.trim().isEmpty) {
                                                return 'Email is required!';
                                              }
                                              if (!EmailValidator.validate(textValue.trim())) {
                                                return 'Please enter a valid email';
                                              }
                                              return null;
                                            },
                                          ),
                                        ] else ...[
                                          CustomInputField(
                                            labelText: 'Email or Username',
                                            hintText: 'Your email or username',
                                            validator: (textValue) {
                                              if (textValue == null || textValue.trim().isEmpty) {
                                                return 'This field is required!';
                                              }
                                              return null;
                                            },
                                            controller: _emailOrUsernameController,
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                        CustomInputField(
                                          labelText: 'Password',
                                          hintText: 'Your password',
                                          isDense: true,
                                          obscureText: true,
                                          controller: _passwordController,
                                          validator: (textValue) {
                                            if (textValue == null || textValue.trim().isEmpty) {
                                              return 'Password is required!';
                                            }
                                            return null;
                                          },
                                          suffixIcon: true,
                                        ),
                                        if (_isLogin) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            alignment: Alignment.centerRight,
                                            child: GestureDetector(
                                              onTap: () {
                                                // Navigate to forget password page
                                              },
                                              child: const Text(
                                                'Forget password?',
                                                style: TextStyle(
                                                  color: Color(0xff939393),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                        CustomFormButton(
                                          innerText: _isLogin ? 'Sign in' : 'Sign up',
                                          onPressed: _isLogin ? _handleLoginUser : _handleSignupUser,
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            const Expanded(child: Divider()),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Text(
                                                _isLogin ? 'or sign in with' : 'or sign up with',
                                                style: const TextStyle(
                                                  color: Color(0xff939393),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            const Expanded(child: Divider()),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        OAuthButtons.buildOAuthButtonsRow(
                                          context,
                                          buttons: [
                                            {
                                              'logoPath': 'assets/images/oauth2/google_logo.png',
                                              'label': 'Google',
                                              'provider': 'google',
                                            },
                                            {
                                              'logoPath': 'assets/images/oauth2/apple_logo.png',
                                              'label': 'Apple',
                                              'provider': 'apple',
                                            },
                                            {
                                              'logoPath': 'assets/images/oauth2/reddit_logo.png',
                                              'label': 'Reddit',
                                              'provider': 'reddit',
                                            },
                                            {
                                              'logoPath': 'assets/images/oauth2/github_logo.png',
                                              'label': 'GitHub',
                                              'provider': 'github',
                                            },
                                          ],
                                          onPressed: (provider) => _handleOAuthSignIn(provider)
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _isLogin ? "Don't have an account? " : 'Already have an account? ',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xff939393),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isLogin = !_isLogin;
                                                  _formKey.currentState?.reset();
                                                });
                                              },
                                              child: Text(
                                                _isLogin ? 'Sign up' : 'Sign in',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xff748288),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_isLoading) const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignupUser() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    final String email = _emailController.text.trim();
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    try {
      LoginResponse loginResponse = await AuthLogin().signUp(
        SignUpRequest(email: email, username: username, password: password),
      );
      await AuthStore().successfulLogin(loginResponse, 0);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign up successful!')));
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AgeOfGoldHome()),
      );
    } catch (e) {
      if (!mounted) return;
      String errorMessage = "Sign up failed. Please try again.";
      if (e is AppException) {
        if (e.message != null) {
          errorMessage = e.message!;
        }
      }
      showToastMessage(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLoginUser() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    final String emailOrUsername = _emailOrUsernameController.text.trim();
    final String password = _passwordController.text.trim();
    try {
      LoginResponse? loginResponse = await AuthLogin().signIn(
        SignInRequest(emailOrUsername: emailOrUsername, password: password),
      );
      await AuthStore().successfulLogin(loginResponse, 0);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in successful!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AgeOfGoldHome()),
      );
    } catch (e) {
      if (!mounted) return;
      String errorMessage = "Sign in failed. Please try again.";
      if (e is AppException) {
        if (e.message != null) {
          errorMessage = e.message!;
        }
      }
      showToastMessage(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleOAuthSignIn(String provider) async {
    if (_isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (provider == "reddit") {
        await _showOAuthWebviewDialog(Uri.parse("https://ageof.gold/api/v1.0/auth/reddit"));
        return;
      } else if (provider == "github") {
        await _showOAuthWebviewDialog(Uri.parse("https://ageof.gold/api/v1.0/auth/github"));
        return;
      } else if (provider == "google") {
        await _handleGoogleSignIn();
        return;
      } else if (provider == "apple") {
        if (Platform.isIOS) {
          await _handleAppleSignIn();
        } else {
          await _showOAuthWebviewDialog(Uri.parse("https://ageof.gold/api/v1.0/auth/apple"));
        }
        return;
      }
    } catch (exception) {
      print(exception.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showOAuthWebviewDialog(Uri uri) async {
    final oauthWebviewResult = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return OAuthWebviewDialog(uri: uri, fromRegister: false);
      },
    );
    if (oauthWebviewResult == true) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in successful!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AgeOfGoldHome()),
      );
    }
    return oauthWebviewResult ?? false;
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final googleSignInService = GoogleSignInService();
      final accessToken = await googleSignInService.signInWithGoogle();
      LoginResponse loginResponse = await AuthLogin().loginGoogleToken(accessToken);
      await AuthStore().successfulLogin(loginResponse, 1);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in successful!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AgeOfGoldHome()),
      );
    } catch (exception) {
      print(exception.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google login failed.')));
    }
  }

  Future<void> _handleAppleSignIn() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    print(credential);
  }
}
