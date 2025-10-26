import 'package:flutter/material.dart';
import 'package:ma2mouria/features/auth/presentaion/ui/auth_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home_page/presentaion/bloc/home_page_cubit.dart';
import '../../features/home_page/presentaion/ui/home_page.dart';
import '../di/di.dart';

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
            builder: (_) => BlocProvider(
                create: (context) => sl<HomePageCubit>(),
                child: const HomeView()));
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
