import 'package:flutter/material.dart';
import 'package:sampatti_bazar/shared/widgets/app_card.dart';
import 'package:sampatti_bazar/shared/widgets/custom_text_field.dart';
import 'package:sampatti_bazar/shared/widgets/primary_button.dart';

class MoversScreen extends StatelessWidget {
  const MoversScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text('Movers & Packers')),
       body: SingleChildScrollView(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Text(
                'Book Trusted Movers',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Safe, secure, and hassle-free relocation services.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                   children: [
                     const CustomTextField(
                       controller: null,
                       labelText: 'Pickup Location',
                       prefixIcon: Icon(Icons.my_location),
                     ),
                     const SizedBox(height: 16),
                     const CustomTextField(
                       controller: null,
                       labelText: 'Drop Location',
                       prefixIcon: Icon(Icons.location_on),
                     ),
                     const SizedBox(height: 16),
                     const CustomTextField(
                       controller: null,
                       labelText: 'Moving Date (DD/MM/YYYY)',
                       prefixIcon: Icon(Icons.calendar_today),
                     ),
                     const SizedBox(height: 16),
                     const CustomTextField(
                       controller: null,
                       labelText: 'House Size (1 BHK, 2 BHK, etc.)',
                       prefixIcon: Icon(Icons.home),
                     ),
                     const SizedBox(height: 24),
                     PrimaryButton(
                       text: 'Get Quotes',
                       onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request sent to partners!')),
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
