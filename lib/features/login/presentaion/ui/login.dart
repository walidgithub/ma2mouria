import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'dart:ui';
import '../../../../core/utils/constant/app_assets.dart';
import '../../../../core/utils/constant/app_constants.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              AppAssets.welcome,
              fit: BoxFit.cover,
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.25),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 72),

                  FadeInDown(
                    duration: Duration(milliseconds: AppConstants.animation),
                    child: Center(
                      child: const Text(
                        'Let\'s start',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 46,
                          height: 1.02,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  FadeInUp(
                    duration: Duration(milliseconds: AppConstants.animation),
                    child: Center(
                      child: Bounceable(
                        onTap: (){

                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                                child: Container(
                                  width: size.width * 0.82,
                                  height: 56,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text("Sign in", style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.w600),),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
