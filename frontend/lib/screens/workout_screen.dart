import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _splits  = [];
  List<dynamic> _logs    = [];
  bool _loadingSplits    = true;
  bool _loadingLogs      = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSplits();
    _loadLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSplits() async {
    setState(() { _loadingSplits = true; _error = null; });
    try {
      final token = await AuthService.getToken();
      final res   = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/workouts/splits/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          _splits       = jsonDecode(res.body);
          _loadingSplits = false;
        });
      } else {
        setState(() { _error = 'Failed to load splits'; _loadingSplits = false; });
      }
    } catch (_) {
      setState(() { _error = 'Cannot connect to server'; _loadingSplits = false; });
    }
  }

  Future<void> _loadLogs() async {
    setState(() => _loadingLogs = true);
    try {
      final token = await AuthService.getToken();
      final res   = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/workouts/logs/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() { _logs = jsonDecode(res.body); _loadingLogs = false; });
      } else {
        setState(() => _loadingLogs = false);
      }
    } catch (_) {
      setState(() => _loadingLogs = false);
    }
  }

  Color _goalColor(String goal) {
    switch (goal) {
      case 'bulk':     return Colors.blue;
      case 'cut':      return Colors.orange;
      case 'strength': return Colors.purple;
      default:         return AppTheme.primaryGreen;
    }
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'advanced':     return Colors.red;
      case 'intermediate': return Colors.orange;
      default:             return AppTheme.primaryGreen;
    }
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: Column(
        children: [
          // Header
          Container(
            color: AppTheme.primaryGreen,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Workout Plans',
                    style: TextStyle(color: Colors.white,
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const Text('Choose a split and log your sessions',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: const [
                    Tab(text: 'Splits'),
                    Tab(text: 'My History'),
                  ],
                ),
              ],
            ),
          ),
          // Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Splits tab ──────────────────────────
                _loadingSplits
                    ? const Center(child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen))
                    : _error != null
                        ? Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_error!, style: const TextStyle(
                                  color: AppTheme.textGrey)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                  onPressed: _loadSplits,
                                  child: const Text('Retry')),
                            ]))
                        : _splits.isEmpty
                            ? const Center(child: Text(
                                'No workout splits available yet.',
                                style: TextStyle(color: AppTheme.textGrey)))
                            : RefreshIndicator(
                                color: AppTheme.primaryGreen,
                                onRefresh: _loadSplits,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _splits.length,
                                  itemBuilder: (context, i) => _SplitCard(
                                    split: _splits[i],
                                    goalColor: _goalColor(
                                        _splits[i]['goal'] ?? ''),
                                    levelColor: _levelColor(
                                        _splits[i]['level'] ?? ''),
                                    cap: _cap,
                                    onLogSaved: () {
                                      _loadLogs();
                                      _tabController.animateTo(1);
                                    },
                                  ),
                                ),
                              ),

                // ── History tab ─────────────────────────
                _loadingLogs
                    ? const Center(child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen))
                    : _logs.isEmpty
                        ? const Center(
                            child: Text(
                              'No workouts logged yet.\nStart a split and log your first session!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textGrey),
                            ))
                        : RefreshIndicator(
                            color: AppTheme.primaryGreen,
                            onRefresh: _loadLogs,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _logs.length,
                              itemBuilder: (context, i) =>
                                  _LogCard(log: _logs[i], cap: _cap),
                            ),
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Split Card ────────────────────────────────────────────────────────────────
class _SplitCard extends StatefulWidget {
  final dynamic split;
  final Color goalColor;
  final Color levelColor;
  final String Function(String) cap;
  final VoidCallback onLogSaved;

  const _SplitCard({
    required this.split,
    required this.goalColor,
    required this.levelColor,
    required this.cap,
    required this.onLogSaved,
  });

  @override
  State<_SplitCard> createState() => _SplitCardState();
}

class _SplitCardState extends State<_SplitCard> {
  bool _expanded   = false;
  int  _selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    final split = widget.split;
    final days  = List<dynamic>.from(split['days'] ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: widget.goalColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('${split['days_per_week']}d',
                        style: TextStyle(color: widget.goalColor,
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(split['name'] ?? '',
                          style: const TextStyle(fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark)),
                      if ((split['description'] ?? '').isNotEmpty)
                        Text(split['description'],
                            style: const TextStyle(fontSize: 12,
                                color: AppTheme.textGrey)),
                      const SizedBox(height: 6),
                      Row(children: [
                        _Badge(widget.cap(split['goal'] ?? ''),
                            widget.goalColor),
                        const SizedBox(width: 6),
                        _Badge(widget.cap(split['level'] ?? ''),
                            widget.levelColor),
                        const SizedBox(width: 6),
                        Text('${split['exercise_count']} exercises',
                            style: const TextStyle(fontSize: 11,
                                color: AppTheme.textGrey)),
                      ]),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Icon(
                    _expanded ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),

          // Expanded section
          if (_expanded && days.isNotEmpty) ...[
            const Divider(height: 1),
            // Day tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                children: List.generate(days.length, (i) {
                  final sel = _selectedDay == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.primaryGreen
                                   : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? AppTheme.primaryGreen
                                     : AppTheme.dividerColor,
                        ),
                      ),
                      child: Text(
                        'Day ${days[i]['day_number']}: ${days[i]['name']}',
                        style: TextStyle(
                          color: sel ? Colors.white : AppTheme.textGrey,
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w600
                                         : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Exercises + Log button
            if (_selectedDay < days.length)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((days[_selectedDay]['notes'] ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(days[_selectedDay]['notes'],
                            style: const TextStyle(fontSize: 12,
                                color: AppTheme.textGrey,
                                fontStyle: FontStyle.italic)),
                      ),
                    ...List.generate(
                      (days[_selectedDay]['exercises'] as List).length,
                      (ei) {
                        final ex = days[_selectedDay]['exercises'][ei];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.scaffoldBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('${ei + 1}',
                                    style: const TextStyle(fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryGreen)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(ex['name'] ?? '',
                                      style: const TextStyle(fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textDark)),
                                  Text(
                                    '${ex['sets']} sets × ${ex['reps']} reps'
                                    '${(ex['weight_note'] ?? '').isNotEmpty ? ' · ${ex['weight_note']}' : ''}',
                                    style: const TextStyle(fontSize: 12,
                                        color: AppTheme.textGrey),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Log this workout button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline,
                          size: 18),
                      label: Text(
                          'Log Day ${days[_selectedDay]['day_number']}: ${days[_selectedDay]['name']}'),
                      onPressed: () => _showLogModal(
                          context, days[_selectedDay]),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showLogModal(BuildContext context, dynamic day) {
    final exercises = List<dynamic>.from(day['exercises'] ?? []);
    // Build controllers for each exercise
    final setsControllers   = exercises.map((_) =>
        TextEditingController()).toList();
    final repsControllers   = exercises.map((_) =>
        TextEditingController()).toList();
    final weightControllers = exercises.map((_) =>
        TextEditingController()).toList();
    final notesCtrl = TextEditingController();
    bool saving = false;

    // Pre-fill sets from plan
    for (int i = 0; i < exercises.length; i++) {
      setsControllers[i].text = '${exercises[i]['sets']}';
      repsControllers[i].text  = '${exercises[i]['reps']}';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Log Day ${day['day_number']}: ${day['name']}',
                          style: const TextStyle(fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark),
                        ),
                        Text('${exercises.length} exercises',
                            style: const TextStyle(fontSize: 13,
                                color: AppTheme.textGrey)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close,
                          color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              // Exercise list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    ...List.generate(exercises.length, (i) {
                      final ex = exercises[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.scaffoldBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text('${i + 1}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryGreen)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(ex['name'] ?? '',
                                  style: const TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark)),
                            ]),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('Sets',
                                        style: TextStyle(fontSize: 12,
                                            color: AppTheme.textGrey)),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: setsControllers[i],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('Reps',
                                        style: TextStyle(fontSize: 12,
                                            color: AppTheme.textGrey)),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: repsControllers[i],
                                      decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('Weight',
                                        style: TextStyle(fontSize: 12,
                                            color: AppTheme.textGrey)),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: weightControllers[i],
                                      decoration: const InputDecoration(
                                          isDense: true,
                                          hintText: 'e.g. 60kg',
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8)),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      );
                    }),
                    // Session notes
                    const Text('Session Notes (optional)',
                        style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          hintText: 'How did it go?'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              setModalState(() => saving = true);
                              try {
                                final token =
                                    await AuthService.getToken();
                                final payload = {
                                  'day_id': day['id'],
                                  'notes':  notesCtrl.text.trim(),
                                  'exercise_logs': List.generate(
                                    exercises.length,
                                    (i) => {
                                      'exercise_id': exercises[i]['id'],
                                      'sets_done':   int.tryParse(setsControllers[i].text) ?? 0,
                                      'reps_done':   repsControllers[i].text,
                                      'weight_used': weightControllers[i].text,
                                    },
                                  ),
                                };
                                final res = await http.post(
                                  Uri.parse('${AppConfig.apiBaseUrl}/workouts/logs/'),
                                  headers: {
                                    'Authorization': 'Bearer $token',
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode(payload),
                                );
                                if (res.statusCode == 201) {
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  widget.onLogSaved();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text('Workout logged!'),
                                      backgroundColor:
                                          AppTheme.primaryGreen,
                                    ));
                                  }
                                }
                              } catch (_) {
                                setModalState(() => saving = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50)),
                      child: saving
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : const Text('Save Workout Log',
                              style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Log Card ──────────────────────────────────────────────────────────────────
class _LogCard extends StatefulWidget {
  final dynamic log;
  final String Function(String) cap;
  const _LogCard({required this.log, required this.cap});

  @override
  State<_LogCard> createState() => _LogCardState();
}

class _LogCardState extends State<_LogCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final log      = widget.log;
    final exLogs   = List<dynamic>.from(log['exercise_logs'] ?? []);
    final loggedAt = DateTime.parse(log['logged_at']).toLocal();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.fitness_center,
                    color: AppTheme.primaryGreen, size: 20),
              ),
            ),
            title: Text(
              '${log['split_name']} — Day ${log['day_number']}: ${log['day_name']}',
              style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark),
            ),
            subtitle: Text(
              '${loggedAt.day}/${loggedAt.month}/${loggedAt.year} · ${loggedAt.hour}:${loggedAt.minute.toString().padLeft(2, '0')} · ${exLogs.length} exercises',
              style: const TextStyle(fontSize: 11,
                  color: AppTheme.textGrey),
            ),
            trailing: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Icon(
                _expanded ? Icons.keyboard_arrow_up
                           : Icons.keyboard_arrow_down,
                color: AppTheme.textGrey,
              ),
            ),
          ),
          if (_expanded && exLogs.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                children: [
                  // Header
                  const Row(children: [
                    Expanded(flex: 3,
                        child: Text('Exercise',
                            style: TextStyle(fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textGrey))),
                    Expanded(child: Text('Sets',
                        style: TextStyle(fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textGrey))),
                    Expanded(child: Text('Reps',
                        style: TextStyle(fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textGrey))),
                    Expanded(flex: 2,
                        child: Text('Weight',
                            style: TextStyle(fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textGrey))),
                  ]),
                  const Divider(height: 10),
                  ...exLogs.map((el) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Expanded(flex: 3,
                              child: Text(el['exercise_name'] ?? '',
                                  style: const TextStyle(fontSize: 12,
                                      color: AppTheme.textDark))),
                          Expanded(
                              child: Text('${el['sets_done']}',
                                  style: const TextStyle(fontSize: 12,
                                      color: AppTheme.textGrey))),
                          Expanded(
                              child: Text(el['reps_done'] ?? '',
                                  style: const TextStyle(fontSize: 12,
                                      color: AppTheme.textGrey))),
                          Expanded(flex: 2,
                              child: Text(
                                (el['weight_used'] ?? '').isEmpty
                                    ? '—'
                                    : el['weight_used'],
                                style: const TextStyle(fontSize: 12,
                                    color: AppTheme.textGrey),
                              )),
                        ]),
                      )),
                  if ((log['notes'] ?? '').isNotEmpty) ...[
                    const Divider(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Note: ${log['notes']}',
                          style: const TextStyle(fontSize: 12,
                              color: AppTheme.textGrey,
                              fontStyle: FontStyle.italic)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}