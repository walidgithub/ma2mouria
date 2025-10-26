import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ma2mouria/core/utils/constant/app_strings.dart';
import 'package:ma2mouria/core/utils/style/app_colors.dart';
import 'package:ma2mouria/features/home_page/presentaion/bloc/home_page_cubit.dart';
import 'package:ma2mouria/features/home_page/presentaion/bloc/home_page_state.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/di/di.dart';
import '../../../../core/preferences/app_pref.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/ui_components/loading_dialog.dart';
import '../../../../core/utils/ui_components/snackbar.dart';

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
  bool isInvoiceCreator = false;
  bool showTotal = false;

  bool isHead = false;

  final TextEditingController _calcTextController = TextEditingController();
  double result = 0;

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

  final List<Map<String, dynamic>> invoiceList = [
    {"name": "Me", "value": 1250.0},
    {"name": "Mo'men ahmed", "value": 1150.5},
    {"name": "Ahmed abd elazziz", "value": 1320.0},
  ];

  final List<Map<String, dynamic>> membersList = [
    {"first_name": "Me", "last_name": ""},
    {"first_name": "Mo'men", "last_name": "Ahmed"},
    {"first_name": "Ahmed", "last_name": "Hassan"},
  ];

  final List<Map<String, dynamic>> reportsList = [
    {
      "restaurant": "kfcfdfd ",
      "date": "December 22 2025",
      "invoice_value": 1250.0,
    },
    {
      "restaurant": "nawara ssd",
      "date": "December 22 2025",
      "invoice_value": 1150.0,
    },
    {
      "restaurant": "alkilany",
      "date": "December 22 2025",
      "invoice_value": 1350.0,
    },
    {
      "restaurant": "alkilany dsg",
      "date": "December 22 2025",
      "invoice_value": 1350.0,
    },
    {
      "restaurant": "alkilany",
      "date": "December 22 2025",
      "invoice_value": 1350.0,
    },
    {
      "restaurant": "alkilany",
      "date": "December 22 2025",
      "invoice_value": 1350.0,
    },
    {
      "restaurant": "alkilany",
      "date": "December 22 2025",
      "invoice_value": 1350.0,
    },
    {
      "restaurant": "alkilany",
      "date": "December 22 2025",
      "invoice_value": 350.0,
    },
  ];

  final List<Map<String, dynamic>> generalReportList = [
    {"name": "walid barakat", "left": 1250.0},
    {"name": "Mo'men ahmed", "left": 1150.0},
    {"name": "Ahmed abd elaziz", "left": 1350.0},
  ];

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

  final List<String> months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

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

  List<String> years = [];
  List<String> days = [];

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
            showSnackBar(context, state.errorMessage);
          } else if (state is GetRuleByEmailSuccessState) {
            hideLoading();
            setState(() {
              userName = state.rulesModel.name;
              if (state.rulesModel.rule == "head") {
                isHead = true;
              }
            });
          } else if (state is LogoutLoadingState) {
            showLoading();
          } else if (state is LogoutErrorState) {
            hideLoading();
          } else if (state is LogoutSuccessState) {
            hideLoading();
            await _appPreferences.setUserLoggedOut();
            Navigator.pushReplacementNamed(context, Routes.loginRoute);
          }
        },
        builder: (context, state) {
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
                            ? _buildInvoiceContent()
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
        });
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
                      child: photoUrl == null ? const CircularProgressIndicator() : CachedNetworkImage(
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

  Widget _buildInvoiceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            AppStrings.addInvoice,
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
              onChanged: (v) => setState(() => selectedDay = v),
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
                        value: isInvoiceCreator,
                        activeColor: Colors.orangeAccent,
                        onChanged: (value) {
                          setState(() {
                            isInvoiceCreator = value!;
                          });
                        },
                      ),
                      Text(
                        AppStrings.invoiceCreator,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),

        SizedBox(height: 10.h),

        !isShared || isInvoiceCreator
            ? TextField(
                keyboardType: TextInputType.text,
                style: TextStyle(color: Colors.white, fontSize: 15.sp),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  hintText: AppStrings.invoiceDetail,
                  hintStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              )
            : Container(),

        isShared && !isInvoiceCreator
            ? Column(
                children: [
                  StatefulBuilder(
                    builder: (context, setStateDropdown) {
                      String? selectedRestaurant;
                      final restaurants = [
                        'KFC 454',
                        'Mac 8787',
                        'Pizza Hut 54',
                      ];

                      return Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: const Color(0xFF2E2159),
                              value: selectedRestaurant,
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
                                AppStrings.invoiceDetail,
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
                              items: restaurants.map((name) {
                                return DropdownMenuItem(
                                  value: name,
                                  child: Text(name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setStateDropdown(() {
                                  selectedRestaurant = value;
                                });
                              },
                            ),
                          ),

                          SizedBox(width: 8.w),

                          InkWell(
                            onTap: () {
                              setStateDropdown(() {
                                selectedRestaurant = null;
                              });
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

        SizedBox(height: 10.h),

        TextField(
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: AppStrings.invoiceValue,
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

        SizedBox(height: 15.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150.w,
              child: Bounceable(
                onTap: () {},
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
            isShared && isInvoiceCreator
                ? SizedBox(
                    width: 150.w,
                    child: Bounceable(
                      onTap: () {},
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
                                  horizontal: 20.w,
                                  vertical: 10.h,
                                ),
                                width: 150.w,
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
                                    AppStrings.approve,
                                    style: GoogleFonts.poppins(
                                      color: Colors.redAccent,
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
                  )
                : Container(),
          ],
        ),

        isShared
            ? Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 2,
                  radius: Radius.circular(10),
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.h),
                    itemCount: invoiceList.length,
                    itemBuilder: (context, index) {
                      final item = invoiceList[index];
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
                              item["name"],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            Row(
                              children: [
                                item["name"] == "Me"
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
                                  "${item["value"].toStringAsFixed(2)} L.E.",
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
              )
            : SizedBox.shrink(),
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
              onChanged: (v) => setState(() => selectedMonth = v),
            ),
            SizedBox(width: 10.w),
            _buildDropdown(
              hint: AppStrings.year,
              value: selectedYear,
              items: years,
              onChanged: (v) => setState(() => selectedYear = v),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        TextField(
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
          onTap: () {},
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "October 2025",
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
                            "1250 L.E.",
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
                            "11",
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
                    onTap: () {},
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
        ),
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

        SizedBox(
          height: 60.h,
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
              itemCount: membersList.length,
              itemBuilder: (context, index) {
                final item = membersList[index];
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
                          item["first_name"],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(width: 5.w),

                        Text(
                          item["last_name"],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(width: 10.w),
                        Bounceable(
                          onTap: () {},
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
        ),

        SizedBox(),

        Expanded(
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
                  margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 5.w),
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
                            item["first_name"],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            item["last_name"],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      item["first_name"] != "Me"
                          ? Bounceable(
                              onTap: () {},
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
        ),
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
                                  "${item["invoice_value"].toStringAsFixed(2)} L.E.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
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
