import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/auth/domain/user_model.dart';
import 'package:sampatti_bazar/features/services/data/booking_repository.dart';
import 'package:sampatti_bazar/features/services/domain/booking_model.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';

class ServiceTrackingScreen extends ConsumerWidget {
  const ServiceTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserDataProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in to track your services')));
    }

    final myBookingsAsync = ref.watch(userBookingsProvider(user.uid));
    final myVisitorsAsync = ref.watch(ownerBookingsProvider(user.uid));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.scaffoldColor,
        appBar: AppBar(
          backgroundColor: context.scaffoldColor,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_back_ios_new, color: context.iconColor, size: 16),
            ),
            onPressed: () => context.pop(),
          ),
          title: Text('Tracking Hub', style: TextStyle(fontWeight: FontWeight.w900, color: context.primaryTextColor, fontSize: 18)),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: AppTheme.primaryBlue,
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: Colors.grey[500],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'MY BOOKINGS'),
              Tab(text: 'MY VISITORS'),
              Tab(text: 'MY SERVICES'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList(context, ref, myBookingsAsync, isOwner: false),
            _buildBookingList(context, ref, myVisitorsAsync, isOwner: true),
            _buildServiceRequestList(context, ref, user),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, WidgetRef ref, AsyncValue<List<BookingModel>> bookingsAsync, {required bool isOwner}) {
    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  isOwner ? 'No one has scheduled a visit yet' : 'You haven\'t booked any visits',
                  style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _buildBookingCard(context, ref, booking, isOwner);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildBookingCard(BuildContext context, WidgetRef ref, BookingModel booking, bool isOwner) {
    final statusColor = _getStatusColor(booking.status);
    final dateStr = DateFormat('EEE, MMM d • hh:mm a').format(booking.bookingDate);
    final otherPartyId = isOwner ? booking.buyerId : booking.ownerId;
    final otherPartyAsync = ref.watch(userProfileProvider(otherPartyId));

    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (booking.propertyImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(booking.propertyImageUrl!, width: 50, height: 50, fit: BoxFit.cover),
                  )
                else
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.home_work_outlined, color: Colors.grey),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.propertyTitle, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: context.primaryTextColor, letterSpacing: -0.3)),
                      const SizedBox(height: 4),
                      Text(dateStr, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(booking.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Container(height: 1, color: context.borderColor),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(child: Text(booking.propertyLocation, style: TextStyle(color: Colors.grey[700], fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 12),
                otherPartyAsync.when(
                  data: (otherParty) => Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(otherParty?.name ?? 'User')}&background=random'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOwner ? 'Visitor: ${otherParty?.name ?? 'User'}' : 'Owner: ${otherParty?.name ?? 'User'}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.primaryTextColor),
                      ),
                      if (otherParty?.phoneNumber != null) ...[
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.phone, size: 16, color: AppTheme.primaryBlue),
                          onPressed: () => launchUrl(Uri.parse('tel:${otherParty!.phoneNumber}')),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ],
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => const Text('Error loading user'),
                ),
              ],
            ),
          ),
          if (isOwner && booking.status == 'pending')
             Padding(
               padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
               child: Row(
                 children: [
                   Expanded(
                     child: OutlinedButton(
                       onPressed: () => ref.read(bookingRepositoryProvider).updateBookingStatus(booking.id, 'cancelled'),
                       style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), foregroundColor: Colors.red),
                       child: const Text('Decline'),
                     ),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: ElevatedButton(
                       onPressed: () => ref.read(bookingRepositoryProvider).updateBookingStatus(booking.id, 'confirmed'),
                       style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                       child: const Text('Confirm'),
                     ),
                   ),
                 ],
               ),
             ),
          if (!isOwner && (booking.status == 'confirmed' || booking.status == 'pending'))
            Padding(
               padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
               child: SizedBox(
                 width: double.infinity,
                 child: OutlinedButton(
                   onPressed: () => ref.read(bookingRepositoryProvider).updateBookingStatus(booking.id, 'cancelled'),
                   style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), foregroundColor: Colors.grey[600]),
                   child: const Text('Cancel Request'),
                 ),
               ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceRequestList(BuildContext context, WidgetRef ref, UserModel user) {
    final servicesAsync = ref.watch(userAllServicesProvider((userId: user.uid, email: user.email)));

    return servicesAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.miscellaneous_services_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No service requests raised yet',
                  style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildServiceRequestCard(context, ref, request, user.uid);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildServiceRequestCard(BuildContext context, WidgetRef ref, ServiceRequestModel request, String currentUserId) {
    final statusColor = _getServiceStatusColor(request.status);
    final dateStr = DateFormat('MMM d, yyyy').format(request.createdAt);
    final isTenant = request.tenantId == currentUserId || request.tenantEmail == ref.read(currentUserDataProvider).value?.email;
    final isLessor = request.userId == currentUserId;
    
    IconData categoryIcon;
    switch (request.category.toLowerCase()) {
      case 'legal': 
      case 'rentagreement': categoryIcon = Icons.gavel; break;
      case 'construction': categoryIcon = Icons.architecture; break;
      case 'sitevisit': categoryIcon = Icons.location_on; break;
      case 'movers': categoryIcon = Icons.local_shipping; break;
      default: categoryIcon = Icons.miscellaneous_services;
    }

    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(categoryIcon, color: AppTheme.primaryBlue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          request.category.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryBlue, letterSpacing: 1),
                        ),
                        if (request.category.toLowerCase() == 'rentagreement')
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isTenant ? Colors.purple.withValues(alpha: 0.1) : (isLessor ? Colors.orange.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isTenant ? 'TENANT ROLE' : (isLessor ? 'LANDLORD ROLE' : 'PARTICIPANT'),
                              style: TextStyle(color: isTenant ? Colors.purple : (isLessor ? Colors.orange : Colors.grey), fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(height: 4),
                      Text(
                        request.category.toLowerCase() == 'movers' 
                            ? '${request.details['pickupLocation']} ➔ ${request.details['dropLocation']}'
                            : (request.details['propertyAddress'] ?? request.details['requirement'] ?? 'Service Request'),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.primaryTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (request.location != null && request.category.toLowerCase() != 'movers')
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(request.location!, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
          ),
          if (request.category.toLowerCase() == 'movers')
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: request.details['finalQuote'] != null 
                         ? Colors.green.withValues(alpha: 0.1) 
                         : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Row(
                       children: [
                         Icon(request.details['finalQuote'] != null ? Icons.verified : Icons.calculate, size: 16, color: request.details['finalQuote'] != null ? Colors.green[700] : Colors.grey[600]),
                         const SizedBox(width: 6),
                         Text(request.details['finalQuote'] != null ? 'Official Provider Quote' : 'Estimated Price', style: TextStyle(fontSize: 12, color: request.details['finalQuote'] != null ? Colors.green[700] : Colors.grey[600], fontWeight: FontWeight.bold)),
                       ],
                     ),
                     Text('₹${request.details['finalQuote'] ?? request.details['estimatedQuote']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: request.details['finalQuote'] != null ? Colors.green[700] : Colors.grey[800])),
                  ],
                ),
              ),
            ),
          // Status Progress Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusStep('Raised', true),
                    _buildStatusStep('Accepted', ['accepted', 'in progress', 'completed'].contains(request.status.toLowerCase())),
                    _buildStatusStep('Active', ['in progress', 'completed'].contains(request.status.toLowerCase())),
                    _buildStatusStep('Done', request.status.toLowerCase() == 'completed'),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _getStatusProgress(request.status),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep(String label, bool isReached) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: isReached ? AppTheme.primaryBlue : Colors.grey[400],
      ),
    );
  }

  double _getStatusProgress(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 0.25;
      case 'accepted': return 0.5;
      case 'in progress': return 0.75;
      case 'completed': return 1.0;
      default: return 0.1;
    }
  }

  Color _getServiceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted': return Colors.blue;
      case 'in progress': return AppTheme.primaryBlue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.orange;
    }
  }
}
