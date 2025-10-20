import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ma2mouria/core/utils/constant/app_strings.dart';
import 'package:ma2mouria/features/auth/presentaion/bloc/auth_cubit.dart';
import 'dart:ui';
import '../../../../core/di/di.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 72),

                FadeInLeft(
                  duration: Duration(milliseconds: AppConstants.animation),
                  child: Text(
                    AppStrings.letsStart,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 46,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                FadeInRight(
                  duration: Duration(milliseconds: AppConstants.animation),
                  child: Text(
                    AppStrings.appName,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 46,
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
                            Navigator.pushReplacementNamed(context, Routes.homeRoute);
                          } else if (state is LoginErrorState) {
                            showSnackBar(context, state.errorMessage);
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
                                  borderRadius: BorderRadius.circular(30),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.all(10),
                                      width: MediaQuery.sizeOf(context).width / 0.5,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Sign in",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 22,
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
