import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:sampatti_bazar/core/utils/currency_utils.dart';
import 'package:sampatti_bazar/features/chat/data/chat_repository.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/core/widgets/google_map_widget.dart';
import 'package:sampatti_bazar/features/services/presentation/widgets/booking_bottom_sheet.dart';

class PropertyDetailScreen extends ConsumerWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});
  
  String _getLocalizedRole(String? roleKey, AppLocalizations l10n) {
    if (roleKey == null) return l10n.ownerLabel;
    
    // Exact mapping from onboarding_screen.dart keys
    switch (roleKey) {
      case 'consumerBuyer': return l10n.consumerBuyer;
      case 'builderAgent': return l10n.builderAgent;
      case 'constructionPartner': return l10n.constructionPartner;
      case 'legalAdvisor': return l10n.legalAdvisor;
      case 'materialVendor': return l10n.materialVendor;
      case 'loanExpert': return l10n.loanExpert;
      case 'packersMovers': return l10n.packersMoversRole;
      default: return roleKey; // Fallback to raw string if no match
    }
  }

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
                        l10n.shareMessage(property.title, property.city, property.price.toInt().toString()),
                        subject: l10n.shareSubject(property.title),
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
                  if (currentUser?.uid == property.ownerId) ...[
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: Icon(
                        LucideIcons.trash2,
                        color: Colors.redAccent,
                        size: 20.w,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Property'),
                            content: const Text('Are you sure you want to delete this property? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await ref.read(propertyRepositoryProvider).deleteProperty(property.id);
                            if (context.mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property deleted')));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete property')));
                            }
                          }
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.3),
                        minimumSize: const Size(40, 40),
                      ),
                    ),
                  ],
                  SizedBox(width: 16.w),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _PropertyImageGallery(
                    propertyId: property.id,
                    imageUrls: property.imageUrls,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Location Section
                      Text(
                        property.title,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w900,
                          color: context.primaryTextColor,
                          fontFamily: 'Poppins',
                          letterSpacing: -0.5,
                          height: 1.2,
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
                            '${property.location}, ${property.city}',
                            style: TextStyle(
                              color: context.secondaryTextColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),

                      // Price & Total Area Card
                      Container(
                        padding: EdgeInsets.all(24.sp),
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey[50], // Very soft grey as per UI
                          borderRadius: BorderRadius.circular(28.sp),
                          border: Border.all(color: context.borderColor, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.askingPrice.toUpperCase(),
                                    style: TextStyle(
                                      color: context.secondaryTextColor,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    CurrencyUtils.formatPrice(property.price),
                                    style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 48.h,
                              color: context.borderColor,
                            ),
                            SizedBox(width: 24.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    l10n.totalArea.toUpperCase(),
                                    style: TextStyle(
                                      color: context.secondaryTextColor,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        property.areaSqFt.toInt().toString(),
                                        style: TextStyle(
                                          color: context.primaryTextColor,
                                          fontSize: 28.sp,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
                                        child: Text(
                                          l10n.sqft.toUpperCase(),
                                          style: TextStyle(
                                            color: context.secondaryTextColor,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
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

                      SizedBox(height: 32.h),
                      _buildSectionHeader(l10n.overview.toUpperCase()),
                      SizedBox(height: 16.h),
                      _buildOverviewGrid(
                        context,
                        property,
                        l10n,
                      ),

                      SizedBox(height: 32.h),
                      _buildSectionHeader(l10n.amenities.toUpperCase()),
                      SizedBox(height: 16.h),
                      _buildAmenities(context, property.amenities, l10n),
                      SizedBox(height: 32.h),

                      if (property.vaultDocuments != null &&
                          property.vaultDocuments!.values.any((url) => url.toLowerCase().contains('.pdf'))) ...[
                        _buildSectionHeader('VERIFIED PROPERTY DOCUMENTS'),
                        _buildDocumentsList(context, property.vaultDocuments!),
                        SizedBox(height: 32.h),
                      ],

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
                      _buildSectionHeader(l10n.locationLabel.toUpperCase()),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(24.sp),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(28.sp),
                          border: Border.all(color: context.borderColor, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    LucideIcons.mapPin,
                                    color: AppTheme.primaryBlue,
                                    size: 24.w,
                                  ),
                                ),
                                SizedBox(width: 20.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        property.location.isNotEmpty ? property.location : l10n.loading,
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w900,
                                          color: context.primaryTextColor,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        property.city.isNotEmpty ? property.city : l10n.locationPlaceholder,
                                        style: TextStyle(
                                          fontSize: 14.sp,
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
                            GoogleMapWidget(
                              latitude: property.latitude,
                              longitude: property.longitude,
                              address: '${property.location}, ${property.city}',
                            ),
                            SizedBox(height: 24.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final Uri url;
                                  if (property.latitude != null && property.longitude != null) {
                                    url = Uri.parse(
                                      'https://www.google.com/maps/search/?api=1&query=${property.latitude},${property.longitude}',
                                    );
                                  } else {
                                    final query = Uri.encodeComponent(
                                      '${property.location}, ${property.city}',
                                    );
                                    url = Uri.parse(
                                      'https://www.google.com/maps/search/?api=1&query=$query',
                                    );
                                  }
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                                icon: Icon(LucideIcons.navigation, size: 18.sp),
                                label: Text(
                                  l10n.getDirections.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14.sp,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                                  foregroundColor: AppTheme.primaryBlue,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 20.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.sp),
                                    side: BorderSide(color: context.borderColor, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),

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
                          border: Border.all(color: context.borderColor, width: 1.2),
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
                                          radius: 35.sp, // Slightly larger
                                          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                          backgroundImage: (owner?.profileImageUrl != null && owner!.profileImageUrl!.isNotEmpty)
                                              ? NetworkImage(owner.profileImageUrl!)
                                              : NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(owner?.name ?? 'User')}&background=random&size=128'),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8.h,
                                        right: 8.w,
                                        child: Container(
                                          width: 16.w,
                                          height: 16.w,
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent[400],
                                            shape: BoxShape.circle,
                                            border: Border.all(color: context.cardColor, width: 3.w),
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
                                            fontSize: 22.sp,
                                            fontWeight: FontWeight.w900,
                                            color: context.primaryTextColor,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          '${_getLocalizedRole(owner?.role, l10n)} • ${owner?.location ?? l10n.verifiedAgent}',
                                          style: TextStyle(
                                            fontSize: 13.sp,
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
                                SizedBox(height: 20.h),
                                Row(
                                  children: [
                                    Icon(LucideIcons.star, color: Colors.amber, size: 16.sp, fill: 1.0),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '${owner.trustScore!.toStringAsFixed(1)} (${owner.ratingCount ?? 0})',
                                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                                    ),
                                    SizedBox(width: 14.w),
                                    Container(width: 1, height: 14.h, color: context.borderColor),
                                    SizedBox(width: 14.w),
                                    Text(
                                      '${owner.totalDeals ?? 0} ${l10n.clearDeals}',
                                      style: TextStyle(fontSize: 13.sp, color: Colors.green, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(height: 32.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildOwnerAction(
                                      context,
                                      l10n.chatAction,
                                      LucideIcons.messageCircle, // Slightly different icon for cleaner look
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
                                      l10n.callAction,
                                      LucideIcons.phoneCall, // Cleaner icon
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
                                    Icons.star_outline_rounded, // Polishicon
                                    Colors.amber,
                                    () => _showRatingDialog(context, ref, owner),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          loading: () => const Center(child: LinearProgressIndicator()),
                          error: (e, st) => Text(l10n.errorLoadingOwner),
                        ),
                      ),
                      SizedBox(height: 48.h),

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
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, -10),
                  blurRadius: 30,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: SafeArea(
              child: currentUser?.uid == property.ownerId
                ? Row(
                    children: [
                      Icon(LucideIcons.shieldCheck, color: AppTheme.primaryBlue, size: 20.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'This is your listing',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14.sp,
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 48.h,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text('Delete Property', style: TextStyle(fontWeight: FontWeight.w900)),
                                content: const Text('Are you sure you want to permanently delete this listing?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await ref.read(propertyRepositoryProvider).deleteProperty(property.id);
                                if (context.mounted) {
                                  context.pop();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property deleted')));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete')));
                                }
                              }
                            }
                          },
                          icon: Icon(LucideIcons.trash2, size: 16.sp, color: Colors.redAccent),
                          label: Text('DELETE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp, color: Colors.redAccent)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16.sp),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            if (currentUser == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.pleaseLoginToChat)),
                              );
                              return;
                            }
                            final chatId = await ref.read(chatRepositoryProvider).startOrGetChat(
                              currentUser.uid,
                              property.ownerId,
                              metadata: {'propertyId': property.id},
                            );
                            if (context.mounted) context.push('/chats/$chatId');
                          },
                          icon: Icon(LucideIcons.messageSquare, color: AppTheme.primaryBlue),
                          padding: EdgeInsets.all(16.w),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: SizedBox(
                          height: 56.h,
                          child: ElevatedButton.icon(
                            onPressed: () => _scheduleTour(context, ref, property, l10n),
                            icon: Icon(LucideIcons.calendarCheck, size: 18.sp),
                            label: Text(
                              l10n.bookVisit.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.sp),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
    PropertyModel property,
    AppLocalizations l10n,
  ) async {
    final user = ref.read(currentUserDataProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseLoginToChat)),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(
        property: property,
        buyerId: user.uid,
      ),
    );
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          color: Colors.blueGrey[400],
          letterSpacing: 1.2,
        ),
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
      childAspectRatio: 0.9,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? Colors.grey[900]?.withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(24.sp),
        border: Border.all(color: context.borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 20.w),
          ),
          const Spacer(),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9.sp,
              color: context.secondaryTextColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: context.primaryTextColor,
              height: 1.1,
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
    if (amenities.isEmpty) {
      return Text(
        l10n.noAmenities,
        style: TextStyle(
          color: context.secondaryTextColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: amenities
          .map(
            (amenity) => Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(color: context.borderColor),
              ),
              child: Text(
                amenity,
                style: TextStyle(
                  color: context.primaryTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
  Widget _buildDocumentsList(BuildContext context, Map<String, String> documents) {
    final pdfDocs = documents.entries.where((e) => e.value.toLowerCase().contains('.pdf')).toList();

    return Column(
      children: pdfDocs.map((doc) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16.sp),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Icon(LucideIcons.fileText, color: Colors.red, size: 20.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.key,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.sp,
                        color: context.primaryTextColor,
                      ),
                    ),
                    Text(
                      'Official PDF Document',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.download, color: AppTheme.primaryBlue, size: 20.sp),
                onPressed: () => launchUrl(Uri.parse(doc.value)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ==============================
// Swipeable Image Gallery Widget
// ==============================
class _PropertyImageGallery extends StatefulWidget {
  final String propertyId;
  final List<String> imageUrls;

  const _PropertyImageGallery({
    required this.propertyId,
    required this.imageUrls,
  });

  @override
  State<_PropertyImageGallery> createState() => _PropertyImageGalleryState();
}

class _PropertyImageGalleryState extends State<_PropertyImageGallery> {
  int _currentPage = 0;
  late final PageController _pageController;

  List<String> get _images => widget.imageUrls.isNotEmpty
      ? widget.imageUrls
      : [
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'
        ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Swipeable images
        PageView.builder(
          controller: _pageController,
          itemCount: _images.length,
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
          itemBuilder: (context, index) {
            final url = _images[index];
            // Keep Hero only on the first image for smooth transition from list
            if (index == 0) {
              return Hero(
                tag: 'property_image_${widget.propertyId}',
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  memCacheHeight: 1000,
                  memCacheWidth: 1000,
                  placeholder: (_, _) => Container(color: Colors.grey[300]),
                  errorWidget: (_, _, _) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                ),
              );
            }
            return CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              memCacheHeight: 1000,
              memCacheWidth: 1000,
              placeholder: (_, _) => Container(color: Colors.grey[300]),
              errorWidget: (_, _, _) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            );
          },
        ),

        // Photo counter badge (top-right area, below action buttons)
        if (_images.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentPage + 1} / ${_images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Dot indicators
        if (_images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_images.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
