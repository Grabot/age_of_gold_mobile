import 'package:age_of_gold_mobile/views/opening_screen.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgeOfGold());
}

class AgeOfGold extends StatelessWidget {
  const AgeOfGold({super.key});

  Future<void> initializeAgeOfGold() async {
    // await Firebase.initializeApp();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeAgeOfGold(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            home: OpeningScreen(),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
