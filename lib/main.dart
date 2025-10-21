import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/di.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
              builder: EasyLoading.init(),
              onGenerateRoute: RouteGenerator.getRoute,
              initialRoute: Routes.homeRoute,
              theme: AppTheme.lightTheme);
        });
  }
}
