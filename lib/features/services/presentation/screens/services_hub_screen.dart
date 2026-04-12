import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/widgets/contact_bottom_sheet.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';

class ServicesHubScreen extends StatelessWidget {
  const ServicesHubScreen({super.key});

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
            Text(
              l10n.financialEcosystem,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.servicesSubtitle,
              style: TextStyle(
                color: context.secondaryTextColor,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 24.h),
            GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
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
                    _buildServiceGridItem(
                      context,
                      l10n.marketplace,
                      LucideIcons.shoppingBag,
                      l10n.materialsAndMore,
                      '/services/marketplace',
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
            _buildVerifiedBanner(
              context,
              l10n,
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/services/tracking'),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(LucideIcons.mapPin, color: Colors.white, size: 18),
        label: Text(l10n.serviceTracking),
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
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16.sp),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8.sp),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Icon(
                    icon,
                    color: context.primaryTextColor,
                    size: 24.sp,
                  ),
                ),
                if (isHot && hotLabel != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Text(
                      hotLabel,
                      style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                color: context.secondaryTextColor,
                fontSize: 10.sp,
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
        _buildListTile(
          context,
          l10n.emiCalculator,
          l10n.planYourFinances,
          LucideIcons.calculator,
          () => context.push('/services/emi-calculator'),
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
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: context.borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8.sp),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Icon(icon, color: context.primaryTextColor, size: 24.sp),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: context.secondaryTextColor, fontSize: 12.sp),
        ),
        trailing: Icon(
          LucideIcons.chevronRight,
          color: context.secondaryTextColor.withValues(alpha: 0.5),
          size: 18.sp,
        ),
      ),
    );
  }

  Widget _buildVerifiedBanner(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(24.sp),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.verified,
                  style: TextStyle(
                    color: AppTheme.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.goldStandardProtection,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.strictlyVetted,
                  style: TextStyle(
                    color: context.secondaryTextColor,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Icon(LucideIcons.zap, color: AppTheme.cyanAccent, size: 40.sp),
        ],
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
