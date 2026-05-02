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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Rent vs Buy State
  double _rentAmount = 25000;
  double _buyPrice = 6000000;
  double _appreciationRate = 6.0;
  double _investmentReturn = 10.0;

  // Tax State
  double _annualInterestPaid = 350000;
  double _annualPrincipalPaid = 150000;
  double _taxBracket = 30.0;

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

  // Tax Logic
  double get _interestDeduction => min(_annualInterestPaid, 200000); // Section 24
  double get _principalDeduction => min(_annualPrincipalPaid, 150000); // Section 80C
  double get _totalTaxSaved => (_interestDeduction + _principalDeduction) * (_taxBracket / 100);

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
        title: Text(l10n.services, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'EMI Calc', icon: Icon(Icons.calculate)),
            Tab(text: 'Eligibility', icon: Icon(Icons.verified_user)),
            Tab(text: 'Rent vs Buy', icon: Icon(Icons.compare_arrows)),
            Tab(text: 'Tax Planner', icon: Icon(Icons.savings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEmiCalculator(context),
          _buildEligibilityChecker(context),
          _buildRentVsBuy(context),
          _buildTaxPlanner(context),
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
          colors: [color.withValues(alpha: 0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
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
              color: Colors.white.withValues(alpha: 0.2),
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
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
              inactiveTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
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

  Widget _buildRentVsBuy(BuildContext context) {
    // Sophisticated 10-year projection logic
    // We compare buying a house vs renting and investing the down payment
    double downPayment = _buyPrice * 0.20; 
    double totalRentPaid = _rentAmount * 12 * 10;
    
    // Future value of the house
    double projectedHouseValue = _buyPrice * pow(1 + (_appreciationRate / 100), 10);
    double appreciationGain = projectedHouseValue - _buyPrice;
    
    // Opportunity cost: What if you invested the down payment instead?
    double investmentGains = downPayment * (pow(1 + (_investmentReturn / 100), 10) - 1);
    
    double netBuyWealth = appreciationGain;
    double netRentWealth = investmentGains - totalRentPaid;

    bool buyingWins = netBuyWealth > netRentWealth;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultCard(
            title: '10-Year Wealth Difference',
            amount: (netBuyWealth - netRentWealth).abs(),
            subtext: buyingWins ? 'Buying is mathematically better' : 'Renting & Investing is better',
            color: buyingWins ? Colors.indigo : Colors.deepOrange,
          ),
          SizedBox(height: 24.h),
          _buildSliderWithInput(
            label: 'Current Monthly Rent',
            value: _rentAmount,
            min: 5000,
            max: 200000,
            divisions: 195,
            displayValue: _formatCurrency(_rentAmount),
            onChanged: (val) => setState(() => _rentAmount = val),
          ),
          SizedBox(height: 16.h),
          _buildSliderWithInput(
            label: 'Property Purchase Price',
            value: _buyPrice,
            min: 1000000,
            max: 100000000,
            divisions: 99,
            displayValue: _formatCurrency(_buyPrice),
            onChanged: (val) => setState(() => _buyPrice = val),
          ),
          SizedBox(height: 16.h),
          _buildSliderWithInput(
            label: 'Annual Appreciation (%)',
            value: _appreciationRate,
            min: 1.0,
            max: 15.0,
            divisions: 140,
            displayValue: '${_appreciationRate.toStringAsFixed(1)}%',
            onChanged: (val) => setState(() => _appreciationRate = val),
          ),
          SizedBox(height: 16.h),
          _buildSliderWithInput(
            label: 'Invest. Return (Opportunity Cost)',
            value: _investmentReturn,
            min: 1.0,
            max: 20.0,
            divisions: 190,
            displayValue: '${_investmentReturn.toStringAsFixed(1)}%',
            onChanged: (val) => setState(() => _investmentReturn = val),
          ),
          SizedBox(height: 32.h),
          Text('Market Assumptions', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text('This analysis assumes a 20% down payment (₹${_formatCurrency(downPayment)}) which is either used to buy the house or invested in the market at ${_investmentReturn.toStringAsFixed(1)}% annual return.', 
               style: TextStyle(fontSize: 12.sp, color: Colors.grey, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildTaxPlanner(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultCard(
            title: 'Annual Tax Savings',
            amount: _totalTaxSaved,
            subtext: 'Potential savings under Section 24 & 80C',
            color: Colors.teal,
          ),
          SizedBox(height: 24.h),
          _buildSliderWithInput(
            label: 'Annual Interest Paid',
            value: _annualInterestPaid,
            min: 0,
            max: 1000000,
            divisions: 100,
            displayValue: _formatCurrency(_annualInterestPaid),
            onChanged: (val) => setState(() => _annualInterestPaid = val),
          ),
          SizedBox(height: 16.h),
          _buildSliderWithInput(
            label: 'Annual Principal Repaid',
            value: _annualPrincipalPaid,
            min: 0,
            max: 500000,
            divisions: 100,
            displayValue: _formatCurrency(_annualPrincipalPaid),
            onChanged: (val) => setState(() => _annualPrincipalPaid = val),
          ),
          SizedBox(height: 16.h),
          _buildSliderWithInput(
            label: 'Your Tax Bracket (%)',
            value: _taxBracket,
            min: 5,
            max: 30,
            divisions: 5,
            displayValue: '${_taxBracket.toInt()}%',
            onChanged: (val) => setState(() => _taxBracket = val),
          ),
          SizedBox(height: 32.h),
          _buildTaxBreakdownCard(),
        ],
      ),
    );
  }

  Widget _buildTaxBreakdownCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          _buildTaxRow('Sec 24 (Interest)', _interestDeduction, 200000),
          Divider(height: 24.h),
          _buildTaxRow('Sec 80C (Principal)', _principalDeduction, 150000),
        ],
      ),
    );
  }

  Widget _buildTaxRow(String label, double deduction, double limit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            Text('Limit: ${_formatCurrency(limit)}', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
          ],
        ),
        Text('Eligible: ${_formatCurrency(deduction)}', style: TextStyle(fontSize: 14.sp, color: Colors.green, fontWeight: FontWeight.bold)),
      ],
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
