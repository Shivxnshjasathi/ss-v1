import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20.sp),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: context.iconColor), 
            onPressed: () {
              showSearch(context: context, delegate: GlobalSearchDelegate());
            }
          ),
          IconButton(icon: Icon(Icons.notifications_none, color: context.iconColor), onPressed: () => context.push('/notifications')),
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
              style: TextStyle(color: context.secondaryTextColor, fontSize: 14.sp),
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
                 _buildServiceGridItem(context, l10n.homeLoans, Icons.account_balance, l10n.instantApproval, '/services/loan', isHot: true, hotLabel: l10n.hot),
                 _buildServiceGridItem(context, l10n.construction, Icons.architecture, l10n.topContractors, '/services/construction'),
                 _buildServiceGridItem(context, l10n.movers, Icons.local_shipping_outlined, l10n.safeRelocation, '/services/movers'),
                 _buildServiceGridItem(context, l10n.legalDocs, Icons.gavel, l10n.verifiedLawyers, '/services/legal'),
                 _buildServiceGridItem(context, l10n.marketplace, Icons.shopping_bag_outlined, l10n.materialsAndMore, '/services/marketplace'),
                 _buildServiceGridItem(context, 'Other Services', Icons.home_repair_service_outlined, 'Plumbing, Electric, etc.', '/services/other'),
              ],
            ),
            SizedBox(height: 32.h),
            Text(
              l10n.toolsAndSupport,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp, letterSpacing: 1, color: context.secondaryTextColor),
            ),
            SizedBox(height: 16.h),
            _buildToolsSupportList(context, l10n),
            SizedBox(height: 32.h),
            _buildVerifiedBanner(context, l10n),
            SizedBox(height: 32.h),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/services/tracking'),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.location_on_outlined, color: Colors.white),
        label: Text(l10n.serviceTracking, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildServiceGridItem(BuildContext context, String title, IconData icon, String subtitle, String route, {bool isHot = false, String? hotLabel}) {
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
                  child: Icon(icon, color: context.primaryTextColor, size: 24.sp),
                ),
                if (isHot && hotLabel != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Text(hotLabel, style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 10.sp, fontWeight: FontWeight.bold)),
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
              style: TextStyle(color: context.secondaryTextColor, fontSize: 10.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsSupportList(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        _buildListTile(context, l10n.emiCalculator, l10n.planYourFinances, Icons.calculate_outlined, () => context.push('/services/emi-calculator')),
        SizedBox(height: 12.h),
        _buildListTile(context, l10n.liveSupport, l10n.chatWithExperts, Icons.headset_mic_outlined, () => ContactBottomSheet.show(context)),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
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
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp)),
        subtitle: Text(subtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 12.sp)),
        trailing: Icon(Icons.chevron_right, color: context.secondaryTextColor, size: 24.sp),
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
                Text(l10n.verified, style: TextStyle(color: AppTheme.cyanAccent, fontWeight: FontWeight.bold, fontSize: 10.sp, letterSpacing: 1)),
                SizedBox(height: 4.h),
                Text(l10n.goldStandardProtection, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp)),
                SizedBox(height: 4.h),
                Text(l10n.strictlyVetted, style: TextStyle(color: context.secondaryTextColor, fontSize: 12.sp)),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Icon(Icons.bolt, color: AppTheme.cyanAccent, size: 48.sp),
        ],
      ),
    );
  }
}

class GlobalSearchDelegate extends SearchDelegate {
  List<Map<String, dynamic>> _getFeatures(AppLocalizations l10n) => [
    {'name': l10n.homeLoans, 'route': '/services/loan', 'icon': Icons.account_balance, 'cat': l10n.finance},
    {'name': l10n.construction, 'route': '/services/construction', 'icon': Icons.architecture, 'cat': l10n.servicesLabel},
    {'name': l10n.movers, 'route': '/services/movers', 'icon': Icons.local_shipping_outlined, 'cat': l10n.servicesLabel},
    {'name': l10n.legalDocs, 'route': '/services/legal', 'icon': Icons.gavel, 'cat': l10n.legal},
    {'name': l10n.marketplace, 'route': '/services/marketplace', 'icon': Icons.shopping_bag_outlined, 'cat': l10n.materials},
    {'name': 'Other Services', 'route': '/services/other', 'icon': Icons.home_repair_service_outlined, 'cat': l10n.servicesLabel},
    {'name': l10n.buy, 'route': '/properties', 'icon': Icons.home, 'cat': l10n.propertiesLabel},
    {'name': l10n.rent, 'route': '/properties', 'icon': Icons.vignette_outlined, 'cat': l10n.propertiesLabel},
    {'name': l10n.list, 'route': '/properties/add', 'icon': Icons.add_home_work_outlined, 'cat': l10n.activity},
    {'name': l10n.saved, 'route': '/properties/saved', 'icon': Icons.favorite_border, 'cat': l10n.activity},
    {'name': l10n.emiCalculator, 'route': '/services/emi-calculator', 'icon': Icons.calculate_outlined, 'cat': l10n.tools},
    {'name': l10n.liveSupport, 'route': '/profile/support', 'icon': Icons.headset_mic_outlined, 'cat': l10n.support},
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear, color: context.secondaryTextColor), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: context.iconColor),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = _getFeatures(l10n);
    final filtered = features.where((f) => 
      f['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
      f['cat'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();

    return Container(
      color: context.scaffoldColor,
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final feature = filtered[index];
          return ListTile(
            leading: Icon(feature['icon'] as IconData, color: context.iconColor),
            title: Text(feature['name'] as String, style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.bold)),
            subtitle: Text(feature['cat'] as String, style: TextStyle(color: context.secondaryTextColor, fontSize: 12.sp)),
            trailing: Icon(Icons.arrow_forward_ios, size: 14.w, color: context.secondaryTextColor),
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
        hintStyle: TextStyle(color: context.secondaryTextColor.withValues(alpha: 0.5)),
      ),
    );
  }
}
