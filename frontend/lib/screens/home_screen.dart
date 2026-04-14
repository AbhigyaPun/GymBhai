import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _member;
  Map<String, dynamic>? _busyStatus;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMember();
    _loadBusyStatus();
  }

  Future<void> _loadMember() async {
    try {
      final token = await AuthService.getToken();
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/member/profile/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        await AuthService.updateMember(data);
        if (mounted) setState(() { _member = data; _loading = false; });
      } else {
        final cached = await AuthService.getMember();
        if (mounted) setState(() { _member = cached; _loading = false; });
      }
    } catch (e) {
      final cached = await AuthService.getMember();
      if (mounted) setState(() { _member = cached; _loading = false; });
    }
  }

  Future<void> _loadBusyStatus() async {
    try {
      final token = await AuthService.getToken();
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/gym/busy-status/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (mounted) setState(() { _busyStatus = data; });
      }
    } catch (e) {
      debugPrint('busy status error: $e');
    }
  }

  String get _firstName {
    if (_member == null) return 'Member';
    final first = _member!['first_name']?.toString() ?? '';
    return first.isNotEmpty ? first : (_member!['username']?.toString() ?? 'Member');
  }

  String get _membershipPlan {
    final plan = _member?['membership']?.toString() ?? 'basic';
    return plan[0].toUpperCase() + plan.substring(1);
  }

  String get _status => _member?['status']?.toString() ?? 'active';

  String get _expiryDate {
    final val = _member?['expiry_date'];
    return val?.toString() ?? '—';
  }

  String get _goal {
    switch (_member?['goal']?.toString()) {
      case 'bulk': return 'Muscle Building';
      case 'cut': return 'Weight Loss';
      case 'maintain': return 'Maintenance';
      default: return 'General Fitness';
    }
  }

  int get _checkins {
    final val = _member?['checkins'];
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  int get _daysUntilExpiry {
    final expiry = _expiryDate;
    if (expiry == '—') return -1;
    try {
      final expiryDate = DateTime.parse(expiry);
      return expiryDate.difference(DateTime.now()).inDays;
    } catch (e) {
      return -1;
    }
  }

  Color get _statusColor {
    switch (_status) {
      case 'active': return AppTheme.primaryGreen;
      case 'frozen': return Colors.blue;
      case 'expired': return Colors.red;
      default: return AppTheme.textGrey;
    }
  }

  Color _busyColor(String status) {
    switch (status) {
      case 'busy': return Colors.red.shade400;
      case 'moderate': return Colors.orange.shade400;
      default: return Colors.green.shade400;
    }
  }

  Color _busyBgColor(String status) {
    switch (status) {
      case 'busy': return Colors.red.shade50;
      case 'moderate': return Colors.orange.shade50;
      default: return Colors.green.shade50;
    }
  }

  Color _busyBorderColor(String status) {
    switch (status) {
      case 'busy': return Colors.red.shade200;
      case 'moderate': return Colors.orange.shade200;
      default: return Colors.green.shade200;
    }
  }

  Color _busyTextColor(String status) {
    switch (status) {
      case 'busy': return Colors.red.shade700;
      case 'moderate': return Colors.orange.shade700;
      default: return Colors.green.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.scaffoldBg,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
      );
    }

    final days = _daysUntilExpiry;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async {
          await _loadMember();
          await _loadBusyStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back, $_firstName! 👋',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Goal: $_goal',
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.card_membership, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text('$_membershipPlan Plan',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: _status == 'active' ? Colors.white : Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(_status[0].toUpperCase() + _status.substring(1),
                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.fitness_center_outlined,
                      value: '$_checkins',
                      label: 'Total Check-ins',
                      iconColor: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_today_outlined,
                      value: days >= 0 ? '$days days' : days < 0 && _expiryDate != '—' ? 'Expired' : 'No expiry',
                      label: 'Days Until Expiry',
                      iconColor: days < 0 && _expiryDate != '—'
                          ? Colors.red
                          : days >= 0 && days <= 7
                              ? Colors.red
                              : days >= 0 && days <= 30
                                  ? Colors.orange
                                  : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Gym Busy Status
              if (_busyStatus != null) ...[
                const Text('Gym Status',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _busyBgColor(_busyStatus!['status'] ?? 'quiet'),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _busyBorderColor(_busyStatus!['status'] ?? 'quiet'),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _busyColor(_busyStatus!['status'] ?? 'quiet').withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _busyStatus!['status'] == 'busy'
                                ? Icons.people
                                : _busyStatus!['status'] == 'moderate'
                                    ? Icons.people_outline
                                    : Icons.person_outline,
                            color: _busyColor(_busyStatus!['status'] ?? 'quiet'),
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _busyStatus!['label'] ?? 'Gym is Quiet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _busyTextColor(_busyStatus!['status'] ?? 'quiet'),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_busyStatus!['count']} check-in${_busyStatus!['count'] == 1 ? '' : 's'} this hour',
                            style: TextStyle(
                              fontSize: 12,
                              color: _busyTextColor(_busyStatus!['status'] ?? 'quiet').withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Membership Info
              const Text('Membership Details',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DetailRow(label: 'Plan', value: _membershipPlan),
                      const Divider(height: 20),
                      _DetailRow(
                        label: 'Status',
                        value: _status[0].toUpperCase() + _status.substring(1),
                        valueColor: _statusColor,
                      ),
                      const Divider(height: 20),
                      _DetailRow(label: 'Expires On', value: _expiryDate),
                      const Divider(height: 20),
                      _DetailRow(label: 'Fitness Goal', value: _goal),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Notifications
              Row(
                children: const [
                  Icon(Icons.notifications_outlined, size: 20, color: AppTheme.textDark),
                  SizedBox(width: 6),
                  Text('Notifications',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                ],
              ),
              const SizedBox(height: 10),

              if (days < 0 && _expiryDate != '—')
                _NotificationCard(
                  message: '❌ Your membership has expired! Please renew.',
                  color: Colors.red.shade50,
                  borderColor: Colors.red.shade200,
                  textColor: Colors.red.shade800,
                )
              else if (days >= 0 && days <= 7)
                _NotificationCard(
                  message: days == 0
                      ? '⚠️ Your membership expires TODAY! Please renew.'
                      : '⚠️ Membership expires in $days day${days == 1 ? '' : 's'}. Renew soon!',
                  color: Colors.red.shade50,
                  borderColor: Colors.red.shade200,
                  textColor: Colors.red.shade800,
                )
              else if (days > 7 && days <= 30)
                _NotificationCard(
                  message: '📅 Your membership expires in $days days.',
                  color: Colors.orange.shade50,
                  borderColor: Colors.orange.shade200,
                  textColor: Colors.orange.shade800,
                ),

              const SizedBox(height: 8),
              _NotificationCard(
                message: '💪 Stay consistent — every workout counts!',
                color: Colors.blue.shade50,
                borderColor: Colors.blue.shade200,
                textColor: Colors.blue.shade800,
              ),
              const SizedBox(height: 8),
              _NotificationCard(
                message: '🎯 Goal: $_goal — keep pushing!',
                color: Colors.green.shade50,
                borderColor: Colors.green.shade200,
                textColor: Colors.green.shade800,
              ),
              const SizedBox(height: 20),
            ],
          ),
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
  const _StatCard({required this.icon, required this.value, required this.label, this.iconColor = AppTheme.primaryGreen});

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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
        Text(value, style: TextStyle(color: valueColor ?? AppTheme.textDark, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String message;
  final Color color, borderColor, textColor;
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