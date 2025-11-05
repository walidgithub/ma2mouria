import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ma2mouria/core/utils/constant/app_strings.dart';
import 'package:ma2mouria/features/home_page/data/requests/edit_share_request.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/utils/style/app_colors.dart';
import '../../../../../core/utils/ui_components/custom_divider.dart';
import '../../../../../core/utils/ui_components/loading_dialog.dart';
import '../../../../../core/utils/ui_components/snackbar.dart';
import '../../../data/model/receipt_members_model.dart';
import '../../../data/requests/delete_share_request.dart';
import '../../bloc/home_page_cubit.dart';
import '../../bloc/home_page_state.dart';

class ReceiptMembersBottomSheet extends StatefulWidget {
  List<ReceiptMembersModel> receiptMembersList;
  Map<String, String?>? userData;
  String selectedId;
  String cycleName;
  String totalValue;
  Function clearMembersList;
  ReceiptMembersBottomSheet({
    super.key,
    required this.receiptMembersList,
    required this.userData,
    required this.selectedId,
    required this.cycleName,
    required this.totalValue,
    required this.clearMembersList,
  });

  @override
  State<ReceiptMembersBottomSheet> createState() =>
      _ReceiptMembersBottomSheetState();
}

class _ReceiptMembersBottomSheetState extends State<ReceiptMembersBottomSheet> {
  final TextEditingController _receiptShareTextController =
      TextEditingController();

  String? editingMemberId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomePageCubit>()..getReceipts(widget.cycleName),
      child: BlocConsumer<HomePageCubit, HomePageState>(
        listener: (context, state) async {
          if (state is GetReceiptsLoadingState) {
            showLoading();
          } else if (state is GetReceiptsErrorState) {
            hideLoading();
            showAppSnackBar(context, state.errorMessage, type: SnackBarType.error);
          } else if (state is GetReceiptsSuccessState) {
            hideLoading();
            widget.clearMembersList();
            setState(() {
              widget.receiptMembersList = state.receipts.firstWhere((receipt) {
                return receipt.shared == true && receipt.receiptId == widget.selectedId;
              }).receiptMembers;
            });
            // ------------------------------------------------------
          } else if (state is EditShareLoadingState) {
            showLoading();
          } else if (state is EditShareErrorState) {
            hideLoading();
            showAppSnackBar(context, state.errorMessage, type: SnackBarType.error);
          } else if (state is EditShareSuccessState) {
            hideLoading();
            HomePageCubit.get(context).getReceipts(widget.cycleName);
            // ------------------------------------------------------
          } else if (state is DeleteShareLoadingState) {
            showLoading();
          } else if (state is DeleteShareErrorState) {
            hideLoading();
            showAppSnackBar(context, state.errorMessage, type: SnackBarType.error);
          } else if (state is DeleteShareSuccessState) {
            hideLoading();
            HomePageCubit.get(context).getReceipts(widget.cycleName);
          }
        },
        builder: (context, state) {
          return Container(
            height: MediaQuery.sizeOf(context).height / 2,
            padding: EdgeInsets.all(10.h),
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
                            horizontal: 10.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cSecondary,
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.2),
                              width: 2.w,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  editingMemberId == item.id
                                      ? SizedBox(
                                    width: 150.w,
                                    height: 35.h,
                                    child: TextField(
                                      controller: _receiptShareTextController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,}$')),
                                      ],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                      ),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.1),
                                        hintText: AppStrings.myShare,
                                        hintStyle: TextStyle(color: Colors.white70),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.r),
                                          borderSide: BorderSide(
                                            color: Colors.white.withOpacity(0.2),
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.h,
                                          horizontal: 12.w,
                                        ),
                                      ),
                                    ),
                                  )
                                      : Text(
                                    "${item.shareValue.toStringAsFixed(2)} L.E.",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  item.name == widget.userData!['name']
                                      ? Row(
                                    children: [
                                      Bounceable(
                                        onTap: () {
                                          setState(() {
                                            if (editingMemberId == item.id) {
                                              editingMemberId = null;

                                              // -----------------
                                              final receiptShareText = _receiptShareTextController.text
                                                  .trim();

                                              if (receiptShareText.isEmpty) {
                                                showAppSnackBar(context, "Please fill in all required fields.", type: SnackBarType.error);
                                                return;
                                              }

                                              final receiptShare = double.tryParse(receiptShareText);

                                              if (receiptShare == null) {
                                                showAppSnackBar(context, "Please enter valid numbers for your share.", type: SnackBarType.error);
                                                return;
                                              }

                                                String totalValue = widget.receiptMembersList
                                                    .fold(0.0, (sum, m) => sum + m.shareValue)
                                                    .toStringAsFixed(2);
                                                if (double.parse(widget.totalValue) < ((double.parse(totalValue) - item.shareValue) + double.parse(_receiptShareTextController.text))) {
                                                  showAppSnackBar(context, "Your share value is not available.", type: SnackBarType.error);
                                                  return;
                                              }

                                              // ------------------------------

                                              EditShareRequest editShareRequest = EditShareRequest(
                                                receiptId: widget.selectedId,
                                                receiptMembersModel: ReceiptMembersModel(
                                                  shareValue: double.parse(_receiptShareTextController.text),
                                                  name: item.name,
                                                  id: item.id,
                                                ),
                                              );

                                              HomePageCubit.get(context).editShare(editShareRequest);
                                            } else {
                                              editingMemberId = item.id;
                                              _receiptShareTextController.text = item.shareValue.toString();
                                            }
                                          });
                                        },
                                        child: Icon(
                                          editingMemberId == item.id ? Icons.check : Icons.edit,
                                          color: Colors.orangeAccent,
                                          size: 18.sp,
                                        ),
                                      ),
                                      SizedBox(width: 15.w),
                                      Bounceable(
                                        onTap: () {
                                          DeleteShareRequest
                                          deleteShareRequest = DeleteShareRequest(
                                            receiptId: widget.selectedId,
                                            receiptMembersModel:
                                            ReceiptMembersModel(
                                              shareValue: item.shareValue,
                                              name: item.name,
                                              id: item.id,
                                            ),
                                          );
                                          HomePageCubit.get(context).deleteShare(deleteShareRequest);
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                          size: 18.sp,
                                        ),
                                      ),
                                    ],
                                  )
                                      : Container(),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.w,
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "${AppStrings.totalPayed}: ",
                            style: TextStyle(
                              color: AppColors.cBlack, // color for the label
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text:
                                "${widget.receiptMembersList.fold(0.0, (sum, m) => sum + m.shareValue).toStringAsFixed(2)} L.E.",
                                style: TextStyle(
                                  color: Colors.redAccent, // color for the value
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.w,
                        ),
                        RichText(
                          text: TextSpan(
                            text: "${AppStrings.total}: ",
                            style: TextStyle(
                              color: AppColors.cBlack, // color for the label
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text:
                                "${widget.totalValue} L.E.",
                                style: TextStyle(
                                  color: AppColors.cSecondary, // color for the value
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    InkWell(
                      onTap: () {
                        HomePageCubit.get(
                          context,
                        ).getReceipts(widget.cycleName);
                      },
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.cSecondary,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.cThird,
                          ),
                        ),
                        child: Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    )
                  ],
                )


              ],
            ),
          );
        },
      ),
    );
  }
}

/*

* */
