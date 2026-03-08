import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Dates with check-ins in January 2025
  final Set<int> _checkedDays = {2, 3, 6, 8, 9, 10, 13, 15, 16, 17, 20, 22, 23, 24, 27};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green header
            Container(
              width: double.infinity,
              color: AppTheme.primaryGreen,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Attendance', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // QR Scan Button
                  InkWell(
                    onTap: () => _showQRDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Scan QR to Check-In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: _AttendanceStat(value: '24', label: 'This Month')),
                  Expanded(child: _AttendanceStat(value: '5', label: 'This Week')),
                  Expanded(child: _AttendanceStat(value: '86%', label: 'Attendance')),
                ],
              ),
            ),
            // Calendar
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
                  const Text('January 2025',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 12),
                  // Day headers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map((d) => SizedBox(
                              width: 36,
                              child: Center(
                                child: Text(d,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textGrey)),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  // Calendar grid - January 2025 starts on Wednesday (index 3)
                  _buildCalendarGrid(),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    const startOffset = 3; // Wednesday
    const daysInMonth = 31;
    final cells = List<int?>.filled(startOffset, null) + List<int?>.generate(daysInMonth, (i) => i + 1);
    // Pad to complete last row
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
              final isChecked = _checkedDays.contains(day);
              return SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: isChecked
                        ? BoxDecoration(
                            color: AppTheme.lightGreen.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
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

  void _showQRDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('QR Check-In'),
        content: const SizedBox(
          height: 200,
          child: Center(child: Icon(Icons.qr_code, size: 150, color: AppTheme.primaryGreen)),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
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