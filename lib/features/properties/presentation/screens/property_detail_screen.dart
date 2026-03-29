import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/features/services/data/booking_repository.dart';
import 'package:sampatti_bazar/features/services/domain/booking_model.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:sampatti_bazar/features/chat/data/chat_repository.dart';

class PropertyDetailScreen extends ConsumerWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertiesStreamProvider);
    
    return propertiesAsync.when(
      data: (properties) {
        final propertyIdx = properties.indexWhere((p) => p.id == propertyId);
        if (propertyIdx == -1) {
          return const Scaffold(body: Center(child: Text('Property not found')));
        }
        final property = properties[propertyIdx];
        final ownerAsync = ref.watch(userProfileProvider(property.ownerId));
        final currentUser = ref.watch(currentUserDataProvider).value;
        final isSavedAsync = currentUser != null 
            ? ref.watch(isPropertySavedProvider((userId: currentUser.uid, propertyId: propertyId)))
            : const AsyncValue.data(false);

        return Scaffold(
          backgroundColor: context.scaffoldColor,
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
                 icon: Icon(
                   isSavedAsync.value == true ? Icons.favorite : Icons.favorite_border, 
                   color: isSavedAsync.value == true ? Colors.red : Colors.white
                 ),
                 onPressed: () async {
                   if (currentUser == null) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to save properties')));
                     return;
                   }
                   await ref.read(propertyRepositoryProvider).toggleSaveProperty(currentUser.uid, propertyId);
                   LoggerService.trackEvent(
                     isSavedAsync.value == true ? 'property_unsaved' : 'property_saved',
                     parameters: {
                       'property_id': propertyId,
                       'property_title': property.title,
                     },
                   );
                 },
                 style: IconButton.styleFrom(
                   backgroundColor: Colors.black.withValues(alpha: 0.3),
                   minimumSize: const Size(40, 40),
                 ),
               ),
               const SizedBox(width: 8),
               IconButton(
                 icon: const Icon(Icons.share_outlined, color: Colors.white),
                 onPressed: () {
                   Share.share(
                     'Check out this property on Sampatti Bazar: ${property.title} in ${property.city} for ₹${property.price.toInt()}.',
                     subject: 'Property Shared: ${property.title}',
                   );
                   LoggerService.trackEvent('property_shared', parameters: {
                     'property_id': propertyId,
                     'property_title': property.title,
                   });
                 },
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
                   CachedNetworkImage(
                     imageUrl: property.imageUrls.isNotEmpty 
                        ? property.imageUrls.first 
                        : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                     fit: BoxFit.cover,
                     memCacheHeight: 600,
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
                             if (property.isZeroBrokerage)
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
                                       '0 BROKERAGE',
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
                             if (property.isZeroBrokerage && property.isVerified)
                               const SizedBox(width: 8),
                             if (property.isVerified)
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
                         Text(
                           property.title,
                           style: const TextStyle(
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
                    property.title.split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '').join(' '),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: context.primaryTextColor, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.primaryBlue, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${property.location.toUpperCase()[0]}${property.location.substring(1).toLowerCase()}, ${property.city.toUpperCase()[0]}${property.city.substring(1).toLowerCase()}',
                        style: TextStyle(color: context.secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.isDarkMode ? Colors.grey[900]?.withValues(alpha: 0.5) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ASKING PRICE', style: TextStyle(color: context.secondaryTextColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text('₹${property.price.toInt()}', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 26, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: context.borderColor),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('TOTAL AREA', style: TextStyle(color: context.secondaryTextColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(text: property.areaSqFt.toInt().toString(), style: TextStyle(color: context.primaryTextColor, fontSize: 22, fontWeight: FontWeight.w900)),
                                  TextSpan(text: ' SQ FT', style: TextStyle(color: context.secondaryTextColor, fontSize: 10, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                   
                   const SizedBox(height: 32),
                   Text('OVERVIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.secondaryTextColor, letterSpacing: 1.5)),
                   const SizedBox(height: 16),
                   _buildOverviewGrid(context, property),
                   
                   const SizedBox(height: 32),
                   Text('AMENITIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.secondaryTextColor, letterSpacing: 1.5)),
                   const SizedBox(height: 16),
                   _buildAmenities(context, property.amenities),
                   
                   const SizedBox(height: 32),
                   
                   const Text(
                     'Property Description',
                     style: TextStyle(
                       fontSize: 20,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   const SizedBox(height: 16),
                     Text(
                       property.description.isNotEmpty ? property.description : 'No description provided for this listing.',
                       style: TextStyle(
                         color: context.secondaryTextColor,
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
                   Text('LOCATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.secondaryTextColor, letterSpacing: 1.5)),
                   const SizedBox(height: 16),
                   Container(
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(
                       color: context.cardColor,
                       borderRadius: BorderRadius.circular(24),
                       border: Border.all(color: context.borderColor),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                 borderRadius: BorderRadius.circular(16),
                               ),
                               child: const Icon(Icons.location_on, color: AppTheme.primaryBlue, size: 24),
                             ),
                             const SizedBox(width: 16),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(
                                     property.city.isNotEmpty ? (property.city[0].toUpperCase() + property.city.substring(1).toLowerCase()) : 'Location',
                                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: context.primaryTextColor),
                                   ),
                                   const SizedBox(height: 2),
                                   Text(
                                     property.location,
                                     style: TextStyle(fontSize: 13, color: context.secondaryTextColor, fontWeight: FontWeight.w500),
                                     maxLines: 2,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ],
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 24),
                         SizedBox(
                           width: double.infinity,
                           child: OutlinedButton.icon(
                             onPressed: () async {
                               final query = Uri.encodeComponent('${property.location}, ${property.city}');
                               final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                               if (await canLaunchUrl(url)) {
                                 await launchUrl(url);
                               }
                             },
                             icon: const Icon(Icons.directions_outlined, size: 20),
                             label: const Text('GET DIRECTIONS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                             style: OutlinedButton.styleFrom(
                               padding: const EdgeInsets.symmetric(vertical: 16),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                               side: BorderSide(color: context.borderColor),
                               foregroundColor: AppTheme.primaryBlue,
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),

                   const SizedBox(height: 32),
                   
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: context.cardColor,
                       borderRadius: BorderRadius.circular(12),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withValues(alpha: 0.04),
                           blurRadius: 10,
                           offset: const Offset(0, 4),
                         )
                       ],
                       border: Border.all(color: context.borderColor),
                     ),
                     child: ownerAsync.when(
                        data: (owner) => Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  backgroundImage: (owner?.phoneNumber != null && owner!.phoneNumber.isNotEmpty)
                                      ? NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(owner.name ?? 'User')}&background=random&size=128')
                                      : const NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'),
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
                                  Text(
                                    owner?.name ?? 'Loading...',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: context.primaryTextColor),
                                  ),
                                  Text(
                                    owner?.role ?? 'Owner',
                                    style: TextStyle(fontSize: 12, color: context.secondaryTextColor, fontWeight: FontWeight.bold),
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
                                  onPressed: () async {
                                    final currentUser = ref.read(currentUserDataProvider).value;
                                    if (currentUser == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to chat with the owner')));
                                      return;
                                    }
                                    
                                    final chatId = await ref.read(chatRepositoryProvider).startOrGetChat(
                                      currentUser.uid, 
                                      property.ownerId,
                                      metadata: {'propertyId': property.id},
                                    );
                                    
                                    if (context.mounted) {
                                      context.push('/chats/$chatId');
                                      LoggerService.trackEvent('property_chat_owner', parameters: {
                                        'property_id': property.id,
                                        'owner_id': property.ownerId,
                                      });
                                    }
                                  },
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
                                 onPressed: () {
                                   if (owner?.phoneNumber != null) {
                                     launchUrl(Uri.parse('tel:${owner!.phoneNumber}'));
                                     LoggerService.trackEvent('property_call_owner', parameters: {
                                       'property_id': property.id,
                                       'owner_id': property.ownerId,
                                     });
                                   }
                                 },
                                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        loading: () => const Center(child: LinearProgressIndicator()),
                        error: (e, st) => Text('Error loading owner info'),
                      ),
                   ),

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
                             color: context.cardColor,
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: context.borderColor),
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
                                Text(
                                  property.builtIn?.toString() ?? 'N/A',
                                  style: const TextStyle(
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
                                Text(
                                  property.lotSizeSqFt != null 
                                      ? '${property.lotSizeSqFt!.toInt().toString()} SF' 
                                      : 'N/A',
                                  style: const TextStyle(
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
          color: context.cardColor,
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
              onPressed: () => _scheduleTour(context, ref, property),
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
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Future<void> _scheduleTour(BuildContext context, WidgetRef ref, dynamic property) async {
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

    final bookingDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    
    try {
      final user = ref.read(currentUserDataProvider).value;
      if (user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to book a visit')));
        }
        return;
      }

      final booking = BookingModel(
        id: const Uuid().v4(),
        propertyId: property.id,
        propertyTitle: property.title,
        propertyLocation: property.location,
        propertyImageUrl: property.imageUrls.isNotEmpty ? property.imageUrls.first : null,
        buyerId: user.uid,
        ownerId: property.ownerId,
        bookingDate: bookingDateTime,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await ref.read(bookingRepositoryProvider).addBooking(booking);
      
      LoggerService.trackEvent('property_book_visit', parameters: {
        'property_id': property.id,
        'booking_id': booking.id,
        'booking_date': bookingDateTime.toIso8601String(),
      });

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Visit Scheduled!'),
            content: Text('Your visit for "${property.title}" has been requested for ${date.day}/${date.month} at ${time.format(context)}. You can track this in the Tracking Hub.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Great!')),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to schedule visit: $e')));
      }
    }
  }

  Widget _buildOverviewGrid(BuildContext context, PropertyModel property) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildOverviewItem(context, Icons.king_bed_outlined, 'BEDROOMS', property.bedrooms.toString()),
        _buildOverviewItem(context, Icons.bathtub_outlined, 'BATHROOMS', property.bathrooms.toString()),
        _buildOverviewItem(context, Icons.square_foot_outlined, 'TOTAL AREA', '${property.areaSqFt.toInt()} SF'),
        if (property.builtIn != null) _buildOverviewItem(context, Icons.calendar_today_outlined, 'BUILT YEAR', property.builtIn.toString()),
        if (property.lotSizeSqFt != null) _buildOverviewItem(context, Icons.landscape_outlined, 'LOT SIZE', '${property.lotSizeSqFt!.toInt()} SF'),
        _buildOverviewItem(context, Icons.apartment_outlined, 'TYPE', property.propertyType),
      ],
    );
  }

  Widget _buildOverviewItem(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[900]?.withValues(alpha: 0.3) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 18),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 9, color: context.secondaryTextColor, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: context.primaryTextColor)),
        ],
      ),
    );
  }

  Widget _buildAmenities(BuildContext context, List<String> amenities) {
    if (amenities.isEmpty) return const Text('No amenities listed.');
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: amenities.map((amenity) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
        ),
        child: Text(
          amenity,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      )).toList(),
    );
  }
}
