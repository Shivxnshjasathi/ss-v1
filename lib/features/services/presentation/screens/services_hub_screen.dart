import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/widgets/contact_bottom_sheet.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ServicesHubScreen extends StatefulWidget {
  const ServicesHubScreen({super.key});

  @override
  State<ServicesHubScreen> createState() => _ServicesHubScreenState();
}

class _ServicesHubScreenState extends State<ServicesHubScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          l10n.servicesHub,
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontSize: 20.sp),
        ),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.search,
              color: context.iconColor,
              size: 20.sp,
            ),
            onPressed: () {
              showSearch(context: context, delegate: GlobalSearchDelegate());
            },
          ),
          IconButton(
            icon: Icon(LucideIcons.bell, color: context.iconColor, size: 20.sp),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOffersBanner(context, l10n),
            SizedBox(height: 32.h),
            GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: context.screenWidth < 380 ? 1.0 : 1.15,
                  children: [
                    _buildServiceGridItem(
                      context,
                      l10n.homeLoans,
                      LucideIcons.landmark,
                      l10n.instantApproval,
                      '/services/loan',
                      isHot: true,
                      hotLabel: l10n.hot,
                    ),
                    _buildServiceGridItem(
                      context,
                      l10n.construction,
                      LucideIcons.pencilRuler,
                      l10n.topContractors,
                      '/services/construction',
                    ),
                    _buildServiceGridItem(
                      context,
                      l10n.movers,
                      LucideIcons.truck,
                      l10n.safeRelocation,
                      '/services/movers',
                    ),
                    _buildServiceGridItem(
                      context,
                      l10n.legalDocs,
                      LucideIcons.gavel,
                      l10n.verifiedLawyers,
                      '/services/legal',
                    ),
                    DescribedFeatureOverlay(
                      featureId: 'hub_marketplace_id',
                      tapTarget: Icon(LucideIcons.shoppingBag, color: AppTheme.primaryBlue),
                      title: const Text('Service Marketplace'),
                      description: const Text('Order construction materials, interior decor, and home essentials.'),
                      backgroundColor: AppTheme.primaryBlue,
                      targetColor: Colors.white,
                      child: _buildServiceGridItem(
                        context,
                        l10n.marketplace,
                        LucideIcons.shoppingBag,
                        l10n.materialsAndMore,
                        '/services/marketplace',
                      ),
                    ),
                    _buildServiceGridItem(
                      context,
                      'Other Services',
                      LucideIcons.wrench,
                      'Plumbing, Electric, etc.',
                      '/services/other',
                    ),
                  ],
                ),
            SizedBox(height: 32.h),
            Text(
              l10n.toolsAndSupport,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12.sp,
                letterSpacing: 1,
                color: context.secondaryTextColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildToolsSupportList(
              context,
              l10n,
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersBanner(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 150.h, // Adjusted height slightly for better fit
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20.sp),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Professional Property/Service Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800&q=80',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) => Container(color: AppTheme.primaryBlue),
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: Text(
                    "BEST VALUE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 8.sp,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Up to 20% OFF",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24.sp,
                    fontFamily: 'Poppins',
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4.h),
                Flexible(
                  child: Text(
                    "On Professional Home & Property Services",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => context.push('/services/offers'),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Text(
                      "Explore Deals",
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGridItem(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    String route, {
    bool isHot = false,
    String? hotLabel,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20.sp),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10.sp),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(14.sp),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Icon(
                    icon,
                    color: context.primaryTextColor,
                    size: 22.sp,
                  ),
                ),
                if (isHot && hotLabel != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Text(
                      hotLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                          color: context.primaryTextColor,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: context.secondaryTextColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsSupportList(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        DescribedFeatureOverlay(
          featureId: 'hub_emi_id',
          tapTarget: Icon(LucideIcons.calculator, color: AppTheme.primaryBlue),
          title: const Text('Planning Tools'),
          description: const Text('Calculate loan installments and plan your property budget smarter.'),
          backgroundColor: AppTheme.primaryBlue,
          targetColor: Colors.white,
          child: _buildListTile(
            context,
            l10n.emiCalculator,
            l10n.planYourFinances,
            LucideIcons.calculator,
            () => context.push('/services/emi-calculator'),
          ),
        ),
        SizedBox(height: 12.h),
        _buildListTile(
          context,
          l10n.liveSupport,
          l10n.chatWithExperts,
          LucideIcons.headphones,
          () => ContactBottomSheet.show(context),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20.sp),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(12.sp),
              ),
              child: Icon(
                icon,
                color: context.primaryTextColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      color: context.primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.secondaryTextColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: context.secondaryTextColor.withValues(alpha: 0.5),
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

}

class GlobalSearchDelegate extends SearchDelegate {
  List<Map<String, dynamic>> _getFeatures(AppLocalizations l10n) => [
    {
      'name': l10n.homeLoans,
      'route': '/services/loan',
      'icon': LucideIcons.landmark,
      'cat': l10n.finance,
    },
    {
      'name': l10n.construction,
      'route': '/services/construction',
      'icon': LucideIcons.pencilRuler,
      'cat': l10n.servicesLabel,
    },
    {
      'name': l10n.movers,
      'route': '/services/movers',
      'icon': LucideIcons.truck,
      'cat': l10n.servicesLabel,
    },
    {
      'name': l10n.legalDocs,
      'route': '/services/legal',
      'icon': LucideIcons.gavel,
      'cat': l10n.legal,
    },
    {
      'name': l10n.marketplace,
      'route': '/services/marketplace',
      'icon': LucideIcons.shoppingBag,
      'cat': l10n.materials,
    },
    {
      'name': 'Other Services',
      'route': '/services/other',
      'icon': LucideIcons.wrench,
      'cat': l10n.servicesLabel,
    },
    {
      'name': l10n.buy,
      'route': '/properties',
      'icon': LucideIcons.house,
      'cat': l10n.propertiesLabel,
    },
    {
      'name': l10n.rent,
      'route': '/properties',
      'icon': LucideIcons.building,
      'cat': l10n.propertiesLabel,
    },
    {
      'name': l10n.list,
      'route': '/properties/add',
      'icon': LucideIcons.squarePlus,
      'cat': l10n.activity,
    },
    {
      'name': l10n.saved,
      'route': '/properties/saved',
      'icon': LucideIcons.heart,
      'cat': l10n.activity,
    },
    {
      'name': l10n.emiCalculator,
      'route': '/services/emi-calculator',
      'icon': LucideIcons.calculator,
      'cat': l10n.tools,
    },
    {
      'name': l10n.liveSupport,
      'route': '/profile/support',
      'icon': LucideIcons.headphones,
      'cat': l10n.support,
    },
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: context.secondaryTextColor),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(LucideIcons.arrowLeft, color: context.iconColor),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = _getFeatures(l10n);
    final filtered = features
        .where(
          (f) =>
              f['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              f['cat'].toString().toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return Container(
      color: context.scaffoldColor,
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final feature = filtered[index];
          return ListTile(
            leading: Icon(
              feature['icon'] as IconData,
              color: context.iconColor,
            ),
            title: Text(
              feature['name'] as String,
              style: TextStyle(
                color: context.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              feature['cat'] as String,
              style: TextStyle(
                color: context.secondaryTextColor,
                fontSize: 12.sp,
              ),
            ),
            trailing: Icon(
              LucideIcons.chevronRight,
              size: 14.w,
              color: context.secondaryTextColor.withValues(alpha: 0.5),
            ),
            onTap: () {
              close(context, null);
              context.push(feature['route'] as String);
            },
          );
        },
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        iconTheme: IconThemeData(color: context.iconColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: context.secondaryTextColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
