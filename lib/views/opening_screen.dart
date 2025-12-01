import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../auth/app_interceptors.dart';
import '../auth/auth_login.dart';
import '../models/services/login_response.dart';
import '../utils/secure_storage.dart';
import '../utils/shared.dart';
import '../utils/utils.dart';
import 'age_of_gold_home/age_of_gold_home.dart';
import 'components/custom_form_button.dart';
import 'components/page_header.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login/auth_page.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  bool _isLoading = true;
  bool acceptEULA = false;
  bool startupCheck = true;

  @override
  void initState() {
    super.initState();
    _checkEULAStatus();
  }

  Future<void> _checkEULAStatus() async {
    final val = await HelperFunction.getEULA();
    if (val == null || val == false) {
      setState(() {
        startupCheck = false;
        _isLoading = false;
      });
    } else {
      // Eula already accepted
      startUp();
    }
  }

  Widget startupView() {
    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Image.asset('assets/images/gold_placeholder.png'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: Stack(
          children: [
            // Your main content
            startupCheck
                ? startupView()
                : SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    children: [
                      const PageHeader(),
                      SizedBox(height: 80),
                      SizedBox(
                        child: Text(
                          "Welcome to\nAge of Gold!",
                          style: TextStyle(
                            fontSize: 40,
                            color: Color(0xff939393),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Read our ",
                              style: TextStyle(
                                color: Color(0xff939393),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                launchUrl(
                                  Uri.parse(
                                    dotenv.env['AGE_OF_GOLD_PRIVACY_URL'] ?? "",
                                  ),
                                );
                              },
                              child: Text(
                                "privacy policy.",
                                style: TextStyle(
                                  color: Colors.lightBlue,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tap \"Agree and continue\" to ",
                              style: TextStyle(
                                color: Color(0xff939393),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "accept the ",
                              style: TextStyle(
                                color: Color(0xff939393),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                launchUrl(
                                  Uri.parse(
                                    dotenv.env['AGE_OF_GOLD_TERMS_URL'] ?? "",
                                  ),
                                );
                              },
                              child: Text(
                                "Terms and Service.",
                                style: TextStyle(
                                  color: Colors.lightBlue,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      CustomFormButton(
                        innerText: 'Agree and continue',
                        onPressed: agreeAndContinue,
                      ),
                      SizedBox(height: 40),
                      Text(
                        "from",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                      ),
                      SizedBox(height: 6),
                      zwaarDevelopersLogo(200, true),
                      Text(
                        "developers",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 20),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(
                  alpha: 0.5,
                ), // Semi-transparent overlay
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> agreeAndContinue() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      await HelperFunction.setEULA(true);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthPage(key: UniqueKey(), showSignUp: true)),
      );
    }
  }

  goToSignIn() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage(key: UniqueKey())),
    );
  }

  Future<void> startUp() async {
    // Automatically log in if an access token was available.
    String? accessToken = await SecureStorage().getAccessToken();
    if (accessToken == null) {
      // No token was available, so we go to the sign in page.
      goToSignIn();
      return;
    } else {
      try {
        LoginResponse loginResponse = await AuthLogin().loginToken();

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign in successful!')));

        await AuthStore().successfulLogin(loginResponse, null);

        if (!mounted) return;
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
        goToSignIn();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
