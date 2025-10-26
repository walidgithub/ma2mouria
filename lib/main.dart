import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/di.dart';
import 'core/preferences/app_pref.dart';
import 'core/router/app_router.dart';
import 'core/utils/constant/app_strings.dart';
import 'core/utils/style/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(apiKey: "AIzaSyBy1FirtopKgVYrJSdipmmXYzo3w6ZB6BM",
        authDomain: "ma2mouria.firebaseapp.com",
        projectId: "ma2mouria",
        storageBucket: "ma2mouria.firebasestorage.app",
        messagingSenderId: "834303301817",
        appId: "1:834303301817:web:26f1d8c408861375c0a368",
        measurementId: "G-GN63DYLJPW")
  );
  await ServiceLocator().init();
  await ScreenUtil.ensureScreenSize();

  final isLoggedIn = await checkUserLoginStatus();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> checkUserLoginStatus() async {
  final AppPreferences appPreferences = sl<AppPreferences>();
  return appPreferences.isUserLoggedIn();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: AppStrings.appName,
              builder: (context, widget) => EasyLoading.init()(context, widget),
              onGenerateRoute: RouteGenerator.getRoute,
              initialRoute: isLoggedIn ? Routes.homeRoute : Routes.loginRoute,
              theme: AppTheme.lightTheme);
        });
  }
}
