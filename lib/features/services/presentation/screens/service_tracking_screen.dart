import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/auth/domain/user_model.dart';
import 'package:sampatti_bazar/features/services/data/booking_repository.dart';
import 'package:sampatti_bazar/features/services/domain/booking_model.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';

class ServiceTrackingScreen extends ConsumerWidget {
  const ServiceTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserDataProvider).value;
    if (user == null) {
      return Scaffold(
        backgroundColor: context.scaffoldColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.userX, size: 64.sp, color: Colors.grey.withValues(alpha: 0.3)),
              SizedBox(height: 16.h),
              Text(
                l10n.pleaseLoginToTrack,
                style: TextStyle(
                  color: context.secondaryTextColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      );
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
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Text(
            l10n.trackingHub,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: context.primaryTextColor,
              fontSize: 20.sp,
              fontFamily: 'Poppins',
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16.sp),
                border: Border.all(color: context.borderColor),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: context.secondaryTextColor,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11.sp,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11.sp,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
                tabs: [
                  Tab(text: l10n.bookings.toUpperCase()),
                  Tab(text: l10n.visitors.toUpperCase()),
                  Tab(text: l10n.services.toUpperCase()),
                ],
              ),
            ),
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
    final l10n = AppLocalizations.of(context)!;
    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return _buildEmptyState(
            context,
            isOwner ? LucideIcons.users : LucideIcons.calendarCheck,
            isOwner ? l10n.noVisitorsYet : l10n.noBookingsFound,
            isOwner ? l10n.noVisitorsYetDesc : l10n.noBookingsFoundDesc,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _buildBookingCard(context, ref, booking, isOwner);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.sp),
            decoration: BoxDecoration(
              color: context.cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48.sp, color: context.secondaryTextColor.withValues(alpha: 0.2)),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18.sp,
              color: context.primaryTextColor,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.secondaryTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, WidgetRef ref, BookingModel booking, bool isOwner) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getBookingStatusColor(booking.status);
    final dateStr = DateFormat('EEE, MMM d').format(booking.bookingDate);
    final timeStr = DateFormat('hh:mm a').format(booking.bookingDate);
    final otherPartyId = isOwner ? booking.buyerId : booking.ownerId;
    final otherPartyAsync = ref.watch(userProfileProvider(otherPartyId));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(24.sp),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.sp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.sp),
                    image: booking.propertyImageUrl != null 
                        ? DecorationImage(image: NetworkImage(booking.propertyImageUrl!), fit: BoxFit.cover)
                        : null,
                    color: context.scaffoldColor,
                  ),
                  child: booking.propertyImageUrl == null 
                      ? Icon(LucideIcons.house, color: context.secondaryTextColor.withValues(alpha: 0.3))
                      : null,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking.propertyTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15.sp,
                                color: context.primaryTextColor,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _buildStatusChip(context, booking.status.toUpperCase(), statusColor),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(LucideIcons.calendar, size: 12.sp, color: AppTheme.primaryBlue),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              "$dateStr at $timeStr",
                              style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: EdgeInsets.all(20.sp),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.sp)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, size: 14.sp, color: context.secondaryTextColor),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        booking.propertyLocation,
                        style: TextStyle(
                          color: context.secondaryTextColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                otherPartyAsync.when(
                  data: (otherParty) => Row(
                    children: [
                      CircleAvatar(
                        radius: 18.sp,
                        backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        backgroundImage: NetworkImage(
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(otherParty?.name ?? 'User')}&background=006BFF&color=fff',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOwner ? l10n.visitorText : l10n.ownerText,
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryBlue,
                                letterSpacing: 1,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              otherParty?.name ?? 'User',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w900,
                                color: context.primaryTextColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (otherParty?.phoneNumber != null)
                        _buildActionButton(
                          context,
                          LucideIcons.phone,
                          () => launchUrl(Uri.parse('tel:${otherParty!.phoneNumber}')),
                        ),
                      SizedBox(width: 8.w),
                      _buildActionButton(
                        context,
                        LucideIcons.messageSquare,
                        () => context.push('/chats/$otherPartyId'),
                      ),
                    ],
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, st) => const Text('Error loading user'),
                ),
              ],
            ),
          ),
          
          if (isOwner && booking.status == 'pending')
             _buildDecisionActions(context, ref, booking.id, isBooking: true),
             
          if (!isOwner && (booking.status == 'confirmed' || booking.status == 'pending'))
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => ref.read(bookingRepositoryProvider).updateBookingStatus(booking.id, 'cancelled'),
                  child: Text(
                    l10n.cancelRequest,
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 11.sp,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDecisionActions(BuildContext context, WidgetRef ref, String id, {bool isBooking = true}) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (isBooking) {
                  ref.read(bookingRepositoryProvider).updateBookingStatus(id, 'cancelled');
                } else {
                  // handle service decline
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                foregroundColor: AppTheme.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.sp)),
              ),
              child: Text(l10n.decline, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (isBooking) {
                  ref.read(bookingRepositoryProvider).updateBookingStatus(id, 'confirmed');
                } else {
                  // handle service confirm
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.sp)),
              ),
              child: Text(l10n.confirm, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.sp)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9.sp,
          fontWeight: FontWeight.w900,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12.sp),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 16.sp, color: context.primaryTextColor),
      ),
    );
  }

  Widget _buildServiceRequestList(BuildContext context, WidgetRef ref, UserModel user) {
    final l10n = AppLocalizations.of(context)!;
    final servicesAsync = ref.watch(userAllServicesProvider((userId: user.uid, email: user.email)));

    return servicesAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyState(
            context,
            LucideIcons.clipboardList,
            l10n.noServiceRequests,
            l10n.noServiceRequestsDesc,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildServiceRequestCard(context, ref, request, user.uid);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildServiceRequestCard(BuildContext context, WidgetRef ref, ServiceRequestModel request, String currentUserId) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getServiceStatusColor(request.status);
    final dateStr = DateFormat('MMM d, yyyy').format(request.createdAt);
    
    IconData categoryIcon;
    switch (request.category.toLowerCase()) {
      case 'legal': 
      case 'rentagreement': categoryIcon = LucideIcons.gavel; break;
      case 'construction': categoryIcon = LucideIcons.pencilRuler; break;
      case 'sitevisit': categoryIcon = LucideIcons.mapPin; break;
      case 'movers': categoryIcon = LucideIcons.truck; break;
      default: categoryIcon = LucideIcons.wrench;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(24.sp),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.sp),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.sp),
                  ),
                  child: Icon(categoryIcon, color: context.primaryTextColor, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.category.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10.sp,
                          color: AppTheme.primaryBlue,
                          letterSpacing: 1.5,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        request.category.toLowerCase() == 'movers' 
                            ? '${request.details['pickupLocation']} ➔ ${request.details['dropLocation']}'
                            : (request.details['propertyAddress'] ?? request.details['requirement'] ?? 'Premium Service'),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16.sp,
                          color: context.primaryTextColor,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(context, request.status.toUpperCase(), statusColor),
              ],
            ),
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                _buildTimelineStep(context, l10n.requestRaised, l10n.requestRaisedDesc(dateStr), true, true),
                _buildTimelineStep(context, l10n.partnerAssigned, l10n.partnerAssignedDesc, ['accepted', 'in progress', 'completed'].contains(request.status.toLowerCase()), true),
                _buildTimelineStep(context, l10n.inProgressStatus, l10n.inProgressDesc, ['in progress', 'completed'].contains(request.status.toLowerCase()), true),
                _buildTimelineStep(context, l10n.serviceDelivered, l10n.serviceDeliveredDesc, request.status.toLowerCase() == 'completed', false),
              ],
            ),
          ),
          
          if (request.category.toLowerCase() == 'movers' && (request.details['finalQuote'] != null || request.details['estimatedQuote'] != null))
            Container(
              margin: EdgeInsets.all(20.sp),
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16.sp),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.details['finalQuote'] != null ? l10n.finalQuote : l10n.estimatedPrice,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: context.secondaryTextColor,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '₹${request.details['finalQuote'] ?? request.details['estimatedQuote']}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryBlue,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            )
          else 
            SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(BuildContext context, String title, String subtitle, bool isCompleted, bool showLine) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: isCompleted ? AppTheme.primaryBlue : context.borderColor,
                  shape: BoxShape.circle,
                  border: isCompleted ? Border.all(color: AppTheme.primaryBlue, width: 2) : null,
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: isCompleted ? AppTheme.primaryBlue : context.borderColor,
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isCompleted ? FontWeight.w900 : FontWeight.w700,
                    color: isCompleted ? context.primaryTextColor : context.secondaryTextColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: context.secondaryTextColor.withValues(alpha: 0.6),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBookingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.orange;
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
}
