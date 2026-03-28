import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PropertyDetailScreen extends StatelessWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
               IconButton(
                 icon: const Icon(Icons.favorite_border, color: Colors.white),
                 onPressed: () {},
                 style: IconButton.styleFrom(
                   backgroundColor: Colors.black.withValues(alpha: 0.3),
                   minimumSize: const Size(40, 40),
                 ),
               ),
               const SizedBox(width: 8),
               IconButton(
                 icon: const Icon(Icons.share_outlined, color: Colors.white),
                 onPressed: () {},
                 style: IconButton.styleFrom(
                   backgroundColor: Colors.black.withValues(alpha: 0.3),
                   minimumSize: const Size(40, 40),
                 ),
               ),
               const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                   Image.network(
                     'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                     fit: BoxFit.cover,
                   ),
                   Container(
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         begin: Alignment.topCenter,
                         end: Alignment.bottomCenter,
                         colors: [
                           Colors.black.withValues(alpha: 0.4),
                           Colors.transparent,
                           Colors.transparent,
                           Colors.black.withValues(alpha: 0.8),
                         ],
                         stops: const [0.0, 0.2, 0.6, 1.0],
                       ),
                     ),
                   ),
                   Positioned(
                     bottom: 24,
                     left: 20,
                     right: 20,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                               decoration: BoxDecoration(
                                 color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               child: const Row(
                                 children: [
                                   Icon(Icons.star, color: Colors.white, size: 12),
                                   SizedBox(width: 4),
                                   Text(
                                     'EXCLUSIVE',
                                     style: TextStyle(
                                       color: Colors.white,
                                       fontSize: 10,
                                       fontWeight: FontWeight.w900,
                                       letterSpacing: 0.5,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                             const SizedBox(width: 8),
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                               decoration: BoxDecoration(
                                 color: Colors.white.withValues(alpha: 0.95),
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                               ),
                               child: Row(
                                 children: [
                                   Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 12),
                                   const SizedBox(width: 4),
                                   const Text(
                                     'VERIFIED',
                                     style: TextStyle(
                                       color: Colors.black87,
                                       fontSize: 10,
                                       fontWeight: FontWeight.w900,
                                       letterSpacing: 0.5,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 12),
                         const Text(
                           'The Glass Pavilion',
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: 28,
                             fontWeight: FontWeight.w900,
                             letterSpacing: -0.5,
                           ),
                         ),
                       ],
                     ),
                   ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     'ASKING PRICE',
                     style: TextStyle(
                       color: Colors.grey.shade500,
                       fontSize: 12,
                       fontWeight: FontWeight.bold,
                       letterSpacing: 1,
                     ),
                   ),
                   const SizedBox(height: 4),
                   Text(
                     '\$3,450,000',
                     style: TextStyle(
                       color: Theme.of(context).colorScheme.primary,
                       fontSize: 36,
                       fontWeight: FontWeight.w900,
                       letterSpacing: -1,
                     ),
                   ),
                   const SizedBox(height: 12),
                   Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Icon(Icons.location_on, size: 20, color: Colors.grey.shade500),
                       const SizedBox(width: 8),
                       const Expanded(
                         child: Text(
                           '248 Skycrest Drive, Hollywood Hills, Los\nAngeles, CA',
                           style: TextStyle(
                             color: Colors.black87,
                             fontSize: 14,
                             height: 1.4,
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                       ),
                     ],
                   ),
                   
                   const SizedBox(height: 32),
                   
                   Container(
                     decoration: BoxDecoration(
                       color: Colors.grey.shade50,
                       border: Border.all(color: Colors.grey.shade200),
                       borderRadius: BorderRadius.circular(12),
                     ),
                     padding: const EdgeInsets.symmetric(vertical: 20),
                     child: IntrinsicHeight(
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         children: [
                           _buildSpecBox('4', 'BEDS', Icons.king_bed_outlined),
                           VerticalDivider(color: Colors.grey[300], width: 1, thickness: 1),
                           _buildSpecBox('3.5', 'BATHS', Icons.bathtub_outlined),
                           VerticalDivider(color: Colors.grey[300], width: 1, thickness: 1),
                           _buildSpecBox('4,200', 'SQ FT', Icons.square_foot_outlined),
                         ],
                       ),
                     ),
                   ),

                   const SizedBox(height: 32),
                   
                   const Text(
                     'Architectural Narrative',
                     style: TextStyle(
                       fontSize: 20,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   const SizedBox(height: 16),
                   const Text(
                     'A masterwork of modernist architecture. This residence features cantilevered glass wings, floating concrete staircases, and a seamless transition between the indoor gallery spaces and the outdoor canyon vistas. Designed for the discerning collector of space and light.',
                     style: TextStyle(
                       color: Colors.black87,
                       fontSize: 14,
                       height: 1.6,
                       fontWeight: FontWeight.w400,
                     ),
                   ),
                   const SizedBox(height: 16),
                   Text(
                     'Read Full Specification',
                     style: TextStyle(
                       fontSize: 14,
                       color: Theme.of(context).colorScheme.primary,
                       fontWeight: FontWeight.bold,
                     ),
                   ),

                   const SizedBox(height: 32),
                   
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(12),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withValues(alpha: 0.04),
                           blurRadius: 10,
                           offset: const Offset(0, 4),
                         )
                       ],
                       border: Border.all(color: Colors.grey.shade100),
                     ),
                     child: Row(
                       children: [
                         Stack(
                           children: [
                             const CircleAvatar(
                               radius: 26,
                               backgroundImage: NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'),
                             ),
                             Positioned(
                               bottom: 2,
                               right: 2,
                               child: Container(
                                 width: 12,
                                 height: 12,
                                 decoration: BoxDecoration(
                                   color: Colors.greenAccent[400],
                                   shape: BoxShape.circle,
                                   border: Border.all(color: Colors.white, width: 2),
                                 ),
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Text(
                                 'Elena Rodriguez',
                                 style: TextStyle(
                                   fontSize: 16,
                                   fontWeight: FontWeight.w900,
                                   height: 1.1,
                                 ),
                               ),
                               const SizedBox(height: 6),
                               Text(
                                 'Prime Listings Expert',
                                 style: TextStyle(
                                   fontSize: 12,
                                   color: Colors.grey[600],
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),
                             ],
                           ),
                         ),
                         Container(
                           decoration: BoxDecoration(
                             color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                             shape: BoxShape.circle,
                           ),
                           child: IconButton(
                             icon: Icon(Icons.chat_bubble, size: 20, color: Theme.of(context).colorScheme.primary),
                             onPressed: () {},
                             constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                             padding: EdgeInsets.zero,
                           ),
                         ),
                         const SizedBox(width: 12),
                         Container(
                           decoration: BoxDecoration(
                             color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                             shape: BoxShape.circle,
                           ),
                           child: IconButton(
                             icon: Icon(Icons.phone, size: 20, color: Theme.of(context).colorScheme.primary),
                             onPressed: () {},
                             constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                             padding: EdgeInsets.zero,
                           ),
                         ),
                       ],
                     ),
                   ),

                   // Removed Location Intelligence Section entirely

                   const SizedBox(height: 32),
                   
                   const Text(
                     'Property Information',
                     style: TextStyle(
                       fontSize: 20,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   const SizedBox(height: 16),
                   Row(
                     children: [
                       Expanded(
                         child: Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: Colors.grey.shade50,
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: Colors.grey.shade200),
                           ),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Icon(Icons.calendar_month_outlined, size: 24, color: Theme.of(context).colorScheme.primary),
                               const SizedBox(height: 12),
                               Text(
                                 'BUILT IN',
                                 style: TextStyle(
                                   fontSize: 10,
                                   fontWeight: FontWeight.bold,
                                   color: Colors.grey.shade600,
                                   letterSpacing: 0.5,
                                 ),
                               ),
                               const SizedBox(height: 4),
                               const Text(
                                 '2023',
                                 style: TextStyle(
                                   fontSize: 18,
                                   fontWeight: FontWeight.w900,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: Colors.grey.shade50,
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: Colors.grey.shade200),
                           ),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Icon(Icons.open_with_outlined, size: 24, color: Theme.of(context).colorScheme.primary),
                               const SizedBox(height: 12),
                               Text(
                                 'LOT SIZE',
                                 style: TextStyle(
                                   fontSize: 10,
                                   fontWeight: FontWeight.bold,
                                   color: Colors.grey.shade600,
                                   letterSpacing: 0.5,
                                 ),
                               ),
                               const SizedBox(height: 4),
                               const Text(
                                 '12,450 SF',
                                 style: TextStyle(
                                   fontSize: 18,
                                   fontWeight: FontWeight.w900,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _scheduleTour(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Book a Visit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
      SnackBar(content: Text('Visit Scheduled for ${date.day}/${date.month} at ${time.format(context)}'))
    );
  }

  Widget _buildSpecBox(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 24),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
