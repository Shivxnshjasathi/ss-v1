import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/services/data/booking_repository.dart';
import 'package:sampatti_bazar/features/services/domain/booking_model.dart';

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
      length: 2,
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
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList(context, ref, myBookingsAsync, isOwner: false),
            _buildBookingList(context, ref, myVisitorsAsync, isOwner: true),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.orange;
    }
  }
}
