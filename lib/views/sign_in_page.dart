import 'package:flutter/material.dart';
import '../models/services/login_response.dart';
import '../models/services/sign_in_request.dart';
import '../services/auth/app_interceptors.dart';
import '../services/auth/auth_login.dart';
import '../utils/auth_store.dart';
import '../utils/utils.dart';
import 'age_of_gold_home/age_of_gold_home.dart';
import '../views/forget_password_page.dart';
import '../views/sign_up_page.dart';
import 'components/custom_form_button.dart';
import 'components/custom_input_field.dart';
import 'components/oauth_buttons.dart';
import 'components/page_header.dart';
import 'components/page_heading.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _loginFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _emailOrUsernameController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
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
                                    key: _loginFormKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 10),
                                        const PageHeading(title: 'Sign in'),
                                        const SizedBox(height: 16),
                                        CustomInputField(
                                          labelText: 'Email or Username',
                                          hintText: 'Your email or username',
                                          validator: (textValue) {
                                            if (textValue == null ||
                                                textValue.trim().isEmpty) {
                                              return 'This field is required!';
                                            }
                                            return null;
                                          },
                                          controller:
                                              _emailOrUsernameController,
                                        ),
                                        const SizedBox(height: 16),
                                        CustomInputField(
                                          labelText: 'Password',
                                          hintText: 'Your password',
                                          obscureText: true,
                                          suffixIcon: true,
                                          validator: (textValue) {
                                            if (textValue == null ||
                                                textValue.trim().isEmpty) {
                                              return 'Password is required!';
                                            }
                                            return null;
                                          },
                                          controller: _passwordController,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap:
                                                () => Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const ForgetPasswordPage(),
                                                  ),
                                                ),
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
                                        const SizedBox(height: 16),
                                        CustomFormButton(
                                          innerText: 'Sign in',
                                          onPressed: _handleLoginUser,
                                        ),
                                        const SizedBox(height: 16),
                                        const Row(
                                          children: [
                                            Expanded(child: Divider()),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              child: Text(
                                                'or sign in with',
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
                                        // OAuth buttons
                                        OAuthButtons.buildOAuthButtonsRow(
                                          context,
                                          buttons: [
                                            {
                                              'logoPath':
                                                  'assets/images/oauth2/google_logo.png',
                                              'label': 'Google',
                                              'provider': 'google',
                                            },
                                            {
                                              'logoPath':
                                                  'assets/images/oauth2/apple_logo.png',
                                              'label': 'Apple',
                                              'provider': 'apple',
                                            },
                                            {
                                              'logoPath':
                                                  'assets/images/oauth2/reddit_logo.png',
                                              'label': 'Reddit',
                                              'provider': 'reddit',
                                            },
                                            {
                                              'logoPath':
                                                  'assets/images/oauth2/github_logo.png',
                                              'label': 'GitHub',
                                              'provider': 'github',
                                            },
                                          ],
                                          onPressed:
                                              (provider) =>
                                                  _handleOAuthSignIn(provider),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Don\'t have an account? ',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xff939393),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap:
                                                  () => Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              const SignUpPage(),
                                                    ),
                                                  ),
                                              child: const Text(
                                                'Sign-up',
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
                          const Center(child: CircularProgressIndicator()),
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

  Future<void> _handleLoginUser() async {
    if (!_loginFormKey.currentState!.validate() || _isLoading) {
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

    final String emailOrUsername = _emailOrUsernameController.text.trim();
    final String password = _passwordController.text.trim();
    try {
      LoginResponse? loginResponse = await AuthLogin().signIn(
        SignInRequest(emailOrUsername: emailOrUsername, password: password),
      );
      await AuthStore().successfulLogin(loginResponse);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in successful!')));
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
    FocusScope.of(context).unfocus();
    try {
      // TODO: Implement OAuth login logic for each provider
      showToastMessage('Signing in in with $provider...');
    } catch (e) {
      if (!mounted) return;
      showToastMessage('Failed to sign in with $provider: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
