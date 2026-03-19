import 'package:flutter/material.dart';
import 'package:sampatti_bazar/shared/widgets/app_card.dart';
import 'package:sampatti_bazar/shared/widgets/custom_text_field.dart';
import 'package:sampatti_bazar/shared/widgets/primary_button.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text('Legal Services')),
       body: SingleChildScrollView(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
              Text(
                'Draft Rent Agreements\n& Legal Consultations',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate standard PDF rent agreement drafts in minutes.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: [
                     const Text('Property Details', style: TextStyle(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 16),
                     const CustomTextField(
                       controller: null,
                       labelText: 'Complete Address',
                     ),
                     const SizedBox(height: 16),
                     const Row(
                       children: [
                         Expanded(
                           child: CustomTextField(
                             controller: null,
                             labelText: 'Rent Amt (₹)',
                             keyboardType: TextInputType.number,
                           ),
                         ),
                         SizedBox(width: 16),
                         Expanded(
                           child: CustomTextField(
                             controller: null,
                             labelText: 'Deposit (₹)',
                             keyboardType: TextInputType.number,
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 24),
                     const Text('Parties Involved', style: TextStyle(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 16),
                     const CustomTextField(
                       controller: null,
                       labelText: 'Landlord Name',
                     ),
                     const SizedBox(height: 16),
                     const CustomTextField(
                       controller: null,
                       labelText: 'Tenant Name',
                     ),
                     const SizedBox(height: 24),
                     PrimaryButton(
                       text: 'Generate Draft PDF',
                       onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Draft PDF Generated!')),
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
