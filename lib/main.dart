import 'package:age_of_gold_mobile/utils/navigation_service.dart';
import 'package:age_of_gold_mobile/views/opening_screen.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:age_of_gold_mobile/router.dart' as router;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(OKToast(child: const AgeOfGold()));
}

class AgeOfGold extends StatelessWidget {
  const AgeOfGold({super.key});

  Future<void> initializeAgeOfGold() async {
    await dotenv.load(fileName: ".env");
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
            title: 'Age of Gold',
            navigatorKey: locator.get<NavigationService>().navigatorKey,
            onGenerateRoute: router.generateRoute,
            initialRoute: '/',
            home: OpeningScreen(),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
