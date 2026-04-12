import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.scaffoldColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: GNav(
              rippleColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              hoverColor: AppTheme.primaryBlue.withValues(alpha: 0.05),
              gap: 8,
              activeColor: AppTheme.primaryBlue,
              iconSize: 22.sp,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              color: context.isDarkMode ? Colors.white54 : Colors.grey[600],
              selectedIndex: navigationShell.currentIndex,
              textStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryBlue,
              ),
              onTabChange: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              tabs: [
                GButton(
                  icon: LucideIcons.house,
                  text: l10n.homeLabel,
                ),
                GButton(
                  icon: LucideIcons.layoutGrid,
                  text: l10n.servicesLabel,
                ),
                GButton(
                  icon: LucideIcons.heart,
                  text: l10n.savedLabel,
                ),
                GButton(
                  icon: LucideIcons.messageSquare,
                  text: l10n.messagesLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
