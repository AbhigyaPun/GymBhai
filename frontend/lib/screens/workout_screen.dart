import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int _selectedDay = 0;

  final List<Map<String, dynamic>> _days = [
    {
      'label': 'Day 1',
      'title': 'Push Day',
      'subtitle': '5 exercises',
      'exercises': [
        {'name': 'Bench Press', 'detail': '4 sets  •  6–8 reps'},
        {'name': 'Overhead Press', 'detail': '3 sets  •  8 reps'},
        {'name': 'Incline Dumbbell Press', 'detail': '3 sets  •  10 reps'},
        {'name': 'Triceps Dips', 'detail': '3 sets  •  12 reps'},
        {'name': 'Lateral Raises', 'detail': '3 sets  •  15 reps'},
      ],
    },
    {
      'label': 'Day 2',
      'title': 'Pull Day',
      'subtitle': '5 exercises',
      'exercises': [
        {'name': 'Deadlift', 'detail': '4 sets  •  5 reps'},
        {'name': 'Pull-Ups', 'detail': '3 sets  •  8 reps'},
        {'name': 'Barbell Rows', 'detail': '3 sets  •  10 reps'},
        {'name': 'Face Pulls', 'detail': '3 sets  •  15 reps'},
        {'name': 'Bicep Curls', 'detail': '3 sets  •  12 reps'},
      ],
    },
    {
      'label': 'Day 3',
      'title': 'Leg Day',
      'subtitle': '4 exercises',
      'exercises': [
        {'name': 'Squats', 'detail': '4 sets  •  8 reps'},
        {'name': 'Leg Press', 'detail': '3 sets  •  12 reps'},
        {'name': 'Romanian Deadlift', 'detail': '3 sets  •  10 reps'},
        {'name': 'Calf Raises', 'detail': '4 sets  •  15 reps'},
      ],
    },
  ];

  final List<Map<String, String>> _recentActivity = [
    {'day': 'Push Day', 'date': '2025-02-20', 'detail': '2 exercises completed'},
    {'day': 'Pull Day', 'date': '2025-02-18', 'detail': '2 exercises completed'},
    {'day': 'Leg Day', 'date': '2025-02-16', 'detail': '2 exercises completed'},
  ];

  @override
  Widget build(BuildContext context) {
    final day = _days[_selectedDay];
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: AppTheme.primaryGreen,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Workout Plan', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text('Intermediate – Muscle Gain', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const Text('Push / Pull / Legs  •  5 Days', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Templates / History buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.grid_view, size: 16),
                          label: const Text('Templates\nView all plans', textAlign: TextAlign.center),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const WorkoutTemplatesScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.history, size: 16),
                          label: const Text('History\nPast workouts', textAlign: TextAlign.center),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Day selector
                  Row(
                    children: List.generate(_days.length, (i) {
                      final selected = _selectedDay == i;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDay = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.primaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: selected ? AppTheme.primaryGreen : AppTheme.dividerColor),
                            ),
                            child: Text(
                              _days[i]['label'],
                              style: TextStyle(
                                color: selected ? Colors.white : AppTheme.textGrey,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // Exercise list
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(day['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                                  Text(day['subtitle'], style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                                ],
                              ),
                              const Icon(Icons.fitness_center, color: AppTheme.primaryGreen, size: 22),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...List.generate((day['exercises'] as List).length, (i) {
                            final ex = (day['exercises'] as List)[i];
                            return Column(
                              children: [
                                if (i > 0) const Divider(height: 1),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(ex['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                  subtitle: Text(ex['detail'], style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                                  trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Recent Activity', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: _recentActivity.map((item) {
                        return Column(
                          children: [
                            if (_recentActivity.indexOf(item) > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['day']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                      Text(item['detail']!, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                                    ],
                                  ),
                                  Text(item['date']!, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Workout Templates Screen ──────────────────────────────────────────────────
class WorkoutTemplatesScreen extends StatelessWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Workout Templates'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose your training style', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
            const SizedBox(height: 16),
            _TemplateSection(
              dot: AppTheme.primaryGreen,
              title: 'Beginner Workouts',
              templates: const [
                _TemplateInfo('Beginner – General Fitness', 'Full body + Cardio\n3 Days / Week'),
                _TemplateInfo('Beginner – Fat Loss', 'Full body + cardio\n3-4 days'),
                _TemplateInfo('Beginner – Muscle Gain', 'Upper / Lower\n4 Days'),
              ],
            ),
            const SizedBox(height: 16),
            _TemplateSection(
              dot: Colors.orange,
              title: 'Intermediate Workouts',
              templates: const [
                _TemplateInfo('Intermediate – Muscle Gain', 'Push / Pull / Legs\n5 Days'),
                _TemplateInfo('Intermediate – Strength', 'Upper / Lower Strength\n4 days'),
              ],
            ),
            const SizedBox(height: 16),
            _TemplateSection(
              dot: Colors.red,
              title: 'Advanced Workouts',
              templates: const [
                _TemplateInfo('Advanced – Strength', 'Powerlifting Style\n4-5 Days'),
                _TemplateInfo('Advanced – Bodybuilding', 'Push / Pull / Legs x2\n6 Days'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.trending_up, color: AppTheme.primaryGreen, size: 18),
                      SizedBox(width: 6),
                      Text('Progression Rules', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Beginner', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen)),
                  const Text('Add weight when reps completed comfortably', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                  const SizedBox(height: 8),
                  const Text('Intermediate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange)),
                  const Text('Periodize: Week 1: 70% • Week 2: 75% • Week 3: 80% • Week 4: Deload',
                      style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateInfo {
  final String name;
  final String detail;
  const _TemplateInfo(this.name, this.detail);
}

class _TemplateSection extends StatelessWidget {
  final Color dot;
  final String title;
  final List<_TemplateInfo> templates;
  const _TemplateSection({required this.dot, required this.title, required this.templates});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
        const SizedBox(height: 8),
        ...templates.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(t.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text(t.detail, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
                onTap: () {},
              ),
            )),
      ],
    );
  }
}

// ── Workout History Screen ────────────────────────────────────────────────────
class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      {
        'day': 'Push Day',
        'date': '2025-02-20',
        'exercises': [
          {'name': 'Bench Press', 'sets': [{'set': 'Set 1', 'kg': '50kg'}, {'set': 'Set 2', 'kg': '60kg'}, {'set': 'Set 3', 'kg': '60kg'}]},
          {'name': 'Overhead Press', 'sets': [{'set': 'Set 1', 'kg': '30kg'}, {'set': 'Set 2', 'kg': '40kg'}, {'set': 'Set 3', 'kg': '40kg'}]},
        ],
      },
      {
        'day': 'Pull Day',
        'date': '2025-02-18',
        'exercises': [
          {'name': 'Deadlift', 'sets': [{'set': 'Set 1', 'kg': '100kg'}, {'set': 'Set 2', 'kg': '100kg'}, {'set': 'Set 3', 'kg': '100kg'}]},
          {'name': 'Pull Ups', 'sets': [{'set': 'Set 1', 'kg': '0 + BW'}, {'set': 'Set 2', 'kg': '0 + BW'}, {'set': 'Set 3', 'kg': '0 + BW'}]},
        ],
      },
      {
        'day': 'Leg Day',
        'date': '2025-02-16',
        'exercises': [
          {'name': 'Squat', 'sets': [{'set': 'Set 1', 'kg': '80kg'}, {'set': 'Set 2', 'kg': '80kg'}, {'set': 'Set 3(AR)', 'kg': '120kg'}]},
        ],
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Workout History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Track your progress over time',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (_, i) {
          final session = history[i];
          final exercises = session['exercises'] as List;
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(session['day'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      Row(children: [
                        Text(session['date'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                        const SizedBox(width: 4),
                        const Icon(Icons.fitness_center, size: 14, color: AppTheme.primaryGreen),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...exercises.map((ex) {
                    final sets = ex['sets'] as List;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ex['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Row(
                            children: sets.map<Widget>((s) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  Text(s['set'] as String, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                                  Text(s['kg'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}