import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/login/presentaion/ui/login.dart';
import '../di/di.dart';
import 'arguments.dart';

class Routes {
  static const String loginRoute = "/login";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginRoute:
        return MaterialPageRoute(
            builder: (_) => const LoginView());
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
