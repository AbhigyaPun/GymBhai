import 'package:flutter/material.dart';

class GymBhaiApp extends StatelessWidget {
  const GymBhaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Bhai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('Gym Bhai Frontend Ready ✅')),
      ),
    );
  }
}
