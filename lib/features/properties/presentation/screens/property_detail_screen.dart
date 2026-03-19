import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sampatti_bazar/shared/widgets/primary_button.dart';

class PropertyDetailScreen extends StatelessWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.3),
              ),
            ),
            actions: [
               IconButton(
                 icon: const Icon(Icons.share, color: Colors.white),
                 onPressed: () {},
                 style: IconButton.styleFrom(
                   backgroundColor: Colors.black.withOpacity(0.3),
                 ),
               ),
               IconButton(
                 icon: const Icon(Icons.favorite_border, color: Colors.white),
                 onPressed: () {},
                 style: IconButton.styleFrom(
                   backgroundColor: Colors.black.withOpacity(0.3),
                 ),
               ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey[400],
                child: const Center(
                  child: Icon(Icons.image, size: 80, color: Colors.white),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         '₹ 18,000 / month',
                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                               fontWeight: FontWeight.bold,
                               color: Theme.of(context).colorScheme.primary,
                             ),
                       ),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           color: Colors.green.shade100,
                           borderRadius: BorderRadius.circular(20),
                         ),
                         child: const Text(
                           'No Brokerage',
                           style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 8),
                   Text(
                     '2 BHK Flat In HSR Layout',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                           fontWeight: FontWeight.w600,
                         ),
                   ),
                   const SizedBox(height: 4),
                   Row(
                     children: [
                       Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                       const SizedBox(width: 4),
                       Expanded(
                         child: Text(
                           'Sector 2, HSR Layout, Bengaluru',
                           style: TextStyle(color: Colors.grey[600]),
                         ),
                       ),
                     ],
                   ),
                   
                   const SizedBox(height: 24),
                   // Grid Specs
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       _buildSpecItem(context, 'Area', '1000 sqft', Icons.square_foot),
                       _buildSpecItem(context, 'Furnishing', 'Semi', Icons.chair),
                       _buildSpecItem(context, 'Deposit', '₹ 1.0 L', Icons.account_balance_wallet),
                       _buildSpecItem(context, 'Available', 'Imm.', Icons.calendar_today),
                     ],
                   ),

                   const SizedBox(height: 24),
                   const Divider(),
                   const SizedBox(height: 16),
                   Text(
                     'Description',
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 8),
                   const Text(
                     'A beautiful 2 BHK semi-furnished flat available for rent in HSR Layout. It has 2 bathrooms, 1 balcony, and reserved parking. North facing and Vastu compliant.',
                   ),

                   const SizedBox(height: 24),
                   Text(
                     'Location Details',
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 16),
                   // Fake Google Map View
                   Container(
                     height: 200,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(color: Colors.grey.shade300),
                     ),
                     clipBehavior: Clip.antiAlias,
                     child: const GoogleMap(
                       initialCameraPosition: CameraPosition(
                         target: LatLng(12.9141, 77.6308), // HSR Layout
                         zoom: 14,
                       ),
                       zoomControlsEnabled: false,
                     ),
                   ),

                   const SizedBox(height: 100), // Space for bottom sheet/button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  text: 'Schedule Tour',
                  onPressed: () => _scheduleTour(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scheduleTour(BuildContext context) async {
    final date = await showDatePicker(
             context: context,
             initialDate: DateTime.now().add(const Duration(days: 1)),
             firstDate: DateTime.now(),
             lastDate: DateTime.now().add(const Duration(days: 30)),
           );
    if (date == null) return;
    if (!context.mounted) return;
    final time = await showTimePicker(
             context: context,
             initialTime: const TimeOfDay(hour: 10, minute: 0),
           );
    if (time == null) return;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Tour Scheduled for ${date.day}/${date.month} at ${time.format(context)}'))
           );
  }

  Widget _buildSpecItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
      ],
    );
  }
}
