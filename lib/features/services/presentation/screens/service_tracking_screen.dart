import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';

class ServiceTrackingScreen extends StatelessWidget {
  const ServiceTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: context.iconColor, size: 16),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text('Tracking Hub', style: TextStyle(fontWeight: FontWeight.w900, color: context.primaryTextColor, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: context.iconColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'Active Requests',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Monitor live updates on your bookings, loans, and services.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
              ),
            ),
            const SizedBox(height: 32),
            
            // Home Loan Tracker
            _buildTrackingCard(
              context,
              title: 'Home Loan Application',
              provider: 'Sampatti Finance',
              statusText: 'In Review',
              statusColor: Colors.amber[700]!,
              icon: Icons.account_balance,
              iconColor: Colors.blue,
              date: 'Oct 24, 2026',
              progress: 0.6,
              details: 'Document verification in progress. Expected completion in 2 days.',
              actionText: 'View Details',
            ),
            
            // Movers Booking
            _buildTrackingCard(
              context,
              title: 'Premium Relocation Service',
              provider: 'Express Movers Plus',
              statusText: 'Scheduled',
              statusColor: Colors.blue[700]!,
              icon: Icons.local_shipping_outlined,
              iconColor: const Color(0xFF00E5FF),
              date: 'Nov 02, 2026',
              progress: 0.3,
              details: 'Route planned from Andheri to Bandra West. Truck allocated.',
              actionText: 'Track Driver',
            ),
            
            // Property Tour
            _buildTrackingCard(
              context,
              title: 'Property Viewing',
              provider: 'The Glass Pavilion',
              statusText: 'Confirmed',
              statusColor: Colors.green[600]!,
              icon: Icons.home_work_outlined,
              iconColor: Colors.indigo,
              date: 'Tomorrow, 10:00 AM',
              progress: 1.0,
              details: 'Agent Elena Rodriguez will meet you at the property main gate.',
              actionText: 'Get Directions',
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Text('Past History', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: context.primaryTextColor)),
            ),
            
            _buildPastHistoryTile(context, 'Legal Consultation', 'Property Agreement Review', 'Oct 15, 2026', Icons.gavel, Colors.green),
            _buildPastHistoryTile(context, 'Construction Visit', 'Site Assessment', 'Sep 28, 2026', Icons.architecture, Colors.grey),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingCard(
    BuildContext context, {
    required String title,
    required String provider,
    required String statusText,
    required Color statusColor,
    required IconData icon,
    required Color iconColor,
    required String date,
    required double progress,
    required String details,
    required String actionText,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.3),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText.toUpperCase(),
                              style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$provider • $date',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: context.borderColor),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Progress Status', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                    const Spacer(),
                    Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  details,
                  style: TextStyle(color: Colors.grey[800], fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  actionText,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: context.primaryTextColor),
                ),
                Icon(Icons.arrow_forward_ios, size: 12, color: context.iconColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastHistoryTile(BuildContext context, String title, String subtitle, String date, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: context.primaryTextColor)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
