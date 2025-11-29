import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ma2mouria/core/utils/constant/app_strings.dart';
import 'package:ma2mouria/core/utils/style/app_colors.dart';
import 'package:web/web.dart' as web;

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

void confirmDelete(BuildContext context, Function logic) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppStrings.waning.tr(),style: TextStyle(
          color: AppColors.cPrimary,
          fontSize: isMobile() ? 20.sp : 6.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        )),
        content: Text(AppStrings.areYouSure.tr(),style: TextStyle(
          color: AppColors.cSecondary,
          fontSize: isMobile() ? 18.sp : 5.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        )),
        actions: [
          TextButton(
            child: Text(AppStrings.no.tr()),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(AppStrings.yes.tr(),style: TextStyle(
              color: AppColors.cPrimary,
              fontSize: isMobile() ? 20.sp : 6.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            )),
            onPressed: () {
              Navigator.of(context).pop();
              logic();
            },
          ),
        ],
      );
    },
  );
}