import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/widgets/contact_bottom_sheet.dart';
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
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.financialEcosystem,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.servicesSubtitle,
              style: TextStyle(color: context.secondaryTextColor, fontSize: 14),
            ),
            const SizedBox(height: 24),
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
                 _buildServiceGridItem(context, l10n.serviceTracking, Icons.receipt_long_outlined, l10n.trackOrders, '/services/tracking'),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              l10n.toolsAndSupport,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            _buildToolsSupportList(context, l10n),
            const SizedBox(height: 32),
            _buildVerifiedBanner(context, l10n),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGridItem(BuildContext context, String title, IconData icon, String subtitle, String route, {bool isHot = false, String? hotLabel}) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: context.primaryTextColor, size: 24),
                ),
                if (isHot && hotLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(hotLabel, style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: context.secondaryTextColor, fontSize: 10),
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
        const SizedBox(height: 12),
        _buildListTile(context, l10n.liveSupport, l10n.chatWithExperts, Icons.headset_mic_outlined, () => ContactBottomSheet.show(context)),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: context.primaryTextColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: context.secondaryTextColor),
      ),
    );
  }

  Widget _buildVerifiedBanner(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.verified, style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(l10n.goldStandardProtection, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 4),
                Text(l10n.strictlyVetted, style: TextStyle(color: context.secondaryTextColor, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.bolt, color: Color(0xFF00D1FF), size: 48),
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
    {'name': l10n.serviceTracking, 'route': '/services/tracking', 'icon': Icons.receipt_long_outlined, 'cat': l10n.activity},
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
      IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () => query = ''),
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
            subtitle: Text(feature['cat'] as String, style: TextStyle(color: context.secondaryTextColor, fontSize: 12)),
            trailing: Icon(Icons.arrow_forward_ios, size: 14, color: context.secondaryTextColor),
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
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }
}
