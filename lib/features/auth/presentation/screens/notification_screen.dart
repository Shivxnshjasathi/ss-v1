import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/services/data/booking_repository.dart';
import 'package:sampatti_bazar/features/services/domain/booking_model.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view notifications.')),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.chevronLeft,
            color: context.iconColor,
            size: 20.w,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Activity Center',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.primaryTextColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: context.primaryTextColor,
          unselectedLabelColor: context.secondaryTextColor,
          labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
          tabs: const [
            Tab(text: 'MY BOOKINGS'),
            Tab(text: 'MY VISITORS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BookingsList(userId: user.uid, isOwner: false),
          _BookingsList(userId: user.uid, isOwner: true),
        ],
      ),
    );
  }
}

class _BookingsList extends ConsumerWidget {
  final String userId;
  final bool isOwner;

  const _BookingsList({required this.userId, required this.isOwner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = isOwner
        ? ref.watch(ownerBookingsProvider(userId))
        : ref.watch(userBookingsProvider(userId));

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.calendarOff,
                  size: 48.w,
                  color: context.secondaryTextColor.withValues(alpha: 0.2),
                ),
                SizedBox(height: 16.h),
                Text(
                  isOwner
                      ? 'No visitor requests yet.'
                      : 'You haven\'t booked any visits yet.',
                  style: TextStyle(
                    color: context.secondaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _BookingCard(booking: booking, isOwner: isOwner)
                .animate()
                .fadeIn(delay: (index * 100).ms)
                .slideX(begin: 0.1, end: 0);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final BookingModel booking;
  final bool isOwner;

  const _BookingCard({required this.booking, required this.isOwner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(booking.status);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _formatDate(booking.bookingDate),
                style: TextStyle(
                  color: context.secondaryTextColor,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            booking.propertyTitle,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(LucideIcons.mapPin, size: 14.w, color: AppTheme.primaryBlue),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  booking.propertyLocation,
                  style: TextStyle(
                    color: context.secondaryTextColor,
                    fontSize: 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              if (booking.status == 'pending' || booking.status == 'confirmed')
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(context, ref, 'cancelled'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
              if (isOwner && booking.status == 'pending') ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(context, ref, 'confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ),
                    child: Text(
                      'CONFIRM',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String newStatus,
  ) async {
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(booking.id, newStatus);
      LoggerService.i('Booking ${booking.id} updated to $newStatus');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
      }
    } catch (e) {
      LoggerService.e('Failed to update booking status', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status')),
        );
      }
    }
  }
}
