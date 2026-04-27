import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'dart:math';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';

class FinancialCenterScreen extends ConsumerStatefulWidget {
  const FinancialCenterScreen({super.key});

  @override
  ConsumerState<FinancialCenterScreen> createState() => _FinancialCenterScreenState();
}

class _FinancialCenterScreenState extends ConsumerState<FinancialCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // EMI Calculator State
  double _loanAmount = 5000000;
  double _interestRate = 8.5;
  double _tenureYears = 20;

  // Eligibility State
  double _monthlyIncome = 100000;
  double _existingEmi = 10000;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _calculatedEmi {
    double p = _loanAmount;
    double r = _interestRate / 12 / 100;
    double n = _tenureYears * 12;
    if (r == 0) return p / n;
    return (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
  }

  double get _totalPayment => _calculatedEmi * _tenureYears * 12;
  double get _totalInterest => _totalPayment - _loanAmount;

  double get _maxEligibleEmi => (_monthlyIncome * 0.5) - _existingEmi;
  double get _maxLoanAmount {
    if (_maxEligibleEmi <= 0) return 0;
    double r = _interestRate / 12 / 100;
    double n = _tenureYears * 12;
    if (r == 0) return _maxEligibleEmi * n;
    return _maxEligibleEmi * (pow(1 + r, n) - 1) / (r * pow(1 + r, n));
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.services ?? 'Financial Center', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'EMI Calculator', icon: Icon(Icons.calculate)),
            Tab(text: 'Loan Eligibility', icon: Icon(Icons.verified_user)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEmiCalculator(context),
          _buildEligibilityChecker(context),
        ],
      ),
    );
  }

  Widget _buildEmiCalculator(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultCard(
            title: 'Your Monthly EMI',
            amount: _calculatedEmi,
            subtext: 'Total Interest: ${_formatCurrency(_totalInterest)}',
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 24.h),
          _buildSliderWithInput(
            label: 'Loan Amount',
            value: _loanAmount,
            min: 100000,
            max: 50000000,
            divisions: 499,
            displayValue: _formatCurrency(_loanAmount),
            onChanged: (val) => setState(() => _loanAmount = val),
          ),
          SizedBox(height: 16.h),
          _buildSliderWithInput(
            label: 'Interest Rate (% p.a.)',
            value: _interestRate,
            min: 6.0,
            max: 15.0,
            divisions: 90,
            displayValue: '${_interestRate.toStringAsFixed(1)}%',
            onChanged: (val) => setState(() => _interestRate = val),
          ),
          SizedBox(height: 16.h),
          _buildSliderWithInput(
            label: 'Tenure (Years)',
            value: _tenureYears,
            min: 1,
            max: 30,
            divisions: 29,
            displayValue: '${_tenureYears.toInt()} Yrs',
            onChanged: (val) => setState(() => _tenureYears = val),
          ),
          SizedBox(height: 24.h),
          _buildChartBreakdown(),
        ],
      ),
    );
  }

  Widget _buildEligibilityChecker(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultCard(
            title: 'Max Eligible Loan',
            amount: _maxLoanAmount > 0 ? _maxLoanAmount : 0,
            subtext: _maxLoanAmount > 0 
                ? 'Based on an EMI of ₹${_maxEligibleEmi.toStringAsFixed(0)}/month'
                : 'Not eligible based on current income/obligations',
            color: _maxLoanAmount > 0 ? Colors.green : Colors.redAccent,
          ),
          SizedBox(height: 24.h),
          _buildSliderWithInput(
            label: 'Monthly Net Income',
            value: _monthlyIncome,
            min: 10000,
            max: 1000000,
            divisions: 99,
            displayValue: _formatCurrency(_monthlyIncome),
            onChanged: (val) => setState(() => _monthlyIncome = val),
          ),
          SizedBox(height: 16.h),
          _buildSliderWithInput(
            label: 'Existing Monthly EMIs',
            value: _existingEmi,
            min: 0,
            max: 500000,
            divisions: 100,
            displayValue: _formatCurrency(_existingEmi),
            onChanged: (val) => setState(() => _existingEmi = val),
          ),
          SizedBox(height: 16.h),
          _buildSliderWithInput(
            label: 'Expected Interest Rate (%)',
            value: _interestRate,
            min: 6.0,
            max: 15.0,
            divisions: 90,
            displayValue: '${_interestRate.toStringAsFixed(1)}%',
            onChanged: (val) => setState(() => _interestRate = val),
          ),
          SizedBox(height: 16.h),
          _buildSliderWithInput(
            label: 'Loan Tenure (Years)',
            value: _tenureYears,
            min: 1,
            max: 30,
            divisions: 29,
            displayValue: '${_tenureYears.toInt()} Yrs',
            onChanged: (val) => setState(() => _tenureYears = val),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({required String title, required double amount, required String subtext, required Color color}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 8.h),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(color: Colors.white, fontSize: 36.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Text(subtext, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderWithInput({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required Function(double) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: context.iconColor)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              valueIndicatorColor: Theme.of(context).colorScheme.primary,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatCurrency(min), style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              Text(_formatCurrency(max), style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBreakdown() {
    double principalPercent = _loanAmount / _totalPayment;
    double interestPercent = _totalInterest / _totalPayment;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Breakdown', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.w),
            child: Row(
              children: [
                Expanded(
                  flex: (principalPercent * 100).toInt(),
                  child: Container(height: 20.h, color: Theme.of(context).colorScheme.primary),
                ),
                Expanded(
                  flex: (interestPercent * 100).toInt(),
                  child: Container(height: 20.h, color: Colors.orangeAccent),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildLegendItem(Theme.of(context).colorScheme.primary, 'Principal Amount', '${(principalPercent * 100).toStringAsFixed(1)}%'),
              SizedBox(width: 24.w),
              _buildLegendItem(Colors.orangeAccent, 'Total Interest', '${(interestPercent * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String value) {
    return Row(
      children: [
        Container(width: 12.w, height: 12.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
