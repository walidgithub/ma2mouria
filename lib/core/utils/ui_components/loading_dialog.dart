import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constant/app_strings.dart';
import '../style/app_colors.dart';
import 'package:flutter/foundation.dart';
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

void showLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = AppColors.cSecondary
    ..indicatorColor = AppColors.cWhite
    ..textColor = AppColors.cWhite
    ..indicatorSize = isMobile() ? 50.0.w : 10.w
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..radius = isMobile() ? 10.0.w : 5.w
    ..dismissOnTap = false
    ..userInteractions = false;
  EasyLoading.show(
    maskType: EasyLoadingMaskType.black,
    status: AppStrings.loading.tr(),
  );
}

void hideLoading() {
  EasyLoading.dismiss();
}
