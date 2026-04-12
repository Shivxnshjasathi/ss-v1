import 'package:flutter/material.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.w),
        child: Padding(
          padding: padding ?? EdgeInsets.all(16.0.w),
          child: child,
        ),
      ),
    );
  }
}
