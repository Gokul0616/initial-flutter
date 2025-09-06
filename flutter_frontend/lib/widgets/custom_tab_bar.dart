import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final void Function(int)? onTap;

  const CustomTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: TabBar(
        controller: controller,
        onTap: onTap,
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        indicator: const BoxDecoration(),
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.normal,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        splashFactory: NoSplash.splashFactory,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
    );
  }
}