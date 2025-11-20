import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/di.dart';
import 'core/preferences/app_pref.dart';
import 'core/router/app_router.dart';
import 'core/utils/constant/app_constants.dart';
import 'core/utils/constant/app_strings.dart';
import 'core/utils/constant/language_manager.dart';
import 'core/utils/style/app_colors.dart';
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
  await EasyLocalization.ensureInitialized();

  final isLoggedIn = await checkUserLoginStatus();

  runApp(EasyLocalization(
      supportedLocales: [ARABIC_LOCAL, ENGLISH_LOCAL],
      path: ASSET_PATH_LOCALISATIONS,
      child: Phoenix(child: MyApp(isLoggedIn: isLoggedIn))));
}

Future<bool> checkUserLoginStatus() async {
  final AppPreferences appPreferences = sl<AppPreferences>();
  return appPreferences.isUserLoggedIn();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppPreferences _appPreferences = sl<AppPreferences>();

  @override
  void didChangeDependencies() {
    _appPreferences.getLocal().then((local) => {context.setLocale(local)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              debugShowCheckedModeBanner: false,
              title: AppStrings.Ma2mouria.tr(),
              builder: (context, widget) => EasyLoading.init()(context, widget),
              onGenerateRoute: RouteGenerator.getRoute,
              initialRoute: widget.isLoggedIn ? Routes.homeRoute : Routes.loginRoute,
              theme: AppTheme.lightTheme);
        });
  }
}

