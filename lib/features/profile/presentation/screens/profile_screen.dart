import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/providers/theme_provider.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Icon(
              LucideIcons.chevronLeft,
              color: context.iconColor,
              size: 20.w,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.myProfile,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.primaryTextColor,$
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon, size: 20.w),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(LucideIcons.bell, size: 20.w),
            onPressed: () {},
          ),
        ],
      ).animate().fadeIn().slideY(begin: -0.1, end: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 24.h),
            // Avatar & Name Section
            Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.borderColor,
                            width: 4.w,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 54.w,
                          backgroundColor: context.isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          child: Text(
                            (userAsync.value?.name ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.w900,
                              color: context.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0.h,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.scaffoldColor,
                              width: 3.w,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.badgeCheck,
                            color: Colors.white,
                            size: 14.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            Text(
              userAsync.value?.name ?? 'User',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 24.sp,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            SizedBox(height: 4.h),
            Text(
              '${userAsync.value?.phoneNumber ?? '+91 XXXXX XXXXX'} • ${userAsync.value?.email ?? 'No email'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.secondaryTextColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.w),
                  ),
                  child: Text(
                    userAsync.value?.role?.toUpperCase() ?? l10n.premiumMember,
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 10.sp,
                      letterSpacing: 1.0,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),
                if (userAsync.value?.isPreApproved == true) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(20.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.badgeCheck,
                          color: Colors.white,
                          size: 12.w,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'PRE-APPROVED: ₹${(userAsync.value!.preApprovalAmount! / 100000).toStringAsFixed(1)} L',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 10.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
                ],
              ],
            ),
            SizedBox(height: 40.h),

            // Profile Options Menu
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.account,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12.sp,
                      color: context.secondaryTextColor,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildMenuCard(
                    context,
                    items: [
                      _buildMenuItem(
                        context,
                        l10n.personalInfo,
                        LucideIcons.user,
                        AppTheme.primaryBlue,
                        () => context.push('/profile/edit'),
                      ),
                      _buildMenuItem(
                        context,
                        l10n.savedProperties,
                        LucideIcons.heart,
                        Colors.pinkAccent,
                        () => context.go('/saved'),
                      ),
                      _buildMenuItem(
                        context,
                        l10n.myDocuments,
                        LucideIcons.fileText,
                        Colors.orange,
                        () => context.push('/profile/documents'),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    l10n.preferences,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12.sp,
                      color: context.secondaryTextColor,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildMenuCard(
                    context,
                    items: [
                      _buildMenuItem(
                        context,
                        l10n.appSettings,
                        LucideIcons.settings,
                        Colors.blueGrey,
                        () => context.push('/profile/settings'),
                      ),
                      _buildMenuItem(
                        context,
                        l10n.helpSupport,
                        LucideIcons.lifeBuoy,
                        Colors.teal,
                        () => context.push('/profile/support'),
                      ),
                      _buildMenuItem(
                        context,
                        l10n.termsPrivacy,
                        LucideIcons.shieldCheck,
                        Colors.indigo,
                        () {},
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(userRepositoryProvider).clearCache();
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) context.go('/login');
                      },
                      icon: Icon(
                        LucideIcons.logOut,
                        color: Colors.redAccent,
                        size: 18.w,
                      ),
                      label: Text(
                        l10n.logOut.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.redAccent.withOpacity(0.3),
                          width: 1.5.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.w),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    ),
                  ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1, end: 0),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required List<Widget> items}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget item = entry.value;
          return Column(
            children: [
              item,
              if (idx != items.length - 1)
                Padding(
                  padding: EdgeInsets.only(left: 64.0.w),
                  child: Divider(height: 1.h, color: context.borderColor),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Icon(icon, color: iconColor, size: 20.w),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 14.sp,
          color: context.primaryTextColor,
        ),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 16.w,
        color: context.secondaryTextColor.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }
}
