import 'package:flutter/material.dart';
import 'package:sampatti_bazar/shared/widgets/app_card.dart';
import 'package:sampatti_bazar/shared/widgets/custom_text_field.dart';
import 'package:sampatti_bazar/shared/widgets/primary_button.dart';

class ConstructionScreen extends StatelessWidget {
  const ConstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text('Construction & Renovation')),
       body: SingleChildScrollView(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Text(
                'Build Your Dream Home',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Get expert civil engineers, map planning, & architecture consultations.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              // Dummy Horizontal List for visual appeal
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFeatureCard(context, 'Map Planning', Icons.map),
                    _buildFeatureCard(context, 'Interior Design', Icons.weekend),
                    _buildFeatureCard(context, 'Civil Work', Icons.construction),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: [
                     Text(
                       'Request a Consultation',
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                     ),
                     const SizedBox(height: 16),
                     const CustomTextField(
                       controller: null,
                       labelText: 'Plot Area (sqft or gaz)',
                     ),
                     const SizedBox(height: 16),
                     const CustomTextField(
                       controller: null,
                       labelText: 'Service Needed (Design/Build)',
                     ),
                     const SizedBox(height: 16),
                     const CustomTextField(
                       controller: null,
                       labelText: 'Budget Estimate (Optional)',
                     ),
                     const SizedBox(height: 24),
                     PrimaryButton(
                       text: 'Request Call Back',
                       onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Consultation request registered!')),
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

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
