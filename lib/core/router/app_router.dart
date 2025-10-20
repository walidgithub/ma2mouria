import 'package:flutter/material.dart';
import 'package:ma2mouria/features/auth/presentaion/ui/auth_view.dart';

import '../../features/home_page/presentaion/ui/home_page.dart';

class Routes {
  static const String loginRoute = "/login";
  static const String homeRoute = "/home";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginRoute:
        return MaterialPageRoute(
            builder: (_) => const AuthView());
      case Routes.homeRoute:
        return MaterialPageRoute(
            builder: (_) => const HomeView());
      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Container()),
    );
  }
}
