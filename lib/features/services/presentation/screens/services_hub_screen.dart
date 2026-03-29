import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/widgets/contact_bottom_sheet.dart';

class ServicesHubScreen extends StatelessWidget {
  const ServicesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          'Services Hub',
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
              'Financial\nEcosystem',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Secure, end-to-end property solutions\npowered by Sampatti.',
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
                 _buildServiceGridItem(context, 'Home Loans', Icons.account_balance, 'Instant Approval', '/services/loan', isHot: true),
                 _buildServiceGridItem(context, 'Construction', Icons.architecture, 'Top Contractors', '/services/construction'),
                 _buildServiceGridItem(context, 'Movers', Icons.local_shipping_outlined, 'Safe Relocation', '/services/movers'),
                 _buildServiceGridItem(context, 'Legal Docs', Icons.gavel, 'Verified Lawyers', '/services/legal'),
                 _buildServiceGridItem(context, 'Marketplace', Icons.shopping_bag_outlined, 'Materials & More', '/services/marketplace'),
                 _buildServiceGridItem(context, 'Service Tracking', Icons.receipt_long_outlined, 'Track Orders', '/services/tracking'),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'TOOLS & SUPPORT',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            _buildToolsSupportList(context),
            const SizedBox(height: 32),
            _buildVerifiedBanner(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGridItem(BuildContext context, String title, IconData icon, String subtitle, String route, {bool isHot = false}) {
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
                if (isHot)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Hot', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 10, fontWeight: FontWeight.bold)),
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

  Widget _buildToolsSupportList(BuildContext context) {
    return Column(
      children: [
        _buildListTile(context, 'EMI Calculator', 'Plan your finances', Icons.calculate_outlined, () {}),
        const SizedBox(height: 12),
        _buildListTile(context, 'Live Support', 'Chat with experts', Icons.headset_mic_outlined, () => ContactBottomSheet.show(context)),
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

  Widget _buildVerifiedBanner(BuildContext context) {
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
                const Text('VERIFIED', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                const SizedBox(height: 4),
                const Text('Gold Standard Protection', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 4),
                Text('All service partners are strictly vetted.', style: TextStyle(color: context.secondaryTextColor, fontSize: 12)),
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
  final List<Map<String, dynamic>> _features = [
    {'name': 'Home Loans', 'route': '/services/loan', 'icon': Icons.account_balance, 'cat': 'Financial'},
    {'name': 'Construction', 'route': '/services/construction', 'icon': Icons.architecture, 'cat': 'Services'},
    {'name': 'Movers & Packers', 'route': '/services/movers', 'icon': Icons.local_shipping_outlined, 'cat': 'Services'},
    {'name': 'Legal Documents', 'route': '/services/legal', 'icon': Icons.gavel, 'cat': 'Legal'},
    {'name': 'Marketplace', 'route': '/services/marketplace', 'icon': Icons.shopping_bag_outlined, 'cat': 'Materials'},
    {'name': 'Service Tracking', 'route': '/services/tracking', 'icon': Icons.receipt_long_outlined, 'cat': 'Activity'},
    {'name': 'Buy Property', 'route': '/properties', 'icon': Icons.home, 'cat': 'Properties'},
    {'name': 'Rent/Lease', 'route': '/properties', 'icon': Icons.vignette_outlined, 'cat': 'Properties'},
    {'name': 'List Property', 'route': '/properties/add', 'icon': Icons.add_business_outlined, 'cat': 'Activity'},
    {'name': 'Saved Properties', 'route': '/properties/saved', 'icon': Icons.favorite_border, 'cat': 'Activity'},
    {'name': 'EMI Calculator', 'route': '/services/loan', 'icon': Icons.calculate_outlined, 'cat': 'Tools'},
    {'name': 'Live Support', 'route': '/profile/support', 'icon': Icons.headset_mic_outlined, 'cat': 'Support'},
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
    final filtered = _features.where((f) => 
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
