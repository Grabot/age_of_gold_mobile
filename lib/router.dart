import 'package:age_of_gold_mobile/views/age_of_gold_home/age_of_gold_home.dart';
import 'package:age_of_gold_mobile/views/sign_in_page.dart';
import 'package:age_of_gold_mobile/views/opening_screen.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/constants/route_paths.dart' as routes;

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case routes.signInRoute:
      return MaterialPageRoute(
        builder: (context) => SignInPage(key: UniqueKey()),
      );
    case routes.ageOfGoldHomeRoute:
      return MaterialPageRoute(
        builder: (context) => AgeOfGoldHome(key: UniqueKey()),
      );
    default:
      return MaterialPageRoute(builder: (context) => OpeningScreen());
  }
}
