import 'package:age_of_gold_mobile/views/signup_page.dart';
import 'package:flutter/material.dart';
import 'components/custom_form_button.dart';
import 'components/page_header.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {

  // TODO: Meant as a opening screen with terms of service and privacy policy acceptance
  // For now, it just navigates to the signup page.
  @override
  Widget build(BuildContext context) {
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20),),
                  ),
                  child: CustomFormButton(
                    innerText: 'Continue',
                    onPressed: _handleOpeningScreen,
                  )
                ),
              ],
            )
        ),
      ),
    );
  }

  void _handleOpeningScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupPage(),
      ),
    );
  }
}
