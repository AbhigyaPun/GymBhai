import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/feedback_screen.dart';
import '../screens/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigate;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

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