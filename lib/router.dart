import 'package:age_of_gold_mobile/views/login_page.dart';
import 'package:age_of_gold_mobile/views/opening_screen.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/constants/route_paths.dart' as routes;

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case routes.LoginRoute:
      return MaterialPageRoute(builder: (context) => LoginPage(key: UniqueKey()));
    // case routes.AgeOfGoldHomeRoute:
    //   return MaterialPageRoute(
    //       builder: (context) => AgeOfGoldHome(key: UniqueKey()));
    default:
      return MaterialPageRoute(builder: (context) => OpeningScreen());
  }
}