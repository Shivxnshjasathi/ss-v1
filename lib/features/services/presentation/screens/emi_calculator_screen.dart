import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'dart:math';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  double loanAmount = 5000000;
  double tenure = 20;
  double interestRate = 8.5;

  String _formatCurrency(num amount) {
    String text = amount.toStringAsFixed(0);
    text = text.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+\d$)'),
      (Match m) => '${m[1]},',
    );
    return '₹$text';
  }

  double get _emi {
    double p = loanAmount;
    double r = interestRate / 12 / 100;
    double n = tenure * 12;
    if (r == 0) return p / n;
    return (p * r * pow((1 + r), n)) / (pow((1 + r), n) - 1);
  }

  double get _totalPayable {
    return _emi * tenure * 12;
  }

  double get _totalInterest {
    return _totalPayable - loanAmount;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E60FF),
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 16.w,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.emiCalculator,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.primaryTextColor,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.emiCalculator,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.homeLoanSubtitle,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12.sp,
                height: 1.5.h,
              ),
            ),
            SizedBox(height: 32.h),
            _buildSliderCard(
              icon: Icons.attach_money,
              label: l10n.loanAmount,
              valueText: _formatCurrency(loanAmount),
              minLabel: '₹1,00,000',
              maxLabel: '₹1,00,00,000',
              value: loanAmount,
              min: 100000,
              max: 10000000,
              onChanged: (val) => setState(() => loanAmount = val),
            ),
            SizedBox(height: 16.h),
            _buildSliderCard(
              icon: Icons.calendar_today,
              label: l10n.tenure,
              valueText: l10n.yearsCount(tenure.toInt()),
              minLabel: l10n.yrLabel,
              maxLabel: l10n.yrsLabel,
              value: tenure,
              min: 1,
              max: 30,
              onChanged: (val) => setState(() => tenure = val),
            ),
            SizedBox(height: 16.h),
            _buildSliderCard(
              icon: Icons.percent,
              label: l10n.interestRate,
              valueText: '${interestRate.toStringAsFixed(1)} %',
              minLabel: '5 %',
              maxLabel: '15 %',
              value: interestRate,
              min: 5,
              max: 15,
              onChanged: (val) => setState(() => interestRate = val),
            ),
            SizedBox(height: 32.h),
            _buildSummaryCard(l10n),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required IconData icon,
    required String label,
    required String valueText,
    required String minLabel,
    required String maxLabel,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16.w, color: Colors.black54),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                valueText,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              activeTrackColor: const Color(0xFF1E60FF),
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF1E60FF).withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
                elevation: 4,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minLabel,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                maxLabel,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.estimatedMonthlyEmi,
            style: TextStyle(
              color: Color(0xFF1E60FF),
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(_emi),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 32.sp,
                  height: 1.h,
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                margin: EdgeInsets.only(bottom: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1E60FF)),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Text(
                  l10n.lowRate,
                  style: TextStyle(
                    color: Color(0xFF1E60FF),
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalInterest,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatCurrency(_totalInterest),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalPayable,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatCurrency(_totalPayable),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12.w),
              border: Border.all(
                color: const Color(0xFF1E60FF).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 16.w,
                  color: Color(0xFF1E60FF),
                ),
                SizedBox(width: 8.w),
                Text(
                  l10n.viewRepaymentSchedule,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, size: 16.w, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
