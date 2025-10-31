import 'package:flutter/material.dart';
import '../app_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const userName = "Patient Name";
    const userEmail = "patient@example.com";

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: cs.primary.withOpacity(0.1),
                        child: Icon(Icons.person_outline_rounded, color: cs.primary, size: 48),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: cs.primary,
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(userEmail, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Account Settings'),
          _SettingsCard(items: [
            _SettingsItem(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit profile (coming soon)')),
                );
              },
            ),
            _SettingsItem(
              icon: Icons.location_on_outlined,
              title: 'My Addresses',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Addresses (coming soon)')),
                );
              },
            ),
          ]),
          const SizedBox(height: 20),
          const _SectionHeader(title: 'General'),
          _SettingsCard(items: [
            _SettingsItem(
              icon: Icons.receipt_long_outlined,
              title: 'My Orders',
              onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
            ),
            _SettingsItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support (coming soon)')),
                );
              },
            ),
          ]),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: items.map((item) {
          final isLast = item == items.last;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: item.onTap,
              ),
              if (!isLast) const Divider(indent: 16, endIndent: 16, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _SettingsItem({required this.icon, required this.title, required this.onTap});
}
