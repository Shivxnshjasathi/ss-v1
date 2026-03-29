import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';

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
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark 
                 ? Colors.black.withValues(alpha: 0.3) 
                 : Colors.black.withValues(alpha: 0.05), 
              blurRadius: 10, 
              offset: const Offset(0, -5))
          ]
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
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.homeLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_outlined),
              activeIcon: const Icon(Icons.grid_view),
              label: l10n.servicesLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border),
              activeIcon: const Icon(Icons.favorite),
              label: l10n.savedLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.forum_outlined),
              activeIcon: const Icon(Icons.forum),
              label: l10n.messagesLabel,
            ),
          ],
        ),
      ),
    );
  }
}
