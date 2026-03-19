import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class HomeLoanScreen extends StatefulWidget {
  const HomeLoanScreen({super.key});

  @override
  State<HomeLoanScreen> createState() => _HomeLoanScreenState();
}

class _HomeLoanScreenState extends State<HomeLoanScreen> {
  double loanAmount = 5000000;
  double tenure = 20;
  double interestRate = 8.5;

  String _formatCurrency(num amount) {
    String text = amount.toStringAsFixed(0);
    text = text.replaceAllMapped(RegExp(r'(\d)(?=(\d\d)+\d$)'), (Match m) => '${m[1]},');
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E60FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text('Finance', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EMI Calculator', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              'Plan your property investment with our hyper-precise financial engine.',
              style: TextStyle(color: Colors.grey[700], fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildSliderCard(
              icon: Icons.attach_money,
              label: 'LOAN AMOUNT',
              valueText: '${_formatCurrency(loanAmount)}',
              minLabel: '₹1,00,000',
              maxLabel: '₹1,00,00,000',
              value: loanAmount,
              min: 100000,
              max: 10000000,
              onChanged: (val) => setState(() => loanAmount = val),
            ),
            const SizedBox(height: 16),
            _buildSliderCard(
              icon: Icons.calendar_today,
              label: 'TENURE',
              valueText: '${tenure.toInt()} YEARS',
              minLabel: '1 YR',
              maxLabel: '30 YRS',
              value: tenure,
              min: 1,
              max: 30,
              onChanged: (val) => setState(() => tenure = val),
            ),
            const SizedBox(height: 16),
            _buildSliderCard(
              icon: Icons.percent,
              label: 'INTEREST RATE',
              valueText: '${interestRate.toStringAsFixed(1)} %',
              minLabel: '5 %',
              maxLabel: '15 %',
              value: interestRate,
              min: 5,
              max: 15,
              onChanged: (val) => setState(() => interestRate = val),
            ),
            const SizedBox(height: 32),
            _buildSummaryCard(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E60FF),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text('Check Eligibility', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'SUBJECT TO TERMS AND CONDITIONS. POWERED BY SAMPATTI FINANCE.',
                style: TextStyle(fontSize: 8, color: Colors.grey[500], fontWeight: FontWeight.bold, letterSpacing: 0.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.black54),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              const Spacer(),
              Text(valueText, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              activeTrackColor: const Color(0xFF1E60FF),
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF1E60FF).withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 4),
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
              Text(minLabel, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text(maxLabel, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ESTIMATED MONTHLY EMI', style: TextStyle(color: Color(0xFF1E60FF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatCurrency(_emi), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, height: 1)),
              const SizedBox(width: 12),
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1E60FF)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('LOW RATE', style: TextStyle(color: Color(0xFF1E60FF), fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL INTEREST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(_formatCurrency(_totalInterest), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL PAYABLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(_formatCurrency(_totalPayable), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF1E60FF).withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.pie_chart_outline, size: 16, color: Color(0xFF1E60FF)),
                SizedBox(width: 8),
                Text('View Repayment Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Spacer(),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
