
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ma2mouria/core/utils/constant/app_strings.dart';
import 'package:ma2mouria/core/utils/style/app_colors.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';

class ReceiptImageDialog extends StatelessWidget {
  String imageUrl;
  ReceiptImageDialog({required this.imageUrl,super.key});

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
    return Stack(
      children: [
        Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 500,
              minWidth: 300,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.receiptImage.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, _) => const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, _, __) =>
                    const Icon(Icons.error, size: 40),
                  ),

                  const SizedBox(height: 20),

                  // You can remove this button if you want only the top floating button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: AppColors.cPrimary,
                      size: isMobile() ? 20.sp : 6.sp,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),

        /// -------- Floating Close Button ----------
        Positioned(
          right: 20,
          top: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}