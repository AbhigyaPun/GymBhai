import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/feedback_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigate;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  void _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _DrawerItem(icon: Icons.home_outlined, label: 'Home', index: 0),
      _DrawerItem(icon: Icons.qr_code_scanner_outlined, label: 'Attendance', index: 1),
      _DrawerItem(icon: Icons.fitness_center_outlined, label: 'Workout', index: 2),
      _DrawerItem(icon: Icons.show_chart_outlined, label: 'Progress', index: 3),
      _DrawerItem(icon: Icons.restaurant_menu_outlined, label: 'Meals', index: 4),
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Main nav items
            ...items.map((item) {
              final selected = currentIndex == item.index;
              return ListTile(
                leading: Icon(
                  item.icon,
                  color: selected ? AppTheme.primaryGreen : AppTheme.textGrey,
                  size: 22,
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    color: selected ? AppTheme.primaryGreen : AppTheme.textDark,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                tileColor: selected ? AppTheme.primaryGreen.withValues(alpha: 0.08) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                onTap: () {
                  Navigator.pop(context);
                  onNavigate(item.index);
                },
              );
            }),
            const Divider(indent: 16, endIndent: 16),
            // Feedback
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: AppTheme.textGrey, size: 22),
              title: const Text('Feedback', style: TextStyle(fontSize: 15, color: AppTheme.textDark)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen()));
              },
            ),
            // Profile
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppTheme.textGrey, size: 22),
              title: const Text('Profile', style: TextStyle(fontSize: 15, color: AppTheme.textDark)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            const Spacer(),
            const Divider(indent: 16, endIndent: 16),
            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red, size: 22),
              title: const Text('Logout', style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.w500)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              onTap: () => _handleLogout(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String label;
  final int index;
  const _DrawerItem({required this.icon, required this.label, required this.index});
}