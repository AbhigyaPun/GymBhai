import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'attendance_screen.dart';
import 'workout_screen.dart';
import 'progress_screen.dart';
import 'meals_screen.dart';
import '../widgets/app_drawer.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _progressKey = 0;
  int _homeKey = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Bhai'),
      ),
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onNavigate: (i) => setState(() => _currentIndex = i),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(key: ValueKey(_homeKey)),
          const AttendanceScreen(),
          const WorkoutScreen(),
          ProgressScreen(key: ValueKey(_progressKey)),
          const MealsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() {
          if (i == 3) _progressKey++;
          if (i == 0) _homeKey++;
          _currentIndex = i;
        }),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_outlined),
              activeIcon: Icon(Icons.qr_code_scanner),
              label: 'Attendance'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Workout'),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_outlined),
              activeIcon: Icon(Icons.show_chart),
              label: 'Progress'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'Meals'),
        ],
      ),
    );
  }
}