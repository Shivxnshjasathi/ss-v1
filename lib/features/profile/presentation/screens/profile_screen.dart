import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/shared/widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Shivansh Jasathi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '+91 98765 43210',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Seeker, Owner & Landlord',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 32),
            AppCard(
              child: Column(
                children: [
                  _buildProfileMenuItem(context, 'Edit Profile', Icons.person_outline, () {}),
                  const Divider(),
                  _buildProfileMenuItem(context, 'Saved Properties', Icons.favorite_outline, () {}),
                  const Divider(),
                  _buildProfileMenuItem(context, 'Switch Role', Icons.swap_horiz, () {
                    context.push('/role-selection');
                  }),
                  const Divider(),
                  _buildProfileMenuItem(context, 'App Settings', Icons.settings_outlined, () {}),
                  const Divider(),
                  _buildProfileMenuItem(context, 'Help & Support', Icons.help_outline, () {}),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () {
                context.go('/login');
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
