import 'package:age_of_gold_mobile/views/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import '../components/shared_app_bar.dart';

class AgeOfGoldHome extends StatefulWidget {
  const AgeOfGoldHome({super.key});

  @override
  State<AgeOfGoldHome> createState() => _AgeOfGoldHomeState();
}

class _AgeOfGoldHomeState extends State<AgeOfGoldHome> {
  late AuthStore authStore;

  @override
  void initState() {
    super.initState();
    authStore = AuthStore();
    authStore.loadUserData().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        title: 'Age of Gold',
        profilePage: const ProfilePage(),
        showHomeOption: false,
      ),
      body: const Center(child: Text('TODO', style: TextStyle(fontSize: 24))),
    );
  }
}
