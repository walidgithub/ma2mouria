import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ma2mouria/core/utils/constant/app_strings.dart';
import 'package:ma2mouria/core/utils/style/app_colors.dart';
import 'package:ma2mouria/features/home_page/data/model/member_model.dart';
import 'package:ma2mouria/features/home_page/data/model/receipt_members_model.dart';
import 'package:ma2mouria/features/home_page/data/model/rules_model.dart';
import 'package:ma2mouria/features/home_page/data/requests/add_receipt_request.dart';
import 'package:ma2mouria/features/home_page/data/requests/delete_member_request.dart';
import 'package:ma2mouria/features/home_page/presentaion/bloc/home_page_cubit.dart';
import 'package:ma2mouria/features/home_page/presentaion/bloc/home_page_state.dart';
import 'package:ma2mouria/features/home_page/presentaion/ui/widgets/receipt_members.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/di.dart';
import '../../../../core/preferences/app_pref.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/temp.dart';
import '../../../../core/utils/constant/months.dart';
import '../../../../core/utils/ui_components/loading_dialog.dart';
import '../../../../core/utils/ui_components/snackbar.dart';
import '../../data/model/cycle_model.dart';
import '../../data/model/receipt_model.dart';
import '../../data/requests/add_member_request.dart';
import '../../data/requests/delete_share_request.dart';
import '../../data/requests/edit_share_request.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final AppPreferences _appPreferences = sl<AppPreferences>();

  final double startValue = 0.0;
  final double endValue = 0.50;

  int _currentIndex = 0;
  bool isShared = false;
  bool isReceiptCreator = false;
  bool showTotal = false;
  bool isHead = false;

  final TextEditingController _calcTextController = TextEditingController();

  final TextEditingController _memberBudgetTextController =
      TextEditingController();
  final TextEditingController _membersCountTextController =
      TextEditingController();
  final TextEditingController _cycleTextController = TextEditingController();
  final TextEditingController _receiptDetailTextController =
      TextEditingController();
  final TextEditingController _receiptValueTextController =
      TextEditingController();
  final TextEditingController _receiptShareTextController =
      TextEditingController();

  double result = 0;

  CycleModel? activeCycleData;
  String? selectedId;
  String? selectedReceiptUserName;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: startValue, end: endValue).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _animationController.forward();

    _calcTextController.addListener(_onTextChanged);
    result = leftOf + spending;

    initDateDropdowns();

    getUserData();
    HomePageCubit.get(context).getUsers();
    HomePageCubit.get(context).getActiveCycle();
    HomePageCubit.get(context).getRuleByEmail(userData!['email'] ?? 'Guest');
  }

  void _onTextChanged() {
    final text = _calcTextController.text;

    final validText = text.replaceAll(RegExp(r'[^0-9+]'), '');

    if (validText.isEmpty) {
      setState(() {
        result = total - (leftOf + spending);
      });

      return;
    }

    final numbers = validText
        .split('+')
        .where((n) => n.isNotEmpty)
        .map(double.parse)
        .toList();

    final sumInput = numbers.fold<double>(0, (a, b) => a + b);

    setState(() {
      result = total - (leftOf + spending) - sumInput;
    });
  }

  void initDateDropdowns() {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonthIndex = now.month - 1;
    final currentDay = now.day;

    years = [
      (currentYear - 1).toString(),
      currentYear.toString(),
      (currentYear + 1).toString(),
    ];

    selectedYear = currentYear.toString();
    selectedMonth = months[currentMonthIndex];

    final lastDay = DateTime(currentYear, now.month + 1, 0).day;
    days = List.generate(lastDay, (i) => (i + 1).toString());
    selectedDay = currentDay.toString();
  }

  double total = 1000.0;
  double spending = 500.0;
  double leftOf = 0.0;
  Map<String, String?>? userData;
  String savedReceiptId = "";

  Future<void> getUserData() async {
    final data = _appPreferences.getUserData();

    setState(() {
      userData = data;
      photoUrl = userData?['photoUrl'];
    });
  }

  String? selectedDay;
  String? selectedMonth;
  String? selectedYear;

  String userName = "";
  String? photoUrl;

  void _updateDays() {
    if (selectedMonth == null || selectedYear == null) return;

    final monthIndex = months.indexOf(selectedMonth!) + 1;
    final year = int.parse(selectedYear!);
    final lastDay = DateTime(year, monthIndex + 1, 0).day;

    setState(() {
      days = List.generate(lastDay, (i) => (i + 1).toString());

      if (selectedDay != null) {
        final dayInt = int.tryParse(selectedDay!) ?? 1;
        if (dayInt > lastDay) selectedDay = lastDay.toString();
      }
    });
  }

  List<MemberModel> membersList = [];
  List<RulesModel> usersList = [];
  List<ReceiptModel> receiptsList = [];
  List<ReceiptMembersModel> receiptMembersList = [];
  List<String> years = [];
  List<String> days = [];
  List<String> receiptsIds = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _animationController.dispose();
    _calcTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomePageCubit, HomePageState>(
      listener: (context, state) async {
        if (state is GetRuleByEmailLoadingState) {
          showLoading();
        } else if (state is GetRuleByEmailErrorState) {
          hideLoading();
          showErrorSnackBar(context, state.errorMessage);
        } else if (state is GetRuleByEmailSuccessState) {
          hideLoading();

          setState(() {
            userName = state.rulesModel.name;
            if (state.rulesModel.rule == "head") {
              isHead = true;
            }
          });

          // ------------------------------------------------------
        } else if (state is LogoutLoadingState) {
          showLoading();
        } else if (state is LogoutErrorState) {
          hideLoading();
          showErrorSnackBar(context, state.errorMessage);
        } else if (state is LogoutSuccessState) {
          hideLoading();
          await _appPreferences.setUserLoggedOut();
          Navigator.pushReplacementNamed(context, Routes.loginRoute);
          // ------------------------------------------------------
        } else if (state is GetUsersLoadingState) {
          showLoading();
        } else if (state is GetUsersErrorState) {
          hideLoading();
          showErrorSnackBar(context, state.errorMessage);
        } else if (state is GetUsersSuccessState) {
          hideLoading();
          setState(() {
            usersList = state.members;
          });
          // ------------------------------------------------------
        } else if (state is AddCycleLoadingState) {
          showLoading();
        } else if (state is AddCycleErrorState) {
          hideLoading();
          showErrorSnackBar(context, state.errorMessage);
        } else if (state is AddCycleSuccessState) {
          hideLoading();
          showSuccessSnackBar(context, "Cycle added successfully");
          _membersCountTextController.text = "";
          _memberBudgetTextController.text = "";
          HomePageCubit.get(context).getActiveCycle();
          // ------------------------------------------------------
        } else if (state is GetActiveCycleLoadingState) {
          showLoading();
        } else if (state is GetActiveCycleErrorState) {
          hideLoading();
          setState(() {
            activeCycleData = null;
            _cycleTextController.text = "";
            membersList = [];
            receiptsList = [];
            receiptsIds = [];
            receiptMembersList = [];
            selectedReceiptUserName = "";
            _receiptValueTextController.text = "";
            _receiptDetailTextController.text = "";
            _receiptShareTextController.text = "";
          });
          showErrorSnackBar(context, state.errorMessage);
        } else if (state is GetActiveCycleSuccessState) {
          hideLoading();

          setState(() {
            activeCycleData = state.cycleModel;
            _cycleTextController.text = activeCycleData!.cycleName;
            membersList = activeCycleData!.members;
            receiptsList = activeCycleData!.receipts;
            receiptsIds = receiptsList
                .where(
                  (receipt) => receipt.shared,
                ) // filter only shared receipts
                .map((receipt) => receipt.receiptId) // get the receiptId
                .toList();
          });
          // ------------------------------------------------------
        } else if (state is GetMembersLoadingState) {
          showLoading();
        } else if (state is GetMembersErrorState) {
          hideLoading();
          showErrorSnackBar(context, state.errorMessage);
        } else if (state is GetMembersSuccessState) {
          hideLoading();

          setState(() {
            membersList = state.members;
          });

          // ------------------------------------------------------
        } else if (state is DeleteCycleLoadingState) {
          showLoading();
        } else if (state is DeleteCycleErrorState) {
          hideLoading();
          showErrorSnackBar(context, state.errorMessage);
        } else if (state is DeleteCycleSuccessState) {
          hideLoading();
          setState(() {
            activeCycleData = null;
          });
          // ------------------------------------------------------
        } else if (state is AddMemberLoadingState) {
          showLoading();
        } else if (state is AddMemberErrorState) {
          hideLoading();
          showErrorSnackBar(context, state.errorMessage);
        } else if (state is AddMemberSuccessState) {
          hideLoading();
          HomePageCubit.get(context).getMembers(_cycleTextController.text);
          // ------------------------------------------------------
        } else if (state is DeleteMemberLoadingState) {
          showLoading();
        } else if (state is DeleteMemberErrorState) {
          hideLoading();
          showErrorSnackBar(context, state.errorMessage);
        } else if (state is DeleteMemberSuccessState) {
          hideLoading();
          HomePageCubit.get(context).getMembers(_cycleTextController.text);
          // ------------------------------------------------------
        } else if (state is GetReceiptsLoadingState) {
          showLoading();
        } else if (state is GetReceiptsErrorState) {
          hideLoading();
          showErrorSnackBar(context, state.errorMessage);
        } else if (state is GetReceiptsSuccessState) {
          hideLoading();

          setState(() {
            receiptMembersList = [];
            selectedId = null;
            receiptsList = state.receipts;
            receiptsIds = receiptsList
                .where((receipt) => receipt.shared)
                .map((receipt) => receipt.receiptId)
                .toList();
            receiptMembersList = receiptsList.firstWhere((receipt) {
              return receipt.shared == true && receipt.receiptId == selectedId;
            }).receiptMembers;
          });
          // ------------------------------------------------------
        } else if (state is AddReceiptLoadingState) {
          showLoading();
        } else if (state is AddReceiptErrorState) {
          hideLoading();
          showErrorSnackBar(context, state.errorMessage);
          _receiptShareTextController.text = "";
          _receiptDetailTextController.text = "";
          _receiptValueTextController.text = "";
          receiptMembersList = [];
        } else if (state is AddReceiptSuccessState) {
          hideLoading();
          _receiptShareTextController.text = "";
          _receiptDetailTextController.text = "";
          _receiptValueTextController.text = "";
          receiptMembersList = [];
          isReceiptCreator
              ? savedReceiptId = state.receiptId
              : savedReceiptId = "";
          HomePageCubit.get(context).getReceipts(activeCycleData!.cycleName);
          // ------------------------------------------------------
        } else if (state is DeleteReceiptLoadingState) {
          showLoading();
        } else if (state is DeleteReceiptErrorState) {
          hideLoading();
          showErrorSnackBar(context, state.errorMessage);
        } else if (state is DeleteReceiptSuccessState) {
          hideLoading();
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBody: true,
          body: Container(
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
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _buildHeader(),
                    ),

                    Expanded(
                      child: _currentIndex == 0
                          ? _buildCreditContent()
                          : _currentIndex == 1
                          ? _buildReceiptContent()
                          : _currentIndex == 2
                          ? isHead
                                ? _buildCycleContent()
                                : Container()
                          : _currentIndex == 3
                          ? isHead
                                ? _buildCycleMembersContent()
                                : Container()
                          : _buildReportsContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.h, sigmaY: 10.w),
              child: Container(
                margin: EdgeInsets.all(10.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      icon: Icons.attach_money,
                      index: 0,
                      isActive: _currentIndex == 0,
                    ),
                    _buildNavItem(
                      icon: Icons.add,
                      index: 1,
                      isActive: _currentIndex == 1,
                    ),
                    if (isHead)
                      _buildNavItem(
                        icon: Icons.add_to_drive_rounded,
                        index: 2,
                        isActive: _currentIndex == 2,
                      ),
                    if (isHead)
                      _buildNavItem(
                        icon: Icons.person,
                        index: 3,
                        isActive: _currentIndex == 3,
                      ),
                    _buildNavItem(
                      icon: Icons.bar_chart_sharp,
                      index: 4,
                      isActive: _currentIndex == 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  AppStrings.hi,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5.w),
                Text('👋', style: TextStyle(fontSize: 15.sp)),
              ],
            ),
            Row(
              children: [
                Bounceable(
                  onTap: () {
                    HomePageCubit.get(context).logout();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Icon(Icons.logout, color: Colors.white, size: 15.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                CircleAvatar(
                  radius: 25.r,
                  backgroundColor: AppColors.cWhite,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cIsActive, width: 2),
                    ),
                    child: ClipOval(
                      child: photoUrl == null
                          ? const CircularProgressIndicator()
                          : CachedNetworkImage(
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(
                                    strokeWidth: 2.w,
                                    color: AppColors.cIsActive,
                                  ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.person),
                              imageUrl: photoUrl!,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Text(
          userName,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        initDateDropdowns();
        if (index == 3 || index == 2) {
          HomePageCubit.get(context).getActiveCycle();
        }
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF8C61) : const Color(0xFF2E2159),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }

  Widget _buildSpendingRow({
    required String label,
    required Color color,
    required String amount,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              amount,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.white70, fontSize: 15.sp),
          ),
          dropdownColor: Colors.black87,
          iconEnabledColor: Colors.white70,
          isDense: true,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCreditContent() {
    return Column(
      children: [
        Text(
          AppStrings.myCredit,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 10.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.h, sigmaY: 10.w),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5.w,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'December',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final percent = _animation.value;

                      return CircularPercentIndicator(
                        radius: 50.r,
                        lineWidth: 7.w,
                        percent: percent,
                        circularStrokeCap: CircularStrokeCap.round,
                        backgroundColor: Colors.white.withOpacity(0.1),

                        linearGradient: const LinearGradient(
                          colors: [
                            Color(0xFF6B4EFF),
                            Color(0xFFFF8C61),
                            Color(0xFFFFB088),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),

                        animation: false,

                        center: Text(
                          '${(percent * 100).toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  Column(
                    children: [
                      _buildSpendingRow(
                        label: AppStrings.leftOf,
                        color: const Color(0xFFFF8C61),
                        amount: "${result.toStringAsFixed(2)} L.E.",
                      ),
                      const SizedBox(height: 16),
                      _buildSpendingRow(
                        label: AppStrings.spending,
                        color: const Color(0xFFAF133D),
                        amount: "${spending.toStringAsFixed(2)} L.E.",
                      ),
                      const SizedBox(height: 16),
                      _buildSpendingRow(
                        label: AppStrings.total,
                        color: const Color(0xFF6B4EFF),
                        amount: "${total.toStringAsFixed(2)} L.E.",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: 20.h),

        TextField(
          controller: _calcTextController,
          keyboardType: TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
          ],
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: AppStrings.typeNumbers,
            hintStyle: const TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            prefixIcon: Icon(Icons.calculate, color: Colors.white, size: 20.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            AppStrings.addReceipt,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: 10.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDropdown(
              hint: AppStrings.year,
              value: selectedYear,
              items: years,
              onChanged: (v) {
                setState(() => selectedYear = v);

                _updateDays();
              },
            ),
            SizedBox(width: 10.w),
            _buildDropdown(
              hint: AppStrings.month,
              value: selectedMonth,
              items: months,
              onChanged: (v) {
                setState(() => selectedMonth = v);

                _updateDays();
              },
            ),
            SizedBox(width: 10.w),
            _buildDropdown(
              hint: AppStrings.day,
              value: selectedDay,
              items: days,
              onChanged: (v) {
                setState(() => selectedDay = v);
              },
            ),
          ],
        ),

        SizedBox(height: 10.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isShared,
                  activeColor: Colors.orangeAccent,
                  onChanged: (value) {
                    setState(() {
                      isShared = value!;
                      _receiptValueTextController.text = "";
                      _receiptDetailTextController.text = "";
                      _receiptShareTextController.text = "";
                      receiptMembersList = [];
                      savedReceiptId = "";
                      selectedId = null;
                      if (!isShared) {
                        isReceiptCreator = false;
                      }
                      HomePageCubit.get(
                        context,
                      ).getReceipts(activeCycleData!.cycleName);
                    });
                  },
                ),
                Text(AppStrings.shared, style: TextStyle(color: Colors.white)),
              ],
            ),

            SizedBox(width: 20.w),

            isShared
                ? Row(
                    children: [
                      Checkbox(
                        value: isReceiptCreator,
                        activeColor: Colors.orangeAccent,
                        onChanged: (value) {
                          _receiptValueTextController.text = "";
                          _receiptDetailTextController.text = "";
                          _receiptShareTextController.text = "";
                          receiptMembersList = [];
                          savedReceiptId = "";
                          selectedId = null;
                          setState(() {
                            isReceiptCreator = value!;
                          });
                        },
                      ),
                      Text(
                        AppStrings.receiptCreator,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),

        SizedBox(height: 10.h),

        isShared && !isReceiptCreator
            ? Column(
                children: [
                  StatefulBuilder(
                    builder: (context, setStateDropdown) {
                      return Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: const Color(0xFF2E2159),
                              value: selectedId,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                              ),
                              hint: Text(
                                AppStrings.receiptId,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15.sp,
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                              ),
                              items: receiptsIds.map((name) {
                                return DropdownMenuItem(
                                  value: name,
                                  child: Text(name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setStateDropdown(() {
                                  selectedId = value;
                                  selectedReceiptUserName = receiptsList
                                      .firstWhere((receipt) {
                                        return receipt.shared == true &&
                                            receipt.receiptId == value;
                                      })
                                      .receiptCreator;
                                  _receiptValueTextController.text =
                                      receiptsList
                                          .firstWhere((receipt) {
                                            return receipt.shared == true &&
                                                receipt.receiptId == value;
                                          })
                                          .receiptValue
                                          .toString();
                                  _receiptDetailTextController.text =
                                      receiptsList.firstWhere((receipt) {
                                        return receipt.shared == true &&
                                            receipt.receiptId == value;
                                      }).receiptDetail;
                                  receiptMembersList = receiptsList.firstWhere((
                                    receipt,
                                  ) {
                                    return receipt.shared == true &&
                                        receipt.receiptId == value;
                                  }).receiptMembers;
                                  _receiptShareTextController.text = "";
                                });
                              },
                            ),
                          ),

                          SizedBox(width: 8.w),

                          InkWell(
                            onTap: () {
                              setStateDropdown(() {
                                selectedId = null;
                              });
                              _receiptValueTextController.text = "";
                              _receiptDetailTextController.text = "";
                              _receiptShareTextController.text = "";
                              receiptMembersList = [];
                              HomePageCubit.get(
                                context,
                              ).getReceipts(activeCycleData!.cycleName);
                            },
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              )
            : Container(),

        isShared && !isReceiptCreator ? SizedBox(height: 10.h) : Container(),

        TextField(
          controller: _receiptDetailTextController,
          enabled: isShared
              ? isReceiptCreator
                    ? true
                    : false
              : true,
          keyboardType: TextInputType.text,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: AppStrings.receiptDetail,
            hintStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),

        SizedBox(height: 10.h),

        TextField(
          controller: _receiptValueTextController,
          enabled: isShared
              ? isReceiptCreator
                    ? true
                    : false
              : true,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: AppStrings.receiptValue,
            hintStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),

        isShared
            ? Column(
                children: [
                  SizedBox(height: 10.h),

                  TextField(
                    controller: _receiptShareTextController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
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
                    ),
                  ),
                ],
              )
            : Container(),

        SizedBox(height: 10.h),

        isShared && isReceiptCreator
            ? Row(
                children: [
                  Text(
                    "${AppStrings.receiptId}: ",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15.sp,
                    ),
                  ),
                  Text(
                    savedReceiptId,
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              )
            : Container(),

        isShared && isReceiptCreator ? SizedBox(height: 10.h) : Container(),

        Row(
          mainAxisAlignment:
              isShared && !isReceiptCreator && userData!['name'] == userName
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            SizedBox(
              child: Bounceable(
                onTap: () {
                  if (!isShared) {
                    _receiptShareTextController.text =
                        _receiptValueTextController.text;
                  }
                  final receiptDetailText = _receiptDetailTextController.text
                      .trim();
                  final receiptValueText = _receiptValueTextController.text
                      .trim();
                  final receiptShareText = _receiptShareTextController.text
                      .trim();

                  if (receiptDetailText.isEmpty ||
                      receiptValueText.isEmpty ||
                      receiptShareText.isEmpty) {
                    showWarningSnackBar(
                      context,
                      "Please fill in all required fields.",
                    );
                    return;
                  }

                  final receiptValue = double.tryParse(receiptValueText);
                  final receiptShare = double.tryParse(receiptShareText);
                  final receiptDetail = receiptDetailText;

                  if (receiptValue == null ||
                      receiptShare == null ||
                      receiptDetail == null) {
                    showErrorSnackBar(
                      context,
                      "Please enter valid numbers for receipt value and my share.",
                    );
                    return;
                  }

                  if (isShared && !isReceiptCreator) {
                    String totalValue = receiptMembersList
                        .fold(0.0, (sum, m) => sum + m.shareValue)
                        .toStringAsFixed(2);
                    if (double.parse(_receiptValueTextController.text) < (double.parse(totalValue) + double.parse(_receiptShareTextController.text))) {
                      showErrorSnackBar(
                        context,
                        "My share value is not available.",
                      );
                      return;
                    }
                  }

                  if (isReceiptCreator &&
                      double.parse(_receiptShareTextController.text) >=
                          double.parse(_receiptValueTextController.text)) {
                    showErrorSnackBar(
                      context,
                      "My share value should be smaller than receipt value.",
                    );
                    return;
                  }

                  var uuid = Uuid();
                  String id = uuid.v4();
                  String memberId = uuid.v4();
                  AddReceiptRequest receipt = AddReceiptRequest(
                    cycleName: activeCycleData!.cycleName,
                    receipt: ReceiptModel(
                      id: id,
                      receiptCreator: !isShared
                          ? userName
                          : isReceiptCreator
                          ? userName
                          : selectedReceiptUserName!,
                      receiptDate: "$selectedDay $selectedMonth $selectedYear",
                      receiptDetail: _receiptDetailTextController.text,
                      receiptId: isShared && !isReceiptCreator
                          ? selectedId!
                          : "${_receiptDetailTextController.text} ${id.substring(0, 7)}",
                      receiptMembers: [
                        ReceiptMembersModel(
                          id: memberId,
                          name: userName,
                          shareValue: double.parse(
                            _receiptShareTextController.text,
                          ),
                        ),
                      ],
                      receiptValue: double.parse(
                        _receiptValueTextController.text,
                      ),
                      shared: isShared,
                    ),
                  );
                  HomePageCubit.get(context).addReceipt(receipt);
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 10.h,
                          ),
                          width: 120.w,
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
                              AppStrings.save,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isShared && !isReceiptCreator
                ? SizedBox(
                    child: Bounceable(
                      onTap: () {
                        if (isShared) {
                          selectedId != null ?
                          showModalBottomSheet(
                            context: context,
                            constraints: BoxConstraints.expand(
                              height: MediaQuery.sizeOf(context).height / 2,
                              width: MediaQuery.sizeOf(context).width,
                            ),
                            isScrollControlled: true,
                            barrierColor: AppColors.cTransparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30.r),
                              ),
                            ),
                            builder: (BuildContext context) {
                              return ReceiptMembersBottomSheet(
                                userData: userData,
                                receiptMembersList: receiptMembersList,
                                selectedId: selectedId!,
                                cycleName: activeCycleData!.cycleName,
                              );
                            },
                          ) : showErrorSnackBar(context, "Select the receipt");
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 10.h,
                                sigmaY: 10.w,
                              ),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 10.h,
                                ),
                                width: 60.w,
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
                                  child: Icon(Icons.group, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),

          ],
        ),
      ],
    );
  }

  Widget _buildCycleContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            AppStrings.addCycle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: 10.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDropdown(
              hint: AppStrings.month,
              value: selectedMonth,
              items: months,
              onChanged: (v) {
                setState(() => selectedMonth = v);
              },
            ),
            SizedBox(width: 10.w),
            _buildDropdown(
              hint: AppStrings.year,
              value: selectedYear,
              items: years,
              onChanged: (v) {
                setState(() => selectedYear = v);
              },
            ),
          ],
        ),

        SizedBox(height: 10.h),

        TextField(
          controller: _memberBudgetTextController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: AppStrings.memberBudget,
            hintStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),

        SizedBox(height: 10.h),

        TextField(
          controller: _membersCountTextController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: AppStrings.membersCount,
            hintStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),

        SizedBox(height: 15.h),

        Bounceable(
          onTap: () {
            final membersCountText = _membersCountTextController.text.trim();
            final memberBudgetText = _memberBudgetTextController.text.trim();

            if (membersCountText.isEmpty || memberBudgetText.isEmpty) {
              showWarningSnackBar(
                context,
                "Please fill in all required fields.",
              );
              return;
            }

            final membersCount = int.tryParse(membersCountText);
            final memberBudget = double.tryParse(memberBudgetText);

            if (membersCount == null || memberBudget == null) {
              showErrorSnackBar(
                context,
                "Please enter valid numbers for members count and budget.",
              );
              return;
            }

            var uuid = Uuid();
            String id = uuid.v4();
            String userId = uuid.v4();
            CycleModel cycle = CycleModel(
              id: id,
              membersCount: int.parse(_membersCountTextController.text),
              active: true,
              cycleDate: "$selectedMonth  $selectedYear",
              cycleName: "$selectedMonth  $selectedYear",
              memberBudget: double.parse(_memberBudgetTextController.text),
              members: [
                MemberModel(
                  id: userId,
                  name: userData!['name']!,
                  email: userData!['email']!,
                ),
              ],
              receipts: [],
            );
            HomePageCubit.get(context).addCycle(cycle);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.h, sigmaY: 10.w),
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      width: 120.w,
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
                          AppStrings.save,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20.h),

        activeCycleData != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.h, sigmaY: 10.w),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 0.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5.w,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.activeCycle,
                              style: TextStyle(
                                color: Colors.deepOrangeAccent,
                                fontSize: 15.sp,
                                letterSpacing: 0.5,
                              ),
                            ),

                            SizedBox(height: 10.h),

                            Text(
                              activeCycleData!.cycleName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                letterSpacing: 0.5,
                              ),
                            ),

                            SizedBox(height: 10.h),

                            Row(
                              children: [
                                Text(
                                  "${AppStrings.memberBudget}:",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    letterSpacing: 0.5,
                                  ),
                                ),

                                SizedBox(width: 10.w),

                                Text(
                                  "${activeCycleData!.memberBudget} L.E.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "${AppStrings.membersCount}:",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    letterSpacing: 0.5,
                                  ),
                                ),

                                SizedBox(width: 10.w),

                                Text(
                                  activeCycleData!.membersCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Bounceable(
                          onTap: () {
                            HomePageCubit.get(
                              context,
                            ).deleteCycle(activeCycleData!.cycleName);
                          },
                          child: Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                            size: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _buildCycleMembersContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            AppStrings.cycleMembers,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: 10.h),

        TextField(
          controller: _cycleTextController,
          keyboardType: TextInputType.text,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: AppStrings.cycleName,
            hintStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),

        SizedBox(height: 10.h),

        usersList.isNotEmpty
            ? SizedBox(
                height: 70.h,
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 2,
                  radius: Radius.circular(10),
                  notificationPredicate: (notif) => notif.depth == 0,
                  controller: _scrollController,
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 10.h),
                    scrollDirection: Axis.horizontal,
                    itemCount: usersList.length,
                    itemBuilder: (context, index) {
                      if (index == 0) return SizedBox.shrink();
                      final item = usersList[index];
                      return Bounceable(
                        onTap: () {},
                        child: Container(
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
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Bounceable(
                                onTap: () {
                                  AddMemberRequest addMemberRequest =
                                      AddMemberRequest(
                                        cycleName: _cycleTextController.text,
                                        member: MemberModel(
                                          id: item.id,
                                          name: item.name,
                                          email: item.email,
                                        ),
                                      );
                                  HomePageCubit.get(
                                    context,
                                  ).addMember(addMemberRequest);
                                },
                                child: Icon(
                                  Icons.add_box_rounded,
                                  color: Colors.teal,
                                  size: 18.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            : Container(),

        SizedBox(),

        membersList.isNotEmpty
            ? Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 2,
                  radius: Radius.circular(10),
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.h),
                    itemCount: membersList.length,
                    itemBuilder: (context, index) {
                      final item = membersList[index];
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
                            Row(
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            item.name != userData!['name']
                                ? Bounceable(
                                    onTap: () {
                                      DeleteMemberRequest deleteMemberRequest =
                                          DeleteMemberRequest(
                                            cycleName:
                                                _cycleTextController.text,
                                            member: MemberModel(
                                              id: item.id,
                                              name: item.name,
                                              email: item.email,
                                            ),
                                          );
                                      HomePageCubit.get(
                                        context,
                                      ).deleteMember(deleteMemberRequest);
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                      size: 18.sp,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _buildReportsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            AppStrings.reports,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        SizedBox(height: 10.h),

        isHead
            ? Center(
                child: Row(
                  children: [
                    Checkbox(
                      value: showTotal,
                      activeColor: Colors.orangeAccent,
                      onChanged: (value) {
                        setState(() {
                          showTotal = value!;
                        });
                      },
                    ),
                    Text(
                      AppStrings.showTotal,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
            : Container(),

        showTotal
            ? Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 2,
                  radius: Radius.circular(10),
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.h),
                    itemCount: generalReportList.length,
                    itemBuilder: (context, index) {
                      final item = generalReportList[index];
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${AppStrings.memberName}:",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 5.h),
                                Text(
                                  item["name"],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 5.h),

                            Row(
                              children: [
                                Text(
                                  "${AppStrings.leftOf}:",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 5.h),
                                Text(
                                  "${item["left"].toStringAsFixed(2)} L.E.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
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
              )
            : Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 2,
                  radius: Radius.circular(10),
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.h),
                    itemCount: reportsList.length,
                    itemBuilder: (context, index) {
                      final item = reportsList[index];
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item["restaurant"],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${item["receipt_value"].toStringAsFixed(2)} L.E.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Bounceable(
                                  onTap: () {},
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 5.h),

                            Text(
                              item["date"],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

        SizedBox(height: 20.h),

        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.h, sigmaY: 10.w),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 0.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "${showTotal ? AppStrings.totalLeft : AppStrings.total}:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          letterSpacing: 0.5,
                        ),
                      ),

                      SizedBox(width: 10.w),

                      Text(
                        "1250 L.E.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  showTotal
                      ? Container()
                      : Row(
                          children: [
                            Text(
                              "${AppStrings.leftOf}:",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                letterSpacing: 0.5,
                              ),
                            ),

                            SizedBox(width: 10.w),

                            Text(
                              "1250 L.E.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
