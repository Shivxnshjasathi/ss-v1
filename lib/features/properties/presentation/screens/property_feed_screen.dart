import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/core/widgets/skeleton_loaders.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:feature_discovery/feature_discovery.dart';

class PropertyFeedScreen extends ConsumerStatefulWidget {
  const PropertyFeedScreen({super.key});

  @override
  ConsumerState<PropertyFeedScreen> createState() => _PropertyFeedScreenState();
}

class _PropertyFeedScreenState extends ConsumerState<PropertyFeedScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Sell', 'Rent/Lease'];

  // Advanced Filter State
  String _selectedPropertyType = 'All';
  String _selectedBedrooms = 'Any';
  RangeValues _priceRange = const RangeValues(0, 100); // 0 to 100 on slider

  final List<String> _propertyTypes = [
    'All',
    'Apartment',
    'Villa',
    'Penthouse',
    'Studio',
  ];
  final List<String> _bedroomOptions = ['Any', '1+', '2+', '3+', '4+'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Refresh properties stream
    ref.invalidate(propertiesStreamProvider);
    // Wait for the next data event (optional but good for UX)
    await ref.read(propertiesStreamProvider.future);
  }

  String _getLocalizedCategory(AppLocalizations l10n, String category) {
    switch (category) {
      case 'All':
        return l10n.all;
      case 'Sell':
        return l10n.sell;
      case 'Rent/Lease':
        return l10n.rentLease;
      default:
        return category;
    }
  }

  String _getLocalizedPropertyType(AppLocalizations l10n, String type) {
    switch (type) {
      case 'All':
        return l10n.all;
      case 'Apartment':
        return l10n.apartment;
      case 'Villa':
        return l10n.villa;
      case 'Penthouse':
        return l10n.penthouse;
      case 'Studio':
        return l10n.studio;
      case 'House/Villa':
        return l10n.houseVilla;
      case 'Plot':
        return l10n.plot;
      case 'PG':
        return l10n.pg;
      case 'Commercial':
        return l10n.commercial;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: context.cardColor,
              border: Border.all(color: context.borderColor),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Icon(
              LucideIcons.chevronLeft,
              color: context.iconColor,
              size: 16.w,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.propertiesTitle,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.primaryTextColor,
            fontSize: 20.sp,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Floating Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(28.sp), // More rounded "flowing" design
                border: Border.all(color: context.borderColor, width: 1.2.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 20.w),
                  DescribedFeatureOverlay(
                    featureId: 'search_feature_id',
                    tapTarget: Icon(LucideIcons.search, color: AppTheme.primaryBlue),
                    title: const Text('Search Properties'),
                    description: const Text('Quickly find properties by location or locality name.'),
                    backgroundColor: AppTheme.primaryBlue,
                    targetColor: Colors.white,
                    child: Icon(
                      LucideIcons.search,
                      color: AppTheme.primaryBlue,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search by location, locality...',
                        hintStyle: TextStyle(
                          color: context.secondaryTextColor.withValues(alpha: 0.4),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        color: context.primaryTextColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        child: Icon(LucideIcons.x, color: context.secondaryTextColor, size: 16.sp),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: VerticalDivider(
                      width: 1.w,
                      thickness: 1.w,
                      color: context.borderColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context, l10n),
                    child: DescribedFeatureOverlay(
                      featureId: 'filter_feature_id',
                      tapTarget: Icon(LucideIcons.slidersHorizontal, color: context.primaryTextColor),
                      title: const Text('Refine Your Search'),
                      description: const Text('Filter by property type, price range, and number of bedrooms.'),
                      backgroundColor: AppTheme.primaryBlue,
                      targetColor: Colors.white,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Icon(
                          LucideIcons.slidersHorizontal,
                          color: context.primaryTextColor,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),


          // Featured Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.featuredCollections,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22.sp,
                    color: context.primaryTextColor,
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    l10n.seeAll,
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Property Cards
          Expanded(
            child: propertiesAsync.when(
              data: (properties) {
                final filtered = properties.where((p) {
                  // Category Filter (Sell/Rent)
                  if (_selectedCategory != 'All' &&
                      p.type != _selectedCategory) {
                    return false;
                  }

                  // Property Type Filter
                  if (_selectedPropertyType != 'All' &&
                      p.propertyType != _selectedPropertyType) {
                    return false;
                  }

                  // Bedrooms Filter
                  if (_selectedBedrooms != 'Any') {
                    final requiredBeds =
                        int.tryParse(_selectedBedrooms.replaceAll('+', '')) ??
                        0;
                    if (p.bedrooms < requiredBeds) {
                      return false;
                    }
                  }

                  // Price Filter logic
                  // 1 unit = 10 Lakhs = 1,000,000
                  final minPrice = _priceRange.start * 1000000;
                  final maxPrice = _priceRange.end * 1000000;

                  if (p.price < minPrice) {
                    return false;
                  }
                  if (_priceRange.end < 100 && p.price > maxPrice) {
                    return false;
                  }

                  // Search Query Filter
                  if (_searchController.text.isNotEmpty) {
                    final query = _searchController.text.toLowerCase();
                    final matchesTitle = p.title.toLowerCase().contains(query);
                    final matchesLocation = p.location.toLowerCase().contains(
                      query,
                    );
                    final matchesCity = p.city.toLowerCase().contains(query);
                    if (!matchesTitle && !matchesLocation && !matchesCity) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noPropertiesMatch,
                      style: TextStyle(
                        color: context.secondaryTextColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }

                if (context.isMobile) {
                  return LiquidPullToRefresh(
                    onRefresh: _handleRefresh,
                    color: AppTheme.primaryBlue,
                    backgroundColor: context.scaffoldColor,
                    showChildOpacityTransition: false,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 24.h),
                          child:
                              _buildPropertyCard(context, filtered[index], l10n),
                        );
                      },
                    ),
                  );
                }

                final crossAxisCount = context.isTablet ? 2 : 3;
                final itemHeight = 420.h;

                return LiquidPullToRefresh(
                  onRefresh: _handleRefresh,
                  color: AppTheme.primaryBlue,
                  backgroundColor: context.scaffoldColor,
                  showChildOpacityTransition: false,
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 24.h,
                      mainAxisExtent: itemHeight,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildPropertyCard(context, filtered[index], l10n);
                    },
                  ),
                );
              },
              loading: () => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount: 3,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: const PropertyCardSkeleton(),
                ),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    if (value >= 10) {
      return '₹${(value / 10).toStringAsFixed(1)} Cr';
    } else {
      return '₹${value.toInt() * 10} L';
    }
  }

  void _showFilterSheet(BuildContext context, AppLocalizations l10n) {
    // Local state for the modal until "Apply" is pressed
    String tempCategory = _selectedCategory;
    String tempType = _selectedPropertyType;
    String tempBedrooms = _selectedBedrooms;
    RangeValues tempPriceRange = _priceRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.scaffoldColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.all(24.0.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.filterProperties,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: context.primaryTextColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.x, size: 20.w),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    l10n.categories,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: context.secondaryTextColor,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 12.h,
                    runSpacing: 12,
                    children: _categories.map((cat) {
                      final isSelected = tempCategory == cat;
                      return _buildModalChoiceChip(
                        label: _getLocalizedCategory(l10n, cat),
                        isSelected: isSelected,
                        onSelected: (val) {
                          if (val) setModalState(() => tempCategory = cat);
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    l10n.propertyType,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: context.secondaryTextColor,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 12.h,
                    runSpacing: 12,
                    children: _propertyTypes.map((type) {
                      final isSelected = tempType == type;
                      return _buildModalChoiceChip(
                        label: _getLocalizedPropertyType(l10n, type),
                        isSelected: isSelected,
                        onSelected: (val) {
                          if (val) setModalState(() => tempType = type);
                        },
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 40.h),
                  Text(
                    l10n.priceRangeLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: context.secondaryTextColor,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  RangeSlider(
                    values: tempPriceRange,
                    min: 0,
                    max: 100, // 0 to 10 Cr+
                    activeColor: AppTheme.primaryBlue,
                    inactiveColor: context.borderColor,
                    onChanged: (values) {
                      setModalState(() {
                        tempPriceRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatPrice(tempPriceRange.start),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.primaryTextColor,
                        ),
                      ),
                      Text(
                        tempPriceRange.end >= 100
                            ? '${_formatPrice(tempPriceRange.end)}+'
                            : _formatPrice(tempPriceRange.end),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.primaryTextColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40.h),
                  Text(
                    l10n.bedroomsLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: context.secondaryTextColor,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 12.h,
                    runSpacing: 12,
                    children: _bedroomOptions.map((beds) {
                      final isSelected = tempBedrooms == beds;
                      return _buildModalChoiceChip(
                        label: beds,
                        isSelected: isSelected,
                        onSelected: (val) {
                          if (val) setModalState(() => tempBedrooms = beds);
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 48.h),

                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = tempCategory;
                          _selectedPropertyType = tempType;
                          _selectedBedrooms = tempBedrooms;
                          _priceRange = tempPriceRange;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                      ),
                      child: Text(
                        l10n.applyFilters,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : context.primaryTextColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      backgroundColor: context.cardColor,
      selectedColor: AppTheme.primaryBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.w),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryBlue : context.borderColor,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
    );
  }

  Widget _buildPropertyCard(
    BuildContext context,
    PropertyModel property,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/${property.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: context.isMobile ? 12.h : 0),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(24.sp), // More rounded iOS style
          border: Border.all(color: context.borderColor, width: 1.5.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08), // Softer, pro shadow
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Hero(
                  tag: 'property_image_${property.id}',
                  child: CachedNetworkImage(
                    imageUrl: property.imageUrls.isNotEmpty
                        ? property.imageUrls.first
                        : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=80',
                    height: 240.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    memCacheHeight: 400.h
                        .toInt(), // Performance: Limit memory cache size
                    memCacheWidth: 600.w.toInt(), // Responsive cache width
                    placeholder: (context, url) =>
                        Container(color: context.cardColor),
                  ),
                ),
                // Gradient Overlay for text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                // Top Tags
                Positioned(
                  top: 16.h,
                  left: 16.w,
                  child: Row(
                    children: [
                      if (property.isZeroBrokerage)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.star,
                                color: Colors.white,
                                size: 12.sp,
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
                      if (property.isZeroBrokerage && property.isVerified)
                        SizedBox(width: 8.w),
                      if (property.isVerified)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: context.scaffoldColor.withValues(
                              alpha: 0.95,
                            ),
                            borderRadius: BorderRadius.circular(8.sp),
                            border: Border.all(color: context.borderColor),
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
                                  color: context.primaryTextColor,
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
                ),
                // Title and Location
                Positioned(
                  bottom: 16.h,
                  left: 16.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      InkWell(
                        onTap: () async {
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
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              color: Colors.white70,
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              property.city,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              LucideIcons.externalLink,
                              color: Colors.white54,
                              size: 10.sp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Details Section
            Padding(
              padding: EdgeInsets.all(20.0.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.askingPrice,
                              style: TextStyle(
                                color: context.secondaryTextColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '₹${property.price.toInt()}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildAmenity(
                        LucideIcons.bed,
                        '${property.bedrooms} ${l10n.bed}',
                      ),
                      SizedBox(width: 16.w),
                      _buildAmenity(
                        LucideIcons.bath,
                        '${property.bathrooms} ${l10n.bath}',
                      ),
                      SizedBox(width: 16.w),
                      _buildAmenity(
                        LucideIcons.maximize,
                        '${property.areaSqFt.toInt()} ${l10n.sqft}',
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Divider(height: 1.h, color: context.borderColor),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final ownerAsync = ref.watch(userProfileProvider(property.ownerId));
                          return ownerAsync.when(
                            data: (owner) => CircleAvatar(
                              radius: 16.w,
                              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                              backgroundImage: (owner?.profileImageUrl != null && owner!.profileImageUrl!.isNotEmpty)
                                  ? NetworkImage(owner.profileImageUrl!)
                                  : NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(owner?.name ?? 'User')}&background=random&size=128'),
                            ),
                            loading: () => CircleAvatar(radius: 16.w, backgroundColor: context.borderColor),
                            error: (err, stack) => CircleAvatar(radius: 16.w, backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=error')),
                          );
                        },
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.listedBy.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: context.secondaryTextColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final ownerAsync = ref.watch(userProfileProvider(property.ownerId));
                              return ownerAsync.when(
                                data: (owner) => Text(
                                  owner?.name ?? 'Owner',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: context.primaryTextColor,
                                  ),
                                ),
                                loading: () => Container(width: 60.w, height: 10.h, color: context.borderColor),
                                error: (err, stack) => Text('Owner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                              );
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () =>
                            context.push('/properties/detail/${property.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          elevation: 2,
                          shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                        ),
                        child: Text(
                          l10n.viewDetails,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildAmenity(IconData icon, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 22.w, color: context.secondaryTextColor),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
            color: context.primaryTextColor,
          ),
        ),
      ],
    );
  }
}
