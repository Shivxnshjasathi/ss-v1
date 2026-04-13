import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: widget.navigationShell,
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
              selectedIndex: widget.navigationShell.currentIndex,
              textStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryBlue,
              ),
              onTabChange: (index) {
                widget.navigationShell.goBranch(
                  index,
                  initialLocation: index == widget.navigationShell.currentIndex,
                );
              },
              tabs: [
                GButton(
                  icon: LucideIcons.house,
                  text: l10n.homeLabel,
                  leading: DescribedFeatureOverlay(
                    featureId: 'nav_home_id',
                    tapTarget: Icon(LucideIcons.house, color: AppTheme.primaryBlue),
                    title: const Text('Home Dashboard'),
                    description: const Text('Find featured properties and quick service links.'),
                    backgroundColor: AppTheme.primaryBlue,
                    targetColor: Colors.white,
                    child: Icon(LucideIcons.house, color: widget.navigationShell.currentIndex == 0 ? AppTheme.primaryBlue : (context.isDarkMode ? Colors.white54 : Colors.grey[600])),
                  ),
                ),
                GButton(
                  icon: LucideIcons.layoutGrid,
                  text: l10n.servicesLabel,
                  leading: DescribedFeatureOverlay(
                    featureId: 'nav_services_id',
                    tapTarget: Icon(LucideIcons.layoutGrid, color: AppTheme.primaryBlue),
                    title: const Text('Services Hub'),
                    description: const Text('Access Loans, Construction, Legal, and Handyman services.'),
                    backgroundColor: AppTheme.primaryBlue,
                    targetColor: Colors.white,
                    child: Icon(LucideIcons.layoutGrid, color: widget.navigationShell.currentIndex == 1 ? AppTheme.primaryBlue : (context.isDarkMode ? Colors.white54 : Colors.grey[600])),
                  ),
                ),
                GButton(
                  icon: LucideIcons.heart,
                  text: l10n.savedLabel,
                  leading: DescribedFeatureOverlay(
                    featureId: 'nav_saved_id',
                    tapTarget: Icon(LucideIcons.heart, color: AppTheme.primaryBlue),
                    title: const Text('Saved Interest'),
                    description: const Text('Quickly access properties you have marked as favorites.'),
                    backgroundColor: AppTheme.primaryBlue,
                    targetColor: Colors.white,
                    child: Icon(LucideIcons.heart, color: widget.navigationShell.currentIndex == 2 ? AppTheme.primaryBlue : (context.isDarkMode ? Colors.white54 : Colors.grey[600])),
                  ),
                ),
                GButton(
                  icon: LucideIcons.messageSquare,
                  text: l10n.messagesLabel,
                  leading: DescribedFeatureOverlay(
                    featureId: 'nav_chats_id',
                    tapTarget: Icon(LucideIcons.messageSquare, color: AppTheme.primaryBlue),
                    title: const Text('Chat & Messages'),
                    description: const Text('Directly communicate with property owners and service providers.'),
                    backgroundColor: AppTheme.primaryBlue,
                    targetColor: Colors.white,
                    child: Icon(LucideIcons.messageSquare, color: widget.navigationShell.currentIndex == 3 ? AppTheme.primaryBlue : (context.isDarkMode ? Colors.white54 : Colors.grey[600])),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
