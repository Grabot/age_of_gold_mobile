import 'dart:io';

import 'package:age_of_gold_mobile/views/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:flutter/services.dart';
import '../../models/auth/me.dart';
import '../../utils/socket_services.dart';
import '../components/shared_app_bar.dart';
import '../friends/friends_page.dart';

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
  }

  void backButtonFunctionality() {
    exitApp();
  }

  exitApp() {
    Me me = authStore.me;
    SocketServices().leaveRoomSolo(me.id);
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          backButtonFunctionality();
        }
      },
      child: Scaffold(
        appBar: SharedAppBar(
          title: 'Age of Gold',
          profilePage: const ProfilePage(),
          friendsPage: const FriendsPage(),
          showHomeOption: false,
          showProfileOption: true,
          showFriendsOption: true,
          showBackButton: false,
          backButtonFunctionality: backButtonFunctionality,
        ),
        body: Stack(
          children: [
            const Center(child: Text('TODO', style: TextStyle(fontSize: 24))),
            Positioned(
              top: 30,
              left: 30,
              child: FloatingActionButton(
                heroTag: 'friendsButton',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FriendsPage()),
                  );
                },
                mini: true,
                child: const Text('👥', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
