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
  final _amountController = TextEditingController(text: '5000000');
  final _rateController = TextEditingController(text: '8.5');
  final _tenureController = TextEditingController(text: '20');

  double _emi = 0;

  @override
  void initState() {
    super.initState();
    _calculateEmi();
  }

  void _calculateEmi() {
    double p = double.tryParse(_amountController.text) ?? 0;
    double r = (double.tryParse(_rateController.text) ?? 0) / 12 / 100;
    double n = (double.tryParse(_tenureController.text) ?? 0) * 12;

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
                   const SizedBox(height: 16),
                   CustomTextField(
                     controller: _amountController,
                     labelText: 'Loan Amount (₹)',
                     keyboardType: TextInputType.number,
                   ),
                   const SizedBox(height: 16),
                   Row(
                     children: [
                       Expanded(
                         child: CustomTextField(
                           controller: _rateController,
                           labelText: 'Interest Rate (%)',
                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: CustomTextField(
                           controller: _tenureController,
                           labelText: 'Tenure (Years)',
                           keyboardType: TextInputType.number,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   PrimaryButton(text: 'Calculate', onPressed: _calculateEmi),
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
}
