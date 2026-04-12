import 'package:flutter/material.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8.sp),
      ),
    );
  }
}

class PropertyCardSkeleton extends StatelessWidget {
  const PropertyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: double.infinity,
            height: 160.h,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.sp)),
          ),
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 120.w, height: 16.h),
                SizedBox(height: 8.h),
                SkeletonLoader(width: 180.w, height: 12.h),
                SizedBox(height: 12.h),
                SkeletonLoader(width: 80.w, height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SkeletonLoader(
          width: 50.w,
          height: 50.w,
          borderRadius: BorderRadius.circular(16.sp),
        ),
        SizedBox(height: 8.h),
        SkeletonLoader(width: 40.w, height: 10.h),
      ],
    );
  }
}
