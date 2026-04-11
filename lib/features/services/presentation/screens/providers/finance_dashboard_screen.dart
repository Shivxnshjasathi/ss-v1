import 'package:flutter/material.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class FinanceDashboardScreen extends StatelessWidget {
  const FinanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        title: Text(l10n.loanExpertDashboard, style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.request_quote_outlined, size: 80.w, color: context.iconColor.withOpacity(0.5)),
            SizedBox(height: 16.h),
            Text(l10n.loanLeads, style: TextStyle(color: context.primaryTextColor, fontSize: 24.sp, fontWeight: FontWeight.w900)),
            SizedBox(height: 8.h),
            Text(l10n.noLeadsYet, style: TextStyle(color: context.secondaryTextColor)),
          ],
        ),
      ),
    );
  }
}
