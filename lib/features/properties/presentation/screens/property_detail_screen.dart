import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class PropertyDetailScreen extends ConsumerWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertiesStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return propertiesAsync.when(
      data: (properties) {
        final propertyIdx = properties.indexWhere((p) => p.id == propertyId);
        if (propertyIdx == -1) {
          return Scaffold(body: Center(child: Text(l10n.propertyNotFound)));
        }
        final property = properties[propertyIdx];
        final ownerAsync = ref.watch(userProfileProvider(property.ownerId));
        final currentUser = ref.watch(currentUserDataProvider).value;
        final isSavedAsync = currentUser != null
            ? ref.watch(
                isPropertySavedProvider((
                  userId: currentUser.uid,
                  propertyId: propertyId,
                )),
              )
            : const AsyncValue.data(false);

        return Scaffold(
          backgroundColor: context.scaffoldColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350.0.h,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: Padding(
                  padding: EdgeInsets.only(left: 8.0.w),
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.chevronLeft,
                        color: Colors.white,
                        size: 20.w,
                      ),
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isSavedAsync.value == true
                          ? LucideIcons.heart
                          : LucideIcons.heart,
                      color: isSavedAsync.value == true
                          ? Colors.red
                          : Colors.white,
                      fill: isSavedAsync.value == true ? 1.0 : 0.0,
                    ),
                    onPressed: () async {
                      if (currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.pleaseLoginToSave)),
                        );
                        return;
                      }
                      await ref
                          .read(propertyRepositoryProvider)
                          .toggleSaveProperty(currentUser.uid, propertyId);
                      LoggerService.trackEvent(
                        isSavedAsync.value == true
                            ? 'property_unsaved'
                            : 'property_saved',
                        parameters: {
                          'property_id': propertyId,
                          'property_title': property.title,
                        },
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      minimumSize: Size(40.w, 40.w),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(
                      LucideIcons.share2,
                      color: Colors.white,
                      size: 20.w,
                    ),
                    onPressed: () {
                      Share.share(
                        'Check out this property on Sampatti Bazar: ${property.title} in ${property.city} for ₹${property.price.toInt()}.', // Consider localizing this message too
                        subject: 'Property Shared: ${property.title}',
                      );
                      LoggerService.trackEvent(
                        'property_shared',
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
                  SizedBox(width: 16.w),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'property_image_${property.id}',
                        child: CachedNetworkImage(
                          imageUrl: property.imageUrls.isNotEmpty
                              ? property.imageUrls.first
                              : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                          fit: BoxFit.cover,
                          memCacheHeight: 800,
                          memCacheWidth: 800,
                        ),
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
                        bottom: 24.h,
                        left: 20.w,
                        right: 20.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (property.isZeroBrokerage)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(8.w),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          LucideIcons.star,
                                          color: Colors.white,
                                          size: 12.w,
                                          fill: 1.0,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          l10n.zeroBrokerageTag,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (property.isZeroBrokerage &&
                                    property.isVerified)
                                  SizedBox(width: 8.w),
                                if (property.isVerified)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.95,
                                      ),
                                      borderRadius: BorderRadius.circular(8.sp),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          LucideIcons.badgeCheck,
                                          color: AppTheme.primaryBlue,
                                          size: 12.sp,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          l10n.verifiedTag,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                                  property.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.0,
                                  ),
                                  )
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title
                            .split(' ')
                            .map(
                              (str) => str.isNotEmpty
                                  ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}'
                                  : '',
                            )
                            .join(' '),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: context.primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            color: AppTheme.primaryBlue,
                            size: 16.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${property.location.toUpperCase()[0]}${property.location.substring(1).toLowerCase()}, ${property.city.toUpperCase()[0]}${property.city.substring(1).toLowerCase()}',
                            style: TextStyle(
                              color: context.secondaryTextColor,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      Container(
                            padding: EdgeInsets.all(20.sp),
                            decoration: BoxDecoration(
                              color: context.isDarkMode
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(24.sp),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.askingPrice,
                                        style: TextStyle(
                                          color: context.secondaryTextColor,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        '₹${property.price.toInt()}',
                                        style: TextStyle(
                                          color: AppTheme.primaryBlue,
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1.w,
                                  height: 40.h,
                                  color: context.borderColor,
                                ),
                                SizedBox(width: 24.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      l10n.totalArea,
                                      style: TextStyle(
                                        color: context.secondaryTextColor,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: property.areaSqFt
                                                .toInt()
                                                .toString(),
                                            style: TextStyle(
                                              color: context.primaryTextColor,
                                              fontSize: 22.sp,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' ${l10n.sqft.toUpperCase()}',
                                            style: TextStyle(
                                              color: context.secondaryTextColor,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                      SizedBox(height: 32.h),
                      Text(
                        l10n.overview,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: context.secondaryTextColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildOverviewGrid(
                        context,
                        property,
                        l10n,
                      ),

                      SizedBox(height: 32.h),
                      Text(
                        l10n.amenities,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: context.secondaryTextColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildAmenities(context, property.amenities, l10n),

                      SizedBox(height: 32.h),

                      Text(
                        l10n.propertyDescription,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        property.description.isNotEmpty
                            ? property.description
                            : l10n.noDescription,
                        style: TextStyle(
                          color: context.secondaryTextColor,
                          fontSize: 14.sp,
                          height: 1.6.h,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        l10n.readFullSpec,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 32.h),
                      Text(
                        l10n.locationLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: context.secondaryTextColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(20.sp),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(24.sp),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(16.w),
                                  ),
                                  child: Icon(
                                    LucideIcons.mapPin,
                                    color: AppTheme.primaryBlue,
                                    size: 24.w,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        property.city.isNotEmpty
                                            ? (property.city[0].toUpperCase() +
                                                  property.city
                                                      .substring(1)
                                                      .toLowerCase())
                                            : 'Location',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w900,
                                          color: context.primaryTextColor,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        property.location,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: context.secondaryTextColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final query = Uri.encodeComponent(
                                    '${property.location}, ${property.city}',
                                  );
                                  final url = Uri.parse(
                                    'https://www.google.com/maps/search/?api=1&query=$query',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                                icon: Icon(LucideIcons.map, size: 18.sp),
                                label: Text(
                                  l10n.getDirections,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13.sp,
                                    letterSpacing: 1,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.sp),
                                  ),
                                  side: BorderSide(color: context.borderColor),
                                  foregroundColor: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),
                      Container(
                        padding: EdgeInsets.all(24.sp),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(28.sp),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(color: context.borderColor),
                        ),
                        child: ownerAsync.when(
                          data: (owner) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(3.w),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 30.sp,
                                          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                          backgroundImage: (owner?.phoneNumber != null && owner!.phoneNumber.isNotEmpty)
                                              ? NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(owner.name ?? 'User')}&background=random&size=128')
                                              : const NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&q=80'),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 5.h,
                                        right: 5.w,
                                        child: Container(
                                          width: 14.w,
                                          height: 14.w,
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent[400],
                                            shape: BoxShape.circle,
                                            border: Border.all(color: context.cardColor, width: 2.5.sp),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 20.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          owner?.name ?? 'Loading...',
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w900,
                                            color: context.primaryTextColor,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          '${owner?.role ?? l10n.ownerLabel} • ${owner?.location ?? 'Verified Agent'}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: context.secondaryTextColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (owner != null && (owner.trustScore ?? 0) > 0) ...[
                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Icon(LucideIcons.star, color: Colors.amber, size: 16.sp, fill: 1.0),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '${owner.trustScore!.toStringAsFixed(1)} (${owner.ratingCount ?? 0})',
                                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                                    ),
                                    SizedBox(width: 12.w),
                                    Container(width: 1, height: 12.h, color: context.borderColor),
                                    SizedBox(width: 12.w),
                                    Text(
                                      '${owner.totalDeals ?? 0} clear deals',
                                      style: TextStyle(fontSize: 12.sp, color: Colors.green, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(height: 24.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildOwnerAction(
                                      context,
                                      'Chat',
                                      LucideIcons.messageSquare,
                                      AppTheme.primaryBlue,
                                      () async {
                                        final currentUser = ref.read(currentUserDataProvider).value;
                                        if (currentUser == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseLoginToChat)));
                                          return;
                                        }
                                        final chatId = await ref.read(chatRepositoryProvider).startOrGetChat(
                                          currentUser.uid,
                                          property.ownerId,
                                          metadata: {'propertyId': property.id},
                                        );
                                        if (context.mounted) context.push('/chats/$chatId');
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildOwnerAction(
                                      context,
                                      'Call',
                                      LucideIcons.phone,
                                      Colors.green.shade600,
                                      () {
                                        if (owner?.phoneNumber != null) {
                                          launchUrl(Uri.parse('tel:${owner!.phoneNumber}'));
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  _buildOwnerIconAction(
                                    context,
                                    Icons.star_rate_rounded,
                                    Colors.amber,
                                    () => _showRatingDialog(context, ref, owner),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          loading: () => const Center(child: LinearProgressIndicator()),
                          error: (e, st) => Text('Error loading owner info'),
                        ),
                      ),

                      SizedBox(height: 32.h),

                      Text(
                        l10n.propertyDetails,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16.sp),
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(12.w),
                                border: Border.all(color: context.borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    LucideIcons.calendar,
                                    size: 24.sp,
                                    color: AppTheme.primaryBlue,
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    l10n.builtIn,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: context.secondaryTextColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      property.builtIn?.toString() ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12.w),
                                border: Border.all(color: context.borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    LucideIcons.maximize,
                                    size: 24.sp,
                                    color: AppTheme.primaryBlue,
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    l10n.lotSize,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: context.secondaryTextColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      property.lotSizeSqFt != null
                                          ? '${property.lotSizeSqFt!.toInt().toString()} ${l10n.sqft.toUpperCase()}'
                                          : 'N/A',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
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
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () => _scheduleTour(context, ref, property, l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                  ),
                  child: Text(
                    l10n.bookVisit,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Future<void> _scheduleTour(
    BuildContext context,
    WidgetRef ref,
    dynamic property,
    AppLocalizations l10n,
  ) async {
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

    final bookingDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    try {
      final user = ref.read(currentUserDataProvider).value;
      if (user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.pleaseLoginToChat)));
        }
        return;
      }

      final booking = BookingModel(
        id: const Uuid().v4(),
        propertyId: property.id,
        propertyTitle: property.title,
        propertyLocation: property.location,
        propertyImageUrl: property.imageUrls.isNotEmpty
            ? property.imageUrls.first
            : null,
        buyerId: user.uid,
        ownerId: property.ownerId,
        bookingDate: bookingDateTime,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await ref.read(bookingRepositoryProvider).addBooking(booking);

      LoggerService.trackEvent(
        'property_book_visit',
        parameters: {
          'property_id': property.id,
          'booking_id': booking.id,
          'booking_date': bookingDateTime.toIso8601String(),
        },
      );

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.visitScheduled),
            content: Text(
              l10n.visitScheduledMsg(
                property.title,
                '${date.day}/${date.month}',
                time.format(context),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.great),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSchedule(e.toString()))),
        );
      }
    }
  }

  Widget _buildOwnerAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18.sp),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.sp),
          side: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
      ),
    );
  }

  Widget _buildOwnerIconAction(
    BuildContext context,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20.sp, color: color),
        onPressed: onTap,
        constraints: BoxConstraints(
          minWidth: 48.w,
          minHeight: 48.w,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showRatingDialog(BuildContext context, WidgetRef ref, dynamic owner) {
    if (owner == null) return;
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Rate ${owner.name ?? 'Agent'}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How was your experience with this property lister?'),
            SizedBox(height: 16.h),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: Colors.amber,
                      onChanged: (val) => setState(() => rating = val),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(userRepositoryProvider)
                    .updateUserRating(owner.uid, rating);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Trust score submitted successfully',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text(
              'Submit',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(
    BuildContext context,
    PropertyModel property,
    AppLocalizations l10n,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildOverviewItem(
          context,
          LucideIcons.bed,
          l10n.bedroomsLabel,
          property.bedrooms.toString(),
        ),
        _buildOverviewItem(
          context,
          LucideIcons.bath,
          l10n.bathroomsTitle,
          property.bathrooms.toString(),
        ),
        _buildOverviewItem(
          context,
          LucideIcons.maximize,
          l10n.totalArea,
          '${property.areaSqFt.toInt()} ${l10n.sqft.toUpperCase()}',
        ),
        if (property.builtIn != null)
          _buildOverviewItem(
            context,
            LucideIcons.calendar,
            l10n.builtYearLabel,
            property.builtIn.toString(),
          ),
        if (property.lotSizeSqFt != null)
          _buildOverviewItem(
            context,
            LucideIcons.map,
            l10n.lotSize,
            '${property.lotSizeSqFt!.toInt()} ${l10n.sqft.toUpperCase()}',
          ),
        _buildOverviewItem(
          context,
          LucideIcons.building,
          l10n.propertyType,
          property.propertyType,
        ),
      ],
    );
  }

  Widget _buildOverviewItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? Colors.grey[900]?.withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 18.w),
          ),
          SizedBox(height: 12.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: context.secondaryTextColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
                color: context.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities(
    BuildContext context,
    List<String> amenities,
    AppLocalizations l10n,
  ) {
    if (amenities.isEmpty) return Text(l10n.noAmenities);
    return Wrap(
      spacing: 12.h,
      runSpacing: 12,
      children: amenities
          .map(
            (amenity) => Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                amenity,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
