import 'dart:html' as html;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:web/web.dart' as web;

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ma2mouria/core/utils/constant/app_strings.dart';
import 'package:ma2mouria/features/auth/presentaion/bloc/auth_cubit.dart';
import 'dart:ui';
import '../../../../core/di/di.dart';
import '../../../../core/preferences/app_pref.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/constant/app_constants.dart';
import '../../../../core/utils/ui_components/loading_dialog.dart';
import '../../../../core/utils/ui_components/snackbar.dart';
import '../bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final AppPreferences _appPreferences = sl<AppPreferences>();

  _changeLanguage() {
    _appPreferences.changeAppLanguage();
    Phoenix.rebirth(context);
  }

  bool isMobile() {
    if (kIsWeb) {
      final ua = web.window.navigator.userAgent.toLowerCase();
      return ua.contains("iphone") ||
          ua.contains("android") ||
          ua.contains("ipad") ||
          ua.contains("mobile");
    } else {
      return defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBlocker(
      child: WillPopScope(
        onWillPop: () async {
          if (html.window.history.length > 1) {
            html.window.history.back();
          } else {
            html.window.location.href = "https://google.com";
          }
          return false;
        },
        child: Scaffold(
          extendBody: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C1633), Color(0xFF2E2159), Color(0xFF443182)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 72.h),
        
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeInLeft(
                          duration: Duration(milliseconds: AppConstants.animation),
                          child: Text(
                            AppStrings.letsStart.tr(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: isMobile() ? 30.sp : 10.sp,
                            ),
                          ),
                        ),
                        Bounceable(
                          onTap: () {
                            setState(() {
                              _changeLanguage();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Icon(
                              Icons.language,
                              color: Colors.white,
                              size: isMobile() ? 15.sp : 5.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
        
                    SizedBox(height: 20.h),
        
                    FadeInRight(
                      duration: Duration(milliseconds: AppConstants.animation),
                      child: Text(
                        AppStrings.Ma2mouria.tr(),
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: isMobile() ? 40.sp : 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
        
                    const Spacer(flex: 3),
        
                    FadeInUp(
                      duration: Duration(milliseconds: AppConstants.animation),
                      child: Center(
                        child: BlocProvider(
                          create: (context) => sl<AuthCubit>(),
                          child: BlocConsumer<AuthCubit, AuthState>(
                            listener: (context, state) async {
                              if (state is LoginLoadingState) {
                                showLoading();
                              } else if (state is LoginSuccessState) {
                                hideLoading();
                                await _appPreferences.setUserLoggedIn();
                                await _appPreferences.saveUserData(
                                  email: state.user.email,
                                  name: state.user.name,
                                  photoUrl: state.user.photoUrl
                                );
                                Navigator.pushReplacementNamed(context, Routes.homeRoute);
                              } else if (state is LoginErrorState) {
                                showAppSnackBar(context, state.errorMessage, type: SnackBarType.error);
                                hideLoading();
                              }
                            },
                            builder: (context, state) {
                              return Bounceable(
                                onTap: () {
                                  AuthCubit.get(context).login();
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20.r),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10.h, sigmaY: 10.w),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 10.w),
                                          padding:  EdgeInsets.symmetric(
                                            horizontal: isMobile() ? 20.w : 10.w,
                                            vertical: isMobile() ? 10.h : 0.h,
                                          ),
                                          width: isMobile() ? MediaQuery.sizeOf(context).width / 0.5 : 80.w ,
                                          height: isMobile() ? 45.h : 60.h,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20.r),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.2),
                                              width: isMobile() ? 1.5.w : 0.5.w,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              AppStrings.signIn.tr(),
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: isMobile() ? 15.sp : 8.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
        
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrientationBlocker extends StatelessWidget {
  final Widget child;

  const OrientationBlocker({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    bool isMobile() {
      if (kIsWeb) {
        final ua = web.window.navigator.userAgent.toLowerCase();
        return ua.contains("iphone") ||
            ua.contains("android") ||
            ua.contains("ipad") ||
            ua.contains("mobile");
      } else {
        return defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLandscape = constraints.maxWidth > constraints.maxHeight;

        if (isLandscape && isMobile()) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body:
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1C1633),
                      Color(0xFF2E2159),
                      Color(0xFF443182),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Text(
                      AppStrings.pleaseRotate.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24.sp,color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return child;   // show your normal app
      },
    );
  }
}
