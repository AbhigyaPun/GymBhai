import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, dynamic>? _profile;
  List<dynamic> _logs  = [];
  bool _loading        = true;
  String? _error;
  String? _memberGoal;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthService.getToken();

      // Fetch member profile for goal
      String goal = 'maintain';
      final memberRes = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/member/profile/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (memberRes.statusCode == 200) {
        final memberData = jsonDecode(memberRes.body) as Map<String, dynamic>;
        await AuthService.updateMember(memberData);
        goal = memberData['goal']?.toString() ?? 'maintain';
      } else {
        final member = await AuthService.getMember();
        goal = member?['goal']?.toString() ?? 'maintain';
      }

      // Fetch progress profile
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/progress/profile/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _memberGoal = goal;
          _profile    = data;
          _logs       = List<dynamic>.from(data['weight_logs'] ?? []);
          _loading    = false;
        });
      } else {
        setState(() {
          _memberGoal = goal;
          _error      = 'Failed to load progress';
          _loading    = false;
        });
      }
    } catch (_) {
      setState(() { _error = 'Cannot connect to server'; _loading = false; });
    }
  }

  String get _goalLabel {
    switch (_memberGoal) {
      case 'bulk':  return 'Muscle Gain';
      case 'cut':   return 'Weight Loss';
      default:      return 'Maintenance';
    }
  }

  Color get _goalColor {
    switch (_memberGoal) {
      case 'bulk':  return Colors.blue;
      case 'cut':   return Colors.orange;
      default:      return AppTheme.primaryGreen;
    }
  }

  int get _dailyCalories {
    final weight = double.tryParse('${_profile?['current_weight'] ?? 0}') ?? 0;
    if (weight <= 0) return 0;
    final base = weight * 33;
    switch (_memberGoal) {
      case 'bulk':  return (base + 300).round();
      case 'cut':   return (base - 500).round();
      default:      return base.round();
    }
  }

  String get _calorieLabel {
    switch (_memberGoal) {
      case 'bulk':  return 'Bulk (+300)';
      case 'cut':   return 'Cut (-500)';
      default:      return 'Maintain';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.primaryGreen,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress Tracking',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Track your transformation journey',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),

            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppTheme.textGrey)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Goal banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _goalColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _goalColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        Icon(Icons.flag_outlined, color: _goalColor),
                        const SizedBox(width: 10),
                        Text('Current Goal: $_goalLabel',
                            style: TextStyle(color: _goalColor, fontWeight: FontWeight.w600, fontSize: 14)),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Stats row 1
                    Row(children: [
                      Expanded(child: _StatCard(
                        label: 'Current Weight',
                        value: _profile?['current_weight'] != null ? '${_profile!['current_weight']} kg' : '—',
                        icon: Icons.monitor_weight_outlined,
                        color: Colors.blue,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        label: 'Target Weight',
                        value: _profile?['target_weight'] != null ? '${_profile!['target_weight']} kg' : '—',
                        icon: Icons.flag_outlined,
                        color: _goalColor,
                      )),
                    ]),
                    const SizedBox(height: 12),

                    // Stats row 2
                    Row(children: [
                      Expanded(child: _StatCard(
                        label: 'To Goal',
                        value: _profile?['weight_to_goal'] != null ? '${_profile!['weight_to_goal']} kg' : '—',
                        icon: Icons.trending_up,
                        color: Colors.orange,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        label: 'Progress',
                        value: '${_profile?['progress_percentage'] ?? 0}%',
                        icon: Icons.pie_chart_outline,
                        color: AppTheme.primaryGreen,
                      )),
                    ]),
                    const SizedBox(height: 12),

                    // Stats row 3 — calories
                    if (_dailyCalories > 0)
                      Row(children: [
                        Expanded(child: _StatCard(
                          label: 'Daily Calories',
                          value: '$_dailyCalories kcal',
                          icon: Icons.local_fire_department_outlined,
                          color: Colors.deepOrange,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(
                          label: 'Calorie Plan',
                          value: _calorieLabel,
                          icon: Icons.restaurant_outlined,
                          color: _goalColor,
                        )),
                      ]),
                    const SizedBox(height: 16),

                    // Progress bar
                    if ((_profile?['progress_percentage'] ?? 0) > 0) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Overall Progress',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                                  Text('${_profile?['progress_percentage'] ?? 0}%',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _goalColor)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: ((_profile?['progress_percentage'] ?? 0) as num).toDouble() / 100,
                                  minHeight: 10,
                                  backgroundColor: AppTheme.dividerColor,
                                  valueColor: AlwaysStoppedAnimation(_goalColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Set goals card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Set Your Goals',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                            const SizedBox(height: 4),
                            if (_profile?['recommended_target'] != null)
                              Text(
                                'Recommended target for ${_goalLabel.toLowerCase()}: ${_profile!['recommended_target']} kg',
                                style: TextStyle(fontSize: 12, color: _goalColor, fontStyle: FontStyle.italic),
                              ),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Update Goals'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 44),
                                side: const BorderSide(color: AppTheme.primaryGreen),
                                foregroundColor: AppTheme.primaryGreen,
                              ),
                              onPressed: () => _showGoalsModal(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Log weight button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Log This Week\'s Weight',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      onPressed: () => _showLogModal(context),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    ),
                    const SizedBox(height: 20),

                    // Weight chart
                    if (_logs.isNotEmpty) ...[
                      const Text('Weight History',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      const SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            height: 160,
                            child: CustomPaint(
                              painter: _WeightChartPainter(
                                logs: _logs,
                                goalColor: _goalColor,
                                targetWeight: _profile?['target_weight'] != null
                                    ? double.tryParse('${_profile!['target_weight']}')
                                    : null,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Log history
                    const Text('Check-in History',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    const SizedBox(height: 10),
                    _logs.isEmpty
                        ? Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'No weight logs yet.\nTap "Log This Week\'s Weight" to start.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                                ),
                              ),
                            ),
                          )
                        : Card(
                            child: Column(
                              children: List.generate(_logs.length, (i) {
                                final log = _logs[i];
                                final isFirst = i == 0;
                                String change = '';
                                if (i < _logs.length - 1) {
                                  final prev = double.tryParse('${_logs[i + 1]['weight']}') ?? 0;
                                  final curr = double.tryParse('${log['weight']}') ?? 0;
                                  final diff = curr - prev;
                                  if (diff > 0) {
                                    change = '+${diff.toStringAsFixed(1)} kg';
                                  } else if (diff < 0) {
                                    change = '${diff.toStringAsFixed(1)} kg';
                                  } else {
                                    change = 'No change';
                                  }
                                }
                                return Column(
                                  children: [
                                    if (i > 0) const Divider(height: 1),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40, height: 40,
                                            decoration: BoxDecoration(
                                              color: isFirst ? _goalColor.withValues(alpha: 0.1) : AppTheme.scaffoldBg,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Icon(Icons.monitor_weight_outlined,
                                                  color: isFirst ? _goalColor : AppTheme.textGrey, size: 20),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('${log['weight']} kg',
                                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                                                Text(log['logged_at'] ?? '',
                                                    style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                                                if ((log['notes'] ?? '').isNotEmpty)
                                                  Text(log['notes'],
                                                      style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontStyle: FontStyle.italic)),
                                              ],
                                            ),
                                          ),
                                          if (change.isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: change.startsWith('+')
                                                    ? Colors.blue.withValues(alpha: 0.1)
                                                    : change.startsWith('-')
                                                        ? Colors.orange.withValues(alpha: 0.1)
                                                        : Colors.grey.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(change,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: change.startsWith('+') ? Colors.blue : change.startsWith('-') ? Colors.orange : Colors.grey,
                                                  )),
                                            ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                            onPressed: () => _deleteLog(log['id']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showGoalsModal(BuildContext context) {
    final currentCtrl = TextEditingController(text: _profile?['current_weight']?.toString() ?? '');
    final targetCtrl  = TextEditingController(text: _profile?['target_weight']?.toString() ?? '');
    final heightCtrl  = TextEditingController(text: _profile?['height']?.toString() ?? '');
    bool saving = false;
    final recommended = _profile?['recommended_target'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Set Your Goals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                if (recommended != null)
                  Text('Recommended target for $_goalLabel: $recommended kg',
                      style: TextStyle(fontSize: 12, color: _goalColor, fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: _ModalField(label: 'Current Weight (kg)', controller: currentCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _ModalField(label: 'Target Weight (kg)', controller: targetCtrl)),
                ]),
                const SizedBox(height: 4),
                if (recommended != null)
                  GestureDetector(
                    onTap: () => targetCtrl.text = '$recommended',
                    child: Text('Use recommended: $recommended kg',
                        style: TextStyle(fontSize: 12, color: _goalColor, decoration: TextDecoration.underline)),
                  ),
                const SizedBox(height: 12),
                _ModalField(label: 'Height (cm)', controller: heightCtrl),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: saving ? null : () async {
                    setModal(() => saving = true);
                    try {
                      final token = await AuthService.getToken();
                      final res = await http.put(
                        Uri.parse('${AppConfig.apiBaseUrl}/progress/profile/'),
                        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'current_weight': double.tryParse(currentCtrl.text) ?? 0,
                          'target_weight': double.tryParse(targetCtrl.text) ?? 0,
                          'height': double.tryParse(heightCtrl.text),
                        }),
                      );
                      if (res.statusCode == 200) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadData();
                      }
                    } catch (_) {}
                    setModal(() => saving = false);
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: saving
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text('Save Goals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogModal(BuildContext context) {
    final weightCtrl = TextEditingController();
    final notesCtrl  = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Log This Week\'s Weight',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 20),
                _ModalField(label: 'Weight (kg)', controller: weightCtrl),
                _ModalField(label: 'Notes (optional)', controller: notesCtrl),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: saving ? null : () async {
                    if (weightCtrl.text.isEmpty) return;
                    setModal(() => saving = true);
                    try {
                      final token = await AuthService.getToken();
                      final res = await http.post(
                        Uri.parse('${AppConfig.apiBaseUrl}/progress/logs/'),
                        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'weight': double.tryParse(weightCtrl.text) ?? 0,
                          'notes': notesCtrl.text.trim(),
                        }),
                      );
                      if (res.statusCode == 201) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Weight logged!'),
                            backgroundColor: AppTheme.primaryGreen,
                          ));
                        }
                      }
                    } catch (_) {}
                    setModal(() => saving = false);
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: saving
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text('Log Weight', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteLog(int id) async {
    final token = await AuthService.getToken();
    await http.delete(
      Uri.parse('${AppConfig.apiBaseUrl}/progress/logs/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    _loadData();
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ModalField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _ModalField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
                isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
          ),
        ],
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<dynamic> logs;
  final Color goalColor;
  final double? targetWeight;

  _WeightChartPainter({required this.logs, required this.goalColor, this.targetWeight});

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.isEmpty) return;

    final weights = logs.reversed.map((l) => double.tryParse('${l['weight']}') ?? 0.0).toList();
    final allValues = [...weights, targetWeight ?? 0.0];
    final minY = allValues.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = allValues.reduce((a, b) => a > b ? a : b) + 2;

    final linePaint = Paint()..color = goalColor..strokeWidth = 2.5..style = PaintingStyle.stroke;
    final fillPaint = Paint()..color = goalColor.withValues(alpha: 0.1)..style = PaintingStyle.fill;
    final dotPaint  = Paint()..color = goalColor..style = PaintingStyle.fill;

    final path     = Path();
    final fillPath = Path();
    final offsets  = <Offset>[];

    for (int i = 0; i < weights.length; i++) {
      final x = i * size.width / (weights.length - 1);
      final y = size.height - (weights[i] - minY) / (maxY - minY) * size.height;
      offsets.add(Offset(x, y));
      if (i == 0) { path.moveTo(x, y); fillPath.moveTo(x, y); }
      else { path.lineTo(x, y); fillPath.lineTo(x, y); }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    for (final o in offsets) {
      canvas.drawCircle(o, 5, Paint()..color = Colors.white..style = PaintingStyle.fill);
      canvas.drawCircle(o, 4, dotPaint);
    }

    if (targetWeight != null) {
      final ty = size.height - (targetWeight! - minY) / (maxY - minY) * size.height;
      canvas.drawLine(Offset(0, ty), Offset(size.width, ty),
          Paint()..color = Colors.red.withValues(alpha: 0.5)..strokeWidth = 1.5..style = PaintingStyle.stroke);
      final tp = TextPainter(
        text: TextSpan(text: 'Target: ${targetWeight}kg', style: TextStyle(color: Colors.red.shade400, fontSize: 10)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(4, ty - 14));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}