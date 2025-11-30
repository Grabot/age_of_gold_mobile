import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../models/services/login_response.dart';
import '../models/services/sign_up_request.dart';
import '../services/auth/app_interceptors.dart';
import '../services/auth/auth_login.dart';
import '../utils/auth_store.dart';
import '../utils/utils.dart';
import 'components/custom_form_button.dart';
import 'components/custom_input_field.dart';
import 'components/oauth_buttons.dart';
import 'components/page_header.dart';
import 'components/page_heading.dart';
import 'sign_in_page.dart';
import 'age_of_gold_home/age_of_gold_home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _signupFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
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
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
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
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  child: Form(
                                    key: _signupFormKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 10),
                                        const PageHeading(title: 'Sign up'),
                                        const SizedBox(height: 16),
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
                                        const SizedBox(height: 22),
                                        CustomFormButton(
                                          innerText: 'Sign up',
                                          onPressed: _handleSignupUser,
                                        ),
                                        const SizedBox(height: 16),
                                        // "Or sign up with" divider
                                        const Row(
                                          children: [
                                            Expanded(child: Divider()),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: Text(
                                                'or sign up with',
                                                style: TextStyle(
                                                  color: Color(0xff939393),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Expanded(child: Divider()),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        OAuthButtons.buildOAuthButtonsRow(
                                          context,
                                          buttons: [
                                            {'logoPath': 'assets/images/oauth2/google_logo.png', 'label': 'Google', 'provider': 'google'},
                                            {'logoPath': 'assets/images/oauth2/apple_logo.png', 'label': 'Apple', 'provider': 'apple'},
                                            {'logoPath': 'assets/images/oauth2/reddit_logo.png', 'label': 'Reddit', 'provider': 'reddit'},
                                            {'logoPath': 'assets/images/oauth2/github_logo.png', 'label': 'GitHub', 'provider': 'github'},
                                          ],
                                          onPressed: (provider) => _handleOAuthSignUp(provider),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Already have an account? ',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xff939393),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => const SignInPage()),
                                              ),
                                              child: const Text(
                                                'Sign in',
                                                style: TextStyle(
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
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
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
    if (!_signupFormKey.currentState!.validate() || _isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    // Scroll to top to show loading indicator better
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
          SignUpRequest(
            email: email,
            username: username,
            password: password,
          )
      );
      await AuthStore().successfulLogin(loginResponse);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up successful!')),
      );
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

  Future<void> _handleOAuthSignUp(String provider) async {
    if (_isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();
    try {
      // TODO: Implement OAuth registration logic for each provider
      showToastMessage('Signing up with $provider...');
    } catch (e) {
      if (!mounted) return;
      showToastMessage('Failed to sign up with $provider: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
