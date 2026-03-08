import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final List<Map<String, dynamic>> _checkIns = [
    {'date': '2021-01-28', 'weight': '82 kg', 'waist': '83 cm', 'chest': '100 cm'},
    {'date': '2021-01-21', 'weight': '76.2 kg', 'waist': '83 cm', 'chest': '99 cm'},
    {'date': '2021-01-14', 'weight': '76.8 kg', 'waist': '84 cm', 'chest': '90 cm'},
    {'date': '2021-01-07', 'weight': '77.5 kg', 'waist': '85 cm', 'chest': '88 cm'},
    {'date': '2020-12-28', 'weight': '78 kg', 'waist': '86 cm', 'chest': '88 cm'},
  ];

  void _showCheckInModal() {
    final weightCtrl = TextEditingController(text: '75.5');
    final waistCtrl = TextEditingController(text: '82');
    final chestCtrl = TextEditingController(text: '100');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Weekly Check-in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalField(label: 'Weight (kg)', controller: weightCtrl),
            const SizedBox(height: 12),
            _ModalField(label: 'Waist (cm)', controller: waistCtrl),
            const SizedBox(height: 12),
            _ModalField(label: 'Chest (cm)', controller: chestCtrl),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Date', style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 40)),
            child: const Text('Save Check-in'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progress Tracking', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Monitor your transformation journey', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards
                  const Text('Your Stats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatBox(label: 'Current\nWeight', value: '75.5 kg', icon: Icons.monitor_weight_outlined, iconColor: Colors.blue),
                      const SizedBox(width: 12),
                      _StatBox(label: 'Target\nWeight', value: '72 kg', icon: Icons.flag_outlined, iconColor: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatBox(label: 'Cut\nest.', value: '17', icon: Icons.content_cut_outlined, iconColor: Colors.orange, small: true),
                      const SizedBox(width: 12),
                      _StatBox(label: 'Cut\nest.', value: '5\ncm', icon: Icons.straighten_outlined, iconColor: Colors.purple, small: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quick Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          const SizedBox(height: 12),
                          _SummaryRow(label: 'Weight Change', value: '+2.5 kg', valueColor: Colors.red),
                          const Divider(height: 16),
                          _SummaryRow(label: 'Weight to Goal', value: '3.5 kg'),
                          const Divider(height: 16),
                          _SummaryRow(label: 'Waist Change', value: '+4.0 cm', valueColor: Colors.red),
                          const Divider(height: 16),
                          _SummaryRow(label: 'Progress', value: '42%', valueColor: AppTheme.primaryGreen),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Add check-in button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add, color: AppTheme.primaryGreen),
                    label: const Text('Add Weekly Check-in', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w500)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: AppTheme.primaryGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _showCheckInModal,
                  ),
                  const SizedBox(height: 20),
                  // Weight progression graph placeholder
                  const Text('Weight Progression', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 140,
                        child: CustomPaint(painter: _LineChartPainter(), child: const SizedBox.expand()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Check-in history
                  const Text('Check-in History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: _checkIns.asMap().entries.map((e) {
                        final item = e.value;
                        return Column(
                          children: [
                            if (e.key > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['date'] as String,
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      _HistoryChip(label: 'Weight', value: item['weight'] as String),
                                      const SizedBox(width: 16),
                                      _HistoryChip(label: 'Waist', value: item['waist'] as String),
                                      const SizedBox(width: 16),
                                      _HistoryChip(label: 'Chest', value: item['chest'] as String),
                                    ],
                                  ),
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

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool small;
  const _StatBox({required this.label, required this.value, required this.icon, required this.iconColor, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppTheme.textDark)),
      ],
    );
  }
}

class _HistoryChip extends StatelessWidget {
  final String label;
  final String value;
  const _HistoryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      ],
    );
  }
}

class _ModalField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _ModalField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        ),
      ],
    );
  }
}

// Simple line chart painter
class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.fill;

    // Mock weight data points (normalized)
    final points = [78.0, 77.5, 76.8, 76.2, 82.0];
    final minY = points.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = points.reduce((a, b) => a > b ? a : b) + 2;

    final path = Path();
    final List<Offset> offsets = [];

    for (int i = 0; i < points.length; i++) {
      final x = i * size.width / (points.length - 1);
      final y = size.height - (points[i] - minY) / (maxY - minY) * size.height;
      offsets.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Fill area
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, Paint()
      ..color = AppTheme.primaryGreen.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill);

    canvas.drawPath(path, paint);

    for (final o in offsets) {
      canvas.drawCircle(o, 4, dotPaint);
      canvas.drawCircle(o, 4, Paint()..color = Colors.white..style = PaintingStyle.fill..strokeWidth = 2);
      canvas.drawCircle(o, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}