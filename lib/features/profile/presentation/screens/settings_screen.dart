import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/providers/theme_provider.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/providers/locale_provider.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.settings, style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900)),
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
            _buildSection(context, l10n.appearance, [
              _buildSettingTile(
                context, 
                l10n.darkMode, 
                Icons.dark_mode_outlined, 
                trailing: Switch.adaptive(
                  value: isDark,
                  activeColor: AppTheme.primaryBlue,
                  onChanged: (_) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
              ),
            ]),
            const SizedBox(height: 32),
            _buildSection(context, l10n.notifications, [
              _buildSettingTile(context, l10n.pushNotifications, Icons.notifications_none_outlined, trailing: _buildSwitch(true)),
              _buildSettingTile(context, l10n.emailUpdates, Icons.alternate_email_outlined, trailing: _buildSwitch(false)),
            ]),
            const SizedBox(height: 32),
            _buildSection(context, l10n.general, [
              _buildSettingTile(
                context, 
                l10n.language, 
                Icons.language_outlined, 
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locale.languageCode == 'en' ? l10n.english : l10n.hindi, 
                      style: TextStyle(color: context.secondaryTextColor, fontSize: 13, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.swap_horiz, size: 16, color: context.secondaryTextColor),
                  ],
                ),
                onTap: () {
                  ref.read(localeProvider.notifier).toggleLocale();
                },
              ),
              _buildSettingTile(context, l10n.locationServices, Icons.location_on_outlined, trailing: _buildSwitch(true)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: context.secondaryTextColor, letterSpacing: 1)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(BuildContext context, String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue, size: 20),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.primaryTextColor)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitch(bool value) {
    return Switch.adaptive(
      value: value,
      activeColor: AppTheme.primaryBlue,
      onChanged: (_) {},
    );
  }
}
