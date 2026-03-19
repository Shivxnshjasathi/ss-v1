import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicesHubScreen extends StatelessWidget {
  const ServicesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Services Hub',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
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
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
                 _buildServiceGridItem(context, 'Management', Icons.description_outlined, 'Rent Tracking', '/services'),
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
            _buildVerifiedBanner(),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.black87, size: 24),
                ),
                if (isHot)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D1FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Hot', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
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
        _buildListTile(context, 'Live Support', 'Chat with experts', Icons.headset_mic_outlined, () {}),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildVerifiedBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFD),
        borderRadius: BorderRadius.circular(16),
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
                Text('All service partners are strictly vetted.', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
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
