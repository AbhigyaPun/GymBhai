import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'account_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Gym Bhai'),
        actions: [IconButton(icon: const Icon(Icons.menu), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green header with avatar
            Container(
              width: double.infinity,
              color: AppTheme.primaryGreen,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    child: const Text('A',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Abhigya',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Member ID: M001',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Membership card
                  _SectionCard(
                    title: '🏷️  Membership',
                    children: [
                      _InfoRow(label: 'Plan', value: 'Premium Annual'),
                      _InfoRow(label: 'Status', value: 'Active', valueColor: AppTheme.primaryGreen),
                      _InfoRow(label: 'Expires', value: 'Feb 15, 2026'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Personal Information card
                  _SectionCard(
                    title: '👤  Personal Information',
                    actionLabel: 'Edit',
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
                    ),
                    children: [
                      _InfoRow(label: 'Email', value: 'abhigya@email.com'),
                      _InfoRow(label: 'Phone', value: '9823510522'),
                      _InfoRow(label: 'Age', value: '30 years'),
                      _InfoRow(label: 'Gender', value: 'Male'),
                      _InfoRow(label: 'Height', value: '175 cm'),
                      _InfoRow(label: 'Weight', value: '75.5 kg'),
                      _InfoRow(label: 'Address', value: 'Kathmandu'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Fitness Profile card
                  _SectionCard(
                    title: '💪  Fitness Profile',
                    actionLabel: 'Edit',
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
                    ),
                    children: [
                      _InfoRow(label: 'Fitness Goal', value: 'Muscle Building'),
                      _InfoRow(label: 'Fitness Level', value: 'Intermediate'),
                      _InfoRow(label: 'Diet Type', value: 'Non-Vegetarian'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Settings card
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                          child: Text('⚙️  Settings',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.notifications_outlined, color: AppTheme.textGrey, size: 20),
                          title: const Text('Notifications', style: TextStyle(fontSize: 14)),
                          trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          leading: const Icon(Icons.manage_accounts_outlined, color: AppTheme.textGrey, size: 20),
                          title: const Text('Account Settings', style: TextStyle(fontSize: 14)),
                          trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Log Out button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                    label: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _confirmLogout(context),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Section Card ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionCard({
    required this.title,
    required this.children,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                if (actionLabel != null)
                  GestureDetector(
                    onTap: onAction,
                    child: Text(actionLabel!,
                        style: const TextStyle(fontSize: 13, color: AppTheme.primaryGreen, fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}