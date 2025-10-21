import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ma2mouria/core/utils/constant/app_strings.dart';
import 'package:ma2mouria/core/utils/style/app_colors.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final double startValue = 0.0;
  final double endValue = 0.50;

  int _currentIndex = 0;
  bool isGroup = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: startValue, end: endValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.forward();
  }
  final List<Map<String, dynamic>> fatoorahList = [
    {"name": "Me", "value": 250.0},
    {"name": "Mo'men", "value": 150.5},
    {"name": "Ahmed", "value": 320.0},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
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
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 15.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          CircleAvatar(
                            radius: 20.r,
                            backgroundImage: NetworkImage(
                              'https://avatar.iran.liara.run/public/boy',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.h, 0, 20.w, 0),
                  child: Row(
                    children: [
                      Text(
                        'Walid mohamed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                _currentIndex == 0
                    ? _buildHomeContent()
                    : _buildFatoorahContent(),
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
                  icon: Icons.home_filled,
                  index: 0,
                  isActive: _currentIndex == 0,
                ),
                _buildNavItem(
                  icon: Icons.add,
                  index: 1,
                  isActive: _currentIndex == 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
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

  Widget _buildHomeContent() {
    return Column(
      children: [
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
                          '${(percent * 100).toStringAsFixed(0)}%',
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
                        amount: '\$500',
                      ),
                      const SizedBox(height: 16),
                      _buildSpendingRow(
                        label: AppStrings.spending,
                        color: const Color(0xFFAF133D),
                        amount: '\$1024',
                      ),
                      const SizedBox(height: 16),
                      _buildSpendingRow(
                        label: AppStrings.total,
                        color: const Color(0xFF6B4EFF),
                        amount: '\$2000',
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
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: AppStrings.test,
            hintStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            prefixIcon: Icon(
              Icons.calculate,
              color: AppColors.cWhite,
              size: 20.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFatoorahContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isGroup,
                  activeColor: Colors.orangeAccent,
                  onChanged: (value) {
                    setState(() {
                      isGroup = value!;
                    });
                  },
                ),
                Text(
                  isGroup ? AppStrings.group : AppStrings.single,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),

            isGroup ? Bounceable(
              onTap: () {

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
                  )
                ],
              ),
            ) : Container()
          ],
        ),

        SizedBox(height: 10.h),

        TextField(
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: AppStrings.value,
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
            hintText: AppStrings.invoiceNumber,
            hintStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),

        SizedBox(height: 10.h),

        StatefulBuilder(
          builder: (context, setStateDropdown) {
            String? selectedRestaurant;
            final restaurants = ['KFC', 'Mac', 'Pizza Hut', 'Hardee\'s'];
            return DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF2E2159),
              value: selectedRestaurant,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
              ),
              hint: Text(
                AppStrings.restaurantName,
                style: TextStyle(color: Colors.white70,fontSize: 15.sp),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
              items: restaurants.map((name) {
                return DropdownMenuItem(value: name, child: Text(name));
              }).toList(),
              onChanged: (value) {
                setStateDropdown(() {
                  selectedRestaurant = value;
                });
              },
            );
          },
        ),

        SizedBox(height: 30.h),

        Bounceable(
          onTap: () {

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
                        AppStrings.save,
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
        ),

        SizedBox(height: 20.h),

        isGroup ? SizedBox(
          height: 100.h,
          child: ListView.builder(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: fatoorahList.length,
            itemBuilder: (context, index) {
              final item = fatoorahList[index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 5.w),
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.w,
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
                        Text(
                          "\$${item["value"].toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Icon(Icons.edit, color: Colors.orangeAccent, size: 18.sp),
                        SizedBox(width: 8.w),
                        Icon(Icons.delete, color: Colors.redAccent, size: 18.sp),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ) : SizedBox.shrink()
      ],
    );
  }
}
