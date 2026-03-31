import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/providers/theme_provider.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';

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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: context.iconColor,
              size: 16,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.myProfile,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.primaryTextColor,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Avatar & Name Section
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.borderColor, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: context.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Text(
                        (userAsync.value?.name ?? 'U').substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: context.isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E5FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              userAsync.value?.name ?? 'User',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: -0.5,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userAsync.value?.phoneNumber ?? '+91 XXXXX XXXXX',
              style: TextStyle(
                color: context.secondaryTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                userAsync.value?.role?.toUpperCase() ?? l10n.premiumMember,
                style: const TextStyle(
                  color: Color(0xFF0066FF),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Profile Options Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.account,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: context.secondaryTextColor,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    items: [
                      _buildMenuItem(
                        context,
                        l10n.personalInfo,
                        Icons.person_outline,
                        const Color(0xFF0066FF),
                        () => context.push('/profile/edit'),
                      ),
                      _buildMenuItem(
                        context,
                        l10n.savedProperties,
                        Icons.favorite_border,
                        Colors.pinkAccent,
                        () => context.go('/saved'),
                      ),
                      _buildMenuItem(
                        context,
                        l10n.myDocuments,
                        Icons.description_outlined,
                        Colors.orange,
                        () => context.push('/profile/documents'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.preferences,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: context.secondaryTextColor,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    items: [
                      _buildMenuItem(
                        context,
                        l10n.appSettings,
                        Icons.settings_outlined,
                        Colors.grey[800]!,
                        () => context.push('/profile/settings'),
                      ),
                      _buildMenuItem(
                        context,
                        l10n.helpSupport,
                        Icons.help_outline,
                        Colors.teal,
                        () => context.push('/profile/support'),
                      ),
                      _buildMenuItem(
                        context,
                        l10n.termsPrivacy,
                        Icons.privacy_tip_outlined,
                        Colors.indigo,
                        () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(userRepositoryProvider).clearCache();
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) context.go('/login');
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      label: Text(
                        l10n.logOut,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.redAccent.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
        borderRadius: BorderRadius.circular(16),
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
                  padding: const EdgeInsets.only(left: 64.0),
                  child: Divider(height: 1, color: context.borderColor),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 14,
          color: context.primaryTextColor,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: context.secondaryTextColor,
      ),
      onTap: onTap,
    );
  }
}
