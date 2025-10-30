import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/style/app_colors.dart';
import '../../../../../core/utils/ui_components/custom_divider.dart';
import '../../../data/model/receipt_members_model.dart';

class ReceiptMembersBottomSheet extends StatefulWidget {
  List<ReceiptMembersModel> receiptMembersList;
  Map<String, String?>? userData;
  ReceiptMembersBottomSheet({
    super.key,
    required this.receiptMembersList,
    required this.userData,
  });

  @override
  State<ReceiptMembersBottomSheet> createState() => _ReceiptMembersBottomSheetState();
}

class _ReceiptMembersBottomSheetState extends State<ReceiptMembersBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height / 2,
      padding: EdgeInsets.all(20.h),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: AppColors.cWhite,
        border: Border.all(color: AppColors.cPrimary, width: 1.5.w),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomDivider(),

          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 2,
              radius: Radius.circular(10),
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10.h),
                itemCount: widget.receiptMembersList.length,
                itemBuilder: (context, index) {
                  final item = widget.receiptMembersList[index];
                  return Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 6.h,
                      horizontal: 5.w,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.2),
                        width: 2.w,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Row(
                          children: [
                            item.name == widget.userData!['name']
                                ? Row(
                                    children: [
                                      Bounceable(
                                        onTap: () {},
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.orangeAccent,
                                          size: 18.sp,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Bounceable(
                                        onTap: () {},
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                          size: 18.sp,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            SizedBox(width: 10.w),
                            Text(
                              "${item.shareValue.toStringAsFixed(2)} L.E.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
