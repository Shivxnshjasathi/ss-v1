import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sampatti_bazar/shared/widgets/app_card.dart';
import 'package:sampatti_bazar/shared/widgets/custom_text_field.dart';
import 'package:sampatti_bazar/shared/widgets/primary_button.dart';

class HomeLoanScreen extends StatefulWidget {
  const HomeLoanScreen({super.key});

  @override
  State<HomeLoanScreen> createState() => _HomeLoanScreenState();
}
class _HomeLoanScreenState extends State<HomeLoanScreen> {
  double _amount = 5000000;
  double _rate = 8.5;
  double _tenure = 20;

  double _emi = 0;

  @override
  void initState() {
    super.initState();
    _calculateEmi();
  }

  void _calculateEmi() {
    double p = _amount;
    double r = _rate / 12 / 100;
    double n = _tenure * 12;

    if (p > 0 && r > 0 && n > 0) {
      setState(() {
        _emi = (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
      });
    } else {
      setState(() {
        _emi = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Loans')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Text(
                     'EMI Calculator',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 24),
                   _buildSliderLabel('Loan Amount (₹)', _amount, '1L', '5Cr'),
                   Slider(
                     value: _amount,
                     min: 100000,
                     max: 50000000,
                     onChanged: (val) {
                       setState(() {
                         _amount = val;
                         _calculateEmi();
                       });
                     },
                   ),
                   const SizedBox(height: 16),
                   _buildSliderLabel('Interest Rate (%)', _rate, '5%', '15%'),
                   Slider(
                     value: _rate,
                     min: 5.0,
                     max: 15.0,
                     divisions: 100,
                     onChanged: (val) {
                       setState(() {
                         _rate = val;
                         _calculateEmi();
                       });
                     },
                   ),
                   const SizedBox(height: 16),
                   _buildSliderLabel('Tenure (Years)', _tenure, '1Y', '30Y'),
                   Slider(
                     value: _tenure,
                     min: 1,
                     max: 30,
                     divisions: 29,
                     onChanged: (val) {
                       setState(() {
                         _tenure = val;
                         _calculateEmi();
                       });
                     },
                   ),
                   const SizedBox(height: 24),
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: Theme.of(context).colorScheme.primaryContainer,
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Column(
                       children: [
                         Text('Your Monthly EMI', style: Theme.of(context).textTheme.titleMedium),
                         const SizedBox(height: 8),
                         Text(
                           '₹ ${_emi.toStringAsFixed(0)}',
                           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                 fontWeight: FontWeight.bold,
                                 color: Theme.of(context).colorScheme.primary,
                               ),
                         ),
                       ],
                     ),
                   ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text(
              'Get Loan Offers Fast',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  const CustomTextField(
                    controller: null,
                    labelText: 'Monthly Income (₹)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const CustomTextField(
                    controller: null,
                    labelText: 'Current Employement (Salaried/Business)',
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Check Eligibility',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Eligibility request submitted!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderLabel(String title, double value, String minLabel, String maxLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              title.contains('%') 
                  ? '${value.toStringAsFixed(1)}%' 
                  : title.contains('Years') 
                      ? '${value.toInt()} Yrs' 
                      : '₹${value.toInt()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text(maxLabel, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
