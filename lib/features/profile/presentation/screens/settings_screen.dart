import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/providers/theme_provider.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/providers/locale_provider.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

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
        padding: EdgeInsets.all(24.w),
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
                  activeTrackColor: AppTheme.primaryBlue,
                  onChanged: (_) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
              ),
            ]),
            SizedBox(height: 32.h),
            _buildSection(context, l10n.notifications, [
              _buildSettingTile(context, l10n.pushNotifications, Icons.notifications_none_outlined, trailing: _buildSwitch(true)),
              _buildSettingTile(context, l10n.emailUpdates, Icons.alternate_email_outlined, trailing: _buildSwitch(false)),
            ]),
            SizedBox(height: 32.h),
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
                      style: TextStyle(color: context.secondaryTextColor, fontSize: 13.sp, fontWeight: FontWeight.bold)
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.swap_horiz, size: 16.w, color: context.secondaryTextColor),
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
        Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10.sp, color: context.secondaryTextColor, letterSpacing: 1)),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16.w),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(BuildContext context, String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue, size: 20.w),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: context.primaryTextColor)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitch(bool value) {
    return Switch.adaptive(
      value: value,
      activeTrackColor: AppTheme.primaryBlue,
      onChanged: (_) {},
    );
  }
}
