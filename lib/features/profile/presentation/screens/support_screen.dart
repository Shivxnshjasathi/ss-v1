import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/widgets/contact_bottom_sheet.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text('Help & Support', style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900)),
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('POPULAR TOPICS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: context.secondaryTextColor, letterSpacing: 1)),
            const SizedBox(height: 16),
            _buildFAQTile(context, 'How to list a new property?'),
            _buildFAQTile(context, 'How to track movers & packers?'),
            _buildFAQTile(context, 'Is property document verification secure?'),
            _buildFAQTile(context, 'How to book a site visit?'),
            const SizedBox(height: 40),
            Text('CONTACT US', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: context.secondaryTextColor, letterSpacing: 1)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => ContactBottomSheet.show(context),
              child: _buildContactCard(context, Icons.support_agent, 'Live Chat Support', 'Response time: < 2 mins'),
            ),
            const SizedBox(height: 16),
            _buildContactCard(context, Icons.email_outlined, 'Email Support', 'support@sampattibazar.com'),
            const SizedBox(height: 16),
            _buildContactCard(context, Icons.call_outlined, 'Call Us', '+91 1800-419-5555'),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(BuildContext context, String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: ListTile(
        title: Text(question, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.primaryTextColor)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.primaryBlue),
        onTap: () {},
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: context.primaryTextColor)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
