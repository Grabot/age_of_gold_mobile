import 'package:age_of_gold_mobile/auth/auth_login.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '../../components/custom_form_button.dart';
import '../../components/custom_input_field.dart';
import '../../components/page_header.dart';
import '../../components/page_heading.dart';
import '../auth_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _forgetPasswordFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const PageHeader(),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Form(
                  key: _forgetPasswordFormKey,
                  child: Column(
                    children: [
                      const PageHeading(title: 'Forgot password'),
                      CustomInputField(
                        labelText: 'Email',
                        hintText: 'Your email',
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Email is required!';
                          }
                          if (!EmailValidator.validate(textValue)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        controller: emailController,
                      ),
                      const SizedBox(height: 18),
                      CustomFormButton(
                        innerText: 'Submit',
                        onPressed: _handleForgetPassword,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: size.width * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap:
                                  () => {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AuthPage(),
                                      ),
                                    ),
                                  },
                              child: const Text(
                                'Back to login',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xff748288),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleForgetPassword() async {
    if (_forgetPasswordFormKey.currentState!.validate()) {
      try {
        final email = emailController.text;
        await AuthLogin().forgotPassword(email);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset send! Please check your email'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Something went wrong, forgot password email not sent. Please try again',
            ),
          ),
        );
      }
    }
  }
}
