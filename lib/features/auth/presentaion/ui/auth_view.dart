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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                FadeInLeft(
                  duration: Duration(milliseconds: AppConstants.animation),
                  child: Text(
                    AppStrings.letsStart,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 30.sp,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                FadeInRight(
                  duration: Duration(milliseconds: AppConstants.animation),
                  child: Text(
                    AppStrings.appName,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 40.sp,
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
                                        horizontal: 20.w,
                                        vertical: 10.h,
                                      ),
                                      width: MediaQuery.sizeOf(context).width / 0.5,
                                      height: 45.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20.r),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1.5.w,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppStrings.signIn,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 15.sp,
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
    );
  }
}
