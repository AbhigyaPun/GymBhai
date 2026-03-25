import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';
import 'qr_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  
  bool _loading = true;
  String? _error;

  // For calendar — days that have a check-in this month
  Set<int> _checkedDaysThisMonth = {};
  int _totalCheckins = 0;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() { _loading = true; _error = null; });

    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/member/attendance/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final dates = List<String>.from(data['dates'] ?? []);
        final now = DateTime.now();

        final thisMonthDays = dates
            .map((d) => DateTime.parse(d))
            .where((d) => d.year == now.year && d.month == now.month)
            .map((d) => d.day)
            .toSet();

        setState(() {
          _totalCheckins = data['total'] ?? 0;
          _checkedDaysThisMonth = thisMonthDays;
          _loading = false;
        });
      } else {
        setState(() { _error = 'Failed to load attendance'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Cannot connect to server'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = _monthName(now.month);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: _loadAttendance,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ── Green Header ──────────────────────────────
              Container(
                width: double.infinity,
                color: AppTheme.primaryGreen,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Attendance',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    // QR Button → opens QR screen
                    InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QRScreen()),
                        );
                        _loadAttendance(); // refresh after returning
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Show My QR Code',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Stats ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: _AttendanceStat(
                      value: _loading ? '—' : '$_totalCheckins',
                      label: 'Total Check-ins',
                    )),
                    Expanded(child: _AttendanceStat(
                      value: _loading ? '—' : '${_checkedDaysThisMonth.length}',
                      label: 'This Month',
                    )),
                    Expanded(child: _AttendanceStat(
                      value: _loading ? '—' : _attendanceRate(),
                      label: 'Rate',
                    )),
                  ],
                ),
              ),

              // ── Calendar ──────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$monthName ${now.year}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['S','M','T','W','T','F','S']
                          .map((d) => SizedBox(
                                width: 36,
                                child: Center(
                                  child: Text(d,
                                      style: const TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textGrey)),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    _buildCalendarGrid(now),
                  ],
                ),
              ),

              // ── Error ─────────────────────────────────────
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime now) {
    final firstDay = DateTime(now.year, now.month, 1);
    final startOffset = firstDay.weekday % 7; // Sunday = 0
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final cells = List<int?>.filled(startOffset, null) +
        List<int?>.generate(daysInMonth, (i) => i + 1);
    while (cells.length % 7 != 0) { cells.add(null); }

    return Column(
      children: List.generate(cells.length ~/ 7, (row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final day = cells[row * 7 + col];
              if (day == null) return const SizedBox(width: 36, height: 36);
              final isChecked = _checkedDaysThisMonth.contains(day);
              final isToday = day == now.day;
              return SizedBox(
                width: 36, height: 36,
                child: Center(
                  child: Container(
                    width: 30, height: 30,
                    decoration: isChecked
                        ? BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          )
                        : isToday
                            ? BoxDecoration(
                                border: Border.all(color: AppTheme.primaryGreen),
                                shape: BoxShape.circle,
                              )
                            : null,
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isChecked || isToday ? FontWeight.w600 : FontWeight.normal,
                          color: isChecked ? AppTheme.primaryGreen : AppTheme.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  String _attendanceRate() {
    final now = DateTime.now();
    final daysSoFar = now.day;
    if (daysSoFar == 0) return '0%';
    final rate = (_checkedDaysThisMonth.length / daysSoFar * 100).round();
    return '$rate%';
  }

  String _monthName(int month) {
    const names = ['','January','February','March','April','May','June',
        'July','August','September','October','November','December'];
    return names[month];
  }
}

class _AttendanceStat extends StatelessWidget {
  final String value;
  final String label;
  const _AttendanceStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
      ],
    );
  }
}