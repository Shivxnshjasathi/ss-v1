import 'package:flutter/material.dart';
import 'package:sampatti_bazar/shared/widgets/custom_text_field.dart';
import 'package:sampatti_bazar/shared/widgets/primary_button.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal Services')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Draft PDF Generated! Downloading...')),
            );
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          final isLastStep = _currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    onPressed: details.onStepContinue ?? () {},
                    text: isLastStep ? 'Generate PDF' : 'Continue',
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel ?? () {},
                      child: const Text('Back'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            isActive: _currentStep >= 0,
            title: const Text('Property Details'),
            content: const Column(
              children: [
                CustomTextField(controller: null, labelText: 'Complete Address'),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: CustomTextField(controller: null, labelText: 'Rent Amt (₹)', keyboardType: TextInputType.number)),
                    SizedBox(width: 16),
                    Expanded(child: CustomTextField(controller: null, labelText: 'Deposit (₹)', keyboardType: TextInputType.number)),
                  ],
                ),
              ],
            ),
          ),
          Step(
            isActive: _currentStep >= 1,
            title: const Text('Parties Involved'),
            content: const Column(
              children: [
                CustomTextField(controller: null, labelText: 'Landlord Full Name'),
                SizedBox(height: 16),
                CustomTextField(controller: null, labelText: 'Tenant Full Name'),
              ],
            ),
          ),
          Step(
            isActive: _currentStep >= 2,
            title: const Text('Agreement Terms'),
            content: const Column(
              children: [
                CustomTextField(controller: null, labelText: 'Duration (Months)', keyboardType: TextInputType.number),
                SizedBox(height: 16),
                CustomTextField(controller: null, labelText: 'Notice Period (Months)', keyboardType: TextInputType.number),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
