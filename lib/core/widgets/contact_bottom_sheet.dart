import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';

class ContactBottomSheet extends StatelessWidget {
  const ContactBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ContactBottomSheet(),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      decoration: BoxDecoration(
        color: context.scaffoldColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.w)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.liveSupportUpper,
                    style: TextStyle(
                      color: const Color(0xFF00D1FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10n.contactSampattiBazar,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18.sp,
                      color: context.primaryTextColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close, color: context.secondaryTextColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          _buildContactTile(
            context,
            icon: Icons.location_on_outlined,
            title: l10n.ourOffice,
            subtitle: l10n.officeAddress,
            onTap: () => _launchUrl('https://www.google.com/maps/search/?api=1&query=Shop+No+2,+481/1,+Bilhari,+Mandla+Road,+Jabalpur,+M.P.'),
          ),
          SizedBox(height: 16.h),
          _buildContactTile(
            context,
            icon: Icons.call_outlined,
            title: l10n.phoneNumber,
            subtitle: '+91 766 685 0012',
            onTap: () => _launchUrl('tel:+917666850012'),
          ),
          SizedBox(height: 16.h),
          _buildContactTile(
            context,
            icon: Icons.email_outlined,
            title: l10n.emailAddress,
            subtitle: 'info@sampattibazar.com',
            onTap: () => _launchUrl('mailto:info@sampattibazar.com'),
          ),
          SizedBox(height: 32.h),
          Center(
            child: Text(
              l10n.available247,
              style: TextStyle(color: Colors.grey, fontSize: 10.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 24.w),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, color: context.primaryTextColor)),
                  SizedBox(height: 4.h),
                  Text(subtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 11.sp, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.open_in_new, size: 14.w, color: context.secondaryTextColor),
          ],
        ),
      ),
    );
  }
}
