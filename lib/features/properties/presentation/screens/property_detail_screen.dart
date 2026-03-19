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
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
               IconButton(
                 icon: const Icon(Icons.more_horiz, color: Colors.white),
                 onPressed: () {},
                 style: IconButton.styleFrom(
                   backgroundColor: Colors.black.withOpacity(0.4),
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
                           Colors.transparent,
                           Colors.transparent,
                           Colors.black.withOpacity(0.8),
                         ],
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
                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                               decoration: BoxDecoration(
                                 color: const Color(0xFF00E5FF),
                                 borderRadius: BorderRadius.circular(20),
                               ),
                               child: const Text(
                                 'EXCLUSIVE',
                                 style: TextStyle(
                                   color: Colors.black,
                                   fontSize: 10,
                                   fontWeight: FontWeight.w900,
                                   letterSpacing: 0.5,
                                 ),
                               ),
                             ),
                             const SizedBox(width: 8),
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                               decoration: BoxDecoration(
                                 color: Colors.white.withOpacity(0.2),
                                 borderRadius: BorderRadius.circular(20),
                                 border: Border.all(color: Colors.white.withOpacity(0.3)),
                               ),
                               child: const Text(
                                 'VERIFIED',
                                 style: TextStyle(
                                   color: Colors.white,
                                   fontSize: 10,
                                   fontWeight: FontWeight.w900,
                                   letterSpacing: 0.5,
                                 ),
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
                   const Text(
                     'ASKING PRICE',
                     style: TextStyle(
                       color: Color(0xFF00E5FF),
                       fontSize: 12,
                       fontWeight: FontWeight.w900,
                       letterSpacing: 1,
                     ),
                   ),
                   const SizedBox(height: 4),
                   const Text(
                     '\$3,450,000',
                     style: TextStyle(
                       color: Colors.black,
                       fontSize: 36,
                       fontWeight: FontWeight.w900,
                       letterSpacing: -1,
                     ),
                   ),
                   const SizedBox(height: 12),
                   Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF00E5FF)),
                       const SizedBox(width: 8),
                       Expanded(
                         child: Text(
                           '248 Skycrest Drive, Hollywood Hills, Los\nAngeles, CA',
                           style: TextStyle(
                             color: Colors.black87,
                             fontSize: 13,
                             height: 1.4,
                             fontWeight: FontWeight.w600,
                           ),
                         ),
                       ),
                     ],
                   ),
                   
                   const SizedBox(height: 32),
                   
                   Container(
                     decoration: BoxDecoration(
                       border: Border.all(color: Colors.grey[200]!),
                       borderRadius: BorderRadius.circular(2),
                     ),
                     child: IntrinsicHeight(
                       child: Row(
                         children: [
                           Expanded(child: _buildSpecBox('4', 'BEDS', Icons.king_bed_outlined)),
                           VerticalDivider(color: Colors.grey[200], width: 1, thickness: 1),
                           Expanded(child: _buildSpecBox('3.5', 'BATHS', Icons.bathtub_outlined)),
                           VerticalDivider(color: Colors.grey[200], width: 1, thickness: 1),
                           Expanded(child: _buildSpecBox('4,200', 'SQ FT', Icons.aspect_ratio_outlined)),
                         ],
                       ),
                     ),
                   ),

                   const SizedBox(height: 32),
                   
                   const Text(
                     'Architectural Narrative',
                     style: TextStyle(
                       fontSize: 18,
                       fontWeight: FontWeight.w900,
                       letterSpacing: -0.5,
                     ),
                   ),
                   const SizedBox(height: 16),
                   const Text(
                     'A masterwork of modernist architecture. This residence features cantilevered glass wings, floating concrete staircases, and a seamless transition between the indoor gallery spaces and the outdoor canyon vistas. Designed for the discerning collector of space and light.',
                     style: TextStyle(
                       color: Colors.black54,
                       fontSize: 13,
                       height: 1.6,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                   const SizedBox(height: 20),
                   const Text(
                     'READ FULL SPECIFICATION',
                     style: TextStyle(
                       fontSize: 12,
                       fontWeight: FontWeight.w900,
                       letterSpacing: 0.5,
                     ),
                   ),

                   const SizedBox(height: 32),
                   
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: const Color(0xFFF8F9FA),
                       borderRadius: BorderRadius.circular(12),
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
                                 'Elena\nRodriguez',
                                 style: TextStyle(
                                   fontSize: 16,
                                   fontWeight: FontWeight.w900,
                                   height: 1.1,
                                   letterSpacing: -0.5,
                                 ),
                               ),
                               const SizedBox(height: 6),
                               Text(
                                 'Prime Listings Expert',
                                 style: TextStyle(
                                   fontSize: 11,
                                   color: Colors.grey[600],
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                             ],
                           ),
                         ),
                         Container(
                           decoration: BoxDecoration(
                             color: Colors.white,
                             shape: BoxShape.circle,
                             border: Border.all(color: Colors.grey[200]!),
                           ),
                           child: IconButton(
                             icon: const Icon(Icons.chat_bubble_outline, size: 20),
                             onPressed: () {},
                             color: Colors.black54,
                             constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                             padding: EdgeInsets.zero,
                           ),
                         ),
                         const SizedBox(width: 12),
                         Container(
                           decoration: BoxDecoration(
                             color: Colors.white,
                             shape: BoxShape.circle,
                             border: Border.all(color: Colors.grey[200]!),
                           ),
                           child: IconButton(
                             icon: const Icon(Icons.phone_outlined, size: 20),
                             onPressed: () {},
                             color: Colors.black54,
                             constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                             padding: EdgeInsets.zero,
                           ),
                         ),
                       ],
                     ),
                   ),

                   const SizedBox(height: 32),
                   
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text(
                         'Location Intelligence',
                         style: TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.w900,
                           letterSpacing: -0.5,
                         ),
                       ),
                       Row(
                         children: [
                           const Text(
                             '98 WALK SCORE',
                             style: TextStyle(
                               color: Color(0xFF00E5FF),
                               fontSize: 10,
                               fontWeight: FontWeight.w900,
                               letterSpacing: 0.5,
                             ),
                           ),
                           const SizedBox(width: 4),
                           const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF00E5FF)),
                         ],
                       ),
                     ],
                   ),
                   const SizedBox(height: 20),
                   
                   Container(
                     height: 160,
                     decoration: BoxDecoration(
                       color: Colors.grey[200],
                       borderRadius: BorderRadius.circular(4),
                     ),
                     clipBehavior: Clip.antiAlias,
                     child: Stack(
                       fit: StackFit.expand,
                       children: [
                         Image.network(
                           'https://images.unsplash.com/photo-1524661135-423995f22d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                           fit: BoxFit.cover,
                         ),
                         Center(
                           child: Container(
                             width: 40,
                             height: 40,
                             decoration: BoxDecoration(
                               color: const Color(0xFF00E5FF).withOpacity(0.9),
                               shape: BoxShape.circle,
                             ),
                             child: const Center(
                               child: Icon(Icons.near_me_outlined, color: Colors.black, size: 20),
                             ),
                           ),
                         ),
                         Positioned(
                           bottom: 16,
                           left: 16,
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(2),
                             ),
                             child: const Text(
                               'SILVER LAKE NEIGHBORHOOD',
                               style: TextStyle(
                                 fontSize: 9,
                                 fontWeight: FontWeight.w900,
                                 letterSpacing: 0.5,
                                 color: Colors.black,
                               ),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),

                   const SizedBox(height: 20),
                   
                   Row(
                     children: [
                       Expanded(
                         child: Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: const Color(0xFFF8F9FA),
                             borderRadius: BorderRadius.circular(4),
                             border: Border.all(color: Colors.grey[200]!),
                           ),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey[600]),
                               const SizedBox(height: 12),
                               const Text(
                                 'BUILT IN',
                                 style: TextStyle(
                                   fontSize: 9,
                                   fontWeight: FontWeight.w900,
                                   color: Colors.black54,
                                   letterSpacing: 0.5,
                                 ),
                               ),
                               const SizedBox(height: 4),
                               const Text(
                                 '2023',
                                 style: TextStyle(
                                   fontSize: 16,
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
                             color: const Color(0xFFF8F9FA),
                             borderRadius: BorderRadius.circular(4),
                             border: Border.all(color: Colors.grey[200]!),
                           ),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Icon(Icons.aspect_ratio_outlined, size: 18, color: Colors.grey[600]),
                               const SizedBox(height: 12),
                               const Text(
                                 'LOT SIZE',
                                 style: TextStyle(
                                   fontSize: 9,
                                   fontWeight: FontWeight.w900,
                                   color: Colors.black54,
                                   letterSpacing: 0.5,
                                 ),
                               ),
                               const SizedBox(height: 4),
                               const Text(
                                 '12,450 SF',
                                 style: TextStyle(
                                   fontSize: 16,
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
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _scheduleTour(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'BOOK VISIT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
