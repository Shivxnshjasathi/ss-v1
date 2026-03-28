import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black87, size: 16),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text('My Profile', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
            ),
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
                      border: Border.all(color: Colors.grey.shade200, width: 4),
                    ),
                    child: const CircleAvatar(
                      radius: 54,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'),
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
                      child: const Icon(Icons.verified, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Shivansh Jasathi',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              '+91 98765 43210 • info@sampatti.com',
              style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'PREMIUM MEMBER',
                style: TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 40),

            // Profile Options Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ACCOUNT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    items: [
                      _buildMenuItem(context, 'Personal Information', Icons.person_outline, const Color(0xFF0066FF), () {}),
                      _buildMenuItem(context, 'Saved Properties', Icons.favorite_border, Colors.pinkAccent, () {}),
                      _buildMenuItem(context, 'My Documents', Icons.description_outlined, Colors.orange, () {}),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('PREFERENCES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    items: [
                      _buildMenuItem(context, 'App Settings', Icons.settings_outlined, Colors.grey[800]!, () {}),
                      _buildMenuItem(context, 'Help & Support', Icons.help_outline, Colors.teal, () {}),
                      _buildMenuItem(context, 'Terms & Privacy', Icons.privacy_tip_outlined, Colors.indigo, () {}),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                      label: const Text(
                        'LOG OUT',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
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
                  child: Divider(height: 1, color: Colors.grey.shade100),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Color iconColor, VoidCallback onTap) {
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
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
