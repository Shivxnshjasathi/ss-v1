import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyPropertiesScreen extends ConsumerWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Properties')),
        body: const Center(child: Text('Please log in')),
      );
    }

    final propertiesAsync = ref.watch(propertiesStreamProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: context.iconColor, size: 20.w),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Properties',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.primaryTextColor,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: propertiesAsync.when(
        data: (properties) {
          final myProperties = properties.where((p) => p.ownerId == user.uid).toList();

          if (myProperties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.building2, size: 48.w, color: context.secondaryTextColor.withValues(alpha: 0.2)),
                  SizedBox(height: 16.h),
                  Text(
                    'You haven\'t listed any properties yet.',
                    style: TextStyle(
                      color: context.secondaryTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/add-property'),
                    icon: Icon(LucideIcons.plus, size: 18.sp),
                    label: Text(
                      'LIST A PROPERTY',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: myProperties.length,
            itemBuilder: (context, index) {
              final property = myProperties[index];
              return _MyPropertyCard(property: property);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _MyPropertyCard extends ConsumerWidget {
  final PropertyModel property;

  const _MyPropertyCard({required this.property});

  String _formatPrice(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/${property.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property.imageUrls.isNotEmpty)
              CachedNetworkImage(
                imageUrl: property.imageUrls.first,
                height: 160.h,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 160.h,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: Icon(LucideIcons.image, size: 48.w, color: Colors.grey),
              ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.title,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: context.primaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(LucideIcons.mapPin, size: 12.sp, color: context.secondaryTextColor),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    '${property.location}, ${property.city}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: context.secondaryTextColor,
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
                      SizedBox(width: 12.w),
                      Text(
                        _formatPrice(property.price),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 42.h,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/properties/manage/${property.id}'),
                      icon: Icon(LucideIcons.shieldCheck, size: 16.sp, color: Colors.white),
                      label: Text(
                        'MANAGE PROPERTY',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Delete button
                  SizedBox(
                    width: double.infinity,
                    height: 42.h,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, ref),
                      icon: Icon(LucideIcons.trash2, size: 16.sp, color: Colors.redAccent),
                      label: Text(
                        'DELETE LISTING',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12.sp,
                          color: Colors.redAccent,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Property', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to permanently delete this listing? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(propertyRepositoryProvider).deleteProperty(property.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete property')),
          );
        }
      }
    }
  }
}
