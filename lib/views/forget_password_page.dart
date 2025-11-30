import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'components/custom_form_button.dart';
import 'components/custom_input_field.dart';
import 'components/page_header.dart';
import 'components/page_heading.dart';
import 'sign_in_page.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
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
                        hintText: 'Your email id',
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
                                        builder:
                                            (context) => const SignInPage(),
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

  void _handleForgetPassword() {
    if (_forgetPasswordFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Submitting data..')));
    }
  }
}
