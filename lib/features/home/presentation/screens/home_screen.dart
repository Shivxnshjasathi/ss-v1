import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:sampatti_bazar/core/services/location_provider.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/core/widgets/skeleton_loaders.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    final propertiesAsync = ref.watch(propertiesStreamProvider);
    final locationAsync = ref.watch(userLocationProvider);
    final l10n = AppLocalizations.of(context)!;

    final fullName = userAsync.value?.name ?? 'User';
    final firstName = fullName.split(' ')[0];
    final currentLocation = locationAsync.when(
      data: (city) => city,
      loading: () => 'Fetching...',
      error: (_, _) => 'Location Error',
    );

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.welcome,
              style: TextStyle(
                fontSize: 12.sp,
                color: context.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  '$firstName!',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: context.primaryTextColor,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  LucideIcons.mapPin,
                  size: 14.w,
                  color: AppTheme.primaryBlue,
                ),
                SizedBox(width: 4.w),
                Text(
                  currentLocation,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.secondaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    backgroundImage: const CachedNetworkImageProvider(
                      'https://i.pravatar.cc/150?u=a042581f4e29026704d',
                    ),
                    radius: 20.sp,
                  ),
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.w),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: TextField(
                readOnly: true,
                onTap: () => context.push('/properties'),
                decoration: InputDecoration(
                  hintText: l10n.searchProperties,
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13.sp,
                  ),
                  prefixIcon: Icon(
                    LucideIcons.search,
                    color: Colors.grey,
                    size: 18.sp,
                  ),
                  suffixIcon: Icon(
                    LucideIcons.slidersHorizontal,
                    color: Colors.grey,
                    size: 18.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.w),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.w),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  filled: true,
                  fillColor: context.surfaceColor,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.h,
                    horizontal: 16.w,
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Categories Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildAdaptiveCategoryGrid(context, [
                _CategoryData(l10n.buy, LucideIcons.house, () {
                  LoggerService.i('Home: Buy tapped');
                  context.push('/properties');
                }),
                _CategoryData(l10n.rent, LucideIcons.building2, () {
                  LoggerService.i('Home: Rent tapped');
                  context.push('/properties');
                }),
                _CategoryData(l10n.list, LucideIcons.plus, () {
                  LoggerService.i('Home: List property tapped');
                  context.push('/add-property');
                }),
                _CategoryData(l10n.marketplace, LucideIcons.shoppingBag, () {
                  LoggerService.i('Home: Marketplace tapped');
                  context.push('/services/marketplace');
                }),
              ]),
            ),

            SizedBox(height: 16.h),

            // Quick Access Services Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildAdaptiveCategoryGrid(context, [
                _CategoryData(
                  l10n.loan,
                  LucideIcons.landmark,
                  () => context.push('/services/loan'),
                ),
                _CategoryData(
                  l10n.construct,
                  LucideIcons.pencilRuler,
                  () => context.push('/services/construction'),
                ),
                _CategoryData(
                  l10n.legal,
                  LucideIcons.gavel,
                  () => context.push('/services/legal'),
                ),
                _CategoryData(
                  l10n.movers,
                  LucideIcons.truck,
                  () => context.push('/services/movers'),
                ),
              ]),
            ),

            SizedBox(height: 32.h),

            // Dynamic Properties Section
            propertiesAsync.when(
              data: (properties) {
                if (properties.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.w),
                      child: Text(
                        l10n.noPropertiesYet,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final zeroBrokerage = properties
                    .where((p) => p.isZeroBrokerage)
                    .toList();
                final featured = zeroBrokerage.isNotEmpty
                    ? zeroBrokerage
                    : properties.take(5).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Zero-Brokerage Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.featuredZeroBrokerage,
                                  maxLines: 2,
                                  softWrap: true,
                                  style: context.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        height: 1.1.h,
                                        fontSize: 18.sp,
                                        color: context.primaryTextColor,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/properties'),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.seeAll,
                                  style: TextStyle(
                                    color: context.colorScheme.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12.sp,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  LucideIcons.arrowRight,
                                  size: 16.sp,
                                  color: context.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 320.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: featured.length,
                        itemBuilder: (context, index) {
                          final prop = featured[index];
                          return Padding(
                            padding: EdgeInsets.only(right: 16.w),
                            child: _buildFeaturedCard(
                              context,
                              prop.title,
                              '₹${prop.price.toInt()}',
                              prop.city,
                              prop.imageUrls.isNotEmpty
                                  ? prop.imageUrls.first
                                  : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&q=80',
                              prop.id,
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Newly Added Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        l10n.newlyAdded,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 20.sp),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        children: properties.take(5).toList().asMap().entries.map((
                          entry,
                        ) {
                          final prop = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _buildNewlyAddedItem(
                              context: context,
                              title: prop.title,
                              price: '₹${prop.price.toInt()}',
                              type: prop.type,
                              image: prop.imageUrls.isNotEmpty
                                  ? prop.imageUrls.first
                                  : 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=300&q=80',
                              propertyId: prop.id,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
              loading: () => SizedBox(
                height: 320.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 3,
                  itemBuilder: (context, index) => const PropertyCardSkeleton(),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Text('Error: $err'),
                ),
              ),
            ),
            SizedBox(height: 100.h), // padding for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/chatbot');
        },
        backgroundColor: AppTheme.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.w),
        ),
        elevation: 10,
        child: Icon(LucideIcons.messageCircle, color: Colors.white, size: 24.w),
      ),
    );
  }

  Widget _buildAdaptiveCategoryGrid(
    BuildContext context,
    List<_CategoryData> items,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - (items.length - 1) * 12) / items.length;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items
              .map(
                (item) => _buildCategoryItem(
                  context,
                  item.title,
                  item.icon,
                  item.onTap,
                  itemWidth,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    double width,
  ) {
    return GestureDetector(
      onTapDown: (_) {}, // For visual feedback if needed
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width.clamp(50.0, 70.0),
            height: width.clamp(50.0, 70.0),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(
                20.sp,
              ), // More rounded iOS style
              border: Border.all(color: context.borderColor, width: 1.5.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: context.iconColor,
              size: width.clamp(20.0, 28.0).sp,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: width,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: context.primaryTextColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(
    BuildContext context,
    String title,
    String price,
    String location,
    String imageUrl,
    String propertyId,
  ) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/$propertyId'),
      child: Container(
        width: 260.w, // Slightly wider for better visual impact
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(
            24.sp,
          ), // Smoother rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08), // Softer shadow
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          image: DecorationImage(
            image: ResizeImage(
              CachedNetworkImageProvider(imageUrl),
              width: 800.w.toInt(),
            ),
            fit: BoxFit.cover,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
            // Zero Brokerage Badge
            Positioned(
              top: 16.h,
              left: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E60FF),
                  borderRadius: BorderRadius.circular(20.sp),
                ),
                child: Text(
                  'Zero Brokerage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Info Section
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '/ month',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12.sp,
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
    );
  }

  Widget _buildNewlyAddedItem({
    required BuildContext context,
    required String title,
    required String price,
    required String type,
    required String image,
    required String propertyId,
  }) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/$propertyId'),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20.sp), // Consistent iOS style
          border: Border.all(color: context.borderColor, width: 1.2.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image with smoother corners
            Container(
              width: 90.w, // Slightly larger
              height: 90.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.sp),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(image),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14.sp,
                            color: context.primaryTextColor,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w900,
                            color: context.colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    price,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18.sp,
                      color: context.primaryTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.sp),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E60FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.zap,
                          color: Colors.white,
                          size: 8.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'DIRECT OWNER',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
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
    );
  }
}

class _CategoryData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _CategoryData(this.title, this.icon, this.onTap);
}
