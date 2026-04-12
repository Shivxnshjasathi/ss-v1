import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

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
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: context.scaffoldColor,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: context.isDarkMode
              ? Colors.white54
              : Colors.grey[400],
          selectedFontSize: 11.sp,
          unselectedFontSize: 11.sp,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.house, size: 22.w),
              activeIcon: Icon(LucideIcons.house, size: 24.w),
              label: l10n.homeLabel,
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.layoutGrid, size: 22.w),
              activeIcon: Icon(LucideIcons.layoutGrid, size: 24.w),
              label: l10n.servicesLabel,
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.heart, size: 22.w),
              activeIcon: Icon(LucideIcons.heart, size: 24.w),
              label: l10n.savedLabel,
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageSquare, size: 22.w),
              activeIcon: Icon(LucideIcons.messageSquare, size: 24.w),
              label: l10n.messagesLabel,
            ),
          ],
        ),
      ),
    );
  }
}
