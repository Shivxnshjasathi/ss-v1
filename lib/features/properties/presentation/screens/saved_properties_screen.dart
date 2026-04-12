import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class SavedPropertiesScreen extends ConsumerWidget {
  const SavedPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LoggerService.trackScreen('SavedPropertiesScreen');
    final userAsync = ref.watch(currentUserDataProvider);
    final l10n = AppLocalizations.of(context)!;

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.savedProperties)),
            body: Center(child: Text(l10n.pleaseLoginToSeeSaved)),
          );
        }

        final savedAsync = ref.watch(savedPropertiesProvider(user.uid));

        return Scaffold(
          backgroundColor: context.scaffoldColor,
          appBar: AppBar(
            backgroundColor: context.scaffoldColor,
            elevation: 0,
            title: Text(
              l10n.savedProperties,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: context.primaryTextColor,
                fontSize: 24.sp,
              ),
            ),
          ),
          body: savedAsync.when(
            data: (properties) {
              if (properties.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.heart,
                        size: 48.w,
                        color: context.secondaryTextColor.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        l10n.noSavedYet,
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
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final prop = properties[index];
                  return _buildSavedCard(context, prop)
                      .animate()
                      .fadeIn(delay: (index * 100).ms)
                      .slideX(begin: 0.1, end: 0);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) {
              LoggerService.e(
                'Error loading saved properties',
                error: e,
                stack: st,
              );
              return Center(child: Text('Error: $e'));
            },
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: context.scaffoldColor,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        backgroundColor: context.scaffoldColor,
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSavedCard(BuildContext context, PropertyModel property) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/${property.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    property.imageUrls.isNotEmpty
                        ? property.imageUrls.first
                        : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=300&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 12.w,
                        color: AppTheme.primaryBlue,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        property.city,
                        style: TextStyle(
                          color: context.secondaryTextColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '₹${property.price.toInt()}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      _buildSpecSmall(
                        context,
                        LucideIcons.bed,
                        '${property.bedrooms}',
                      ),
                      SizedBox(width: 12.w),
                      _buildSpecSmall(
                        context,
                        LucideIcons.bath,
                        '${property.bathrooms}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecSmall(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14.w, color: context.secondaryTextColor),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: context.secondaryTextColor,
          ),
        ),
      ],
    );
  }
}
