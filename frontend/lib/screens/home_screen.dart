import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back, Abhigya!',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Ready to crush your fitness goals today?',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats Row
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.calendar_today_outlined, value: '24', label: 'Days Active')),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.local_fire_department_outlined, value: '5', label: 'Streak', iconColor: Colors.orange)),
              ],
            ),
            const SizedBox(height: 20),
            // Today's Workout
            const Text("Today's Workout", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: const [
                  _WorkoutItem(name: 'Bench Press', sets: '4 sets × 8-10 reps'),
                  Divider(height: 1, indent: 16, endIndent: 16),
                  _WorkoutItem(name: 'Incline Dumbbell Press', sets: '3 sets × 10-12 reps'),
                  Divider(height: 1, indent: 16, endIndent: 16),
                  _WorkoutItem(name: 'Cable Flyes', sets: '3 sets × 12-15 reps'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Notifications
            Row(
              children: const [
                Icon(Icons.notifications_outlined, size: 20, color: AppTheme.textDark),
                SizedBox(width: 6),
                Text('Notifications', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              ],
            ),
            const SizedBox(height: 10),
            _NotificationCard(
              message: 'Your subscription expires in 5 days',
              color: Colors.orange.shade50,
              borderColor: Colors.orange.shade200,
              textColor: Colors.orange.shade800,
            ),
            const SizedBox(height: 8),
            _NotificationCard(
              message: 'New workout plan available!',
              color: Colors.blue.shade50,
              borderColor: Colors.blue.shade200,
              textColor: Colors.blue.shade800,
            ),
            const SizedBox(height: 8),
            _NotificationCard(
              message: 'Congrats! You hit your weekly goal 🎉',
              color: Colors.green.shade50,
              borderColor: Colors.green.shade200,
              textColor: Colors.green.shade800,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = AppTheme.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
          ],
        ),
      ),
    );
  }
}

class _WorkoutItem extends StatelessWidget {
  final String name;
  final String sets;
  const _WorkoutItem({required this.name, required this.sets});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
          const SizedBox(height: 2),
          Text(sets, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String message;
  final Color color;
  final Color borderColor;
  final Color textColor;
  const _NotificationCard({required this.message, required this.color, required this.borderColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: TextStyle(fontSize: 13, color: textColor)),
    );
  }
}