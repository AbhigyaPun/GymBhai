import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _member;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  Future<void> _loadMember() async {
    final member = await AuthService.getMember();
    if (mounted) setState(() { _member = member; _loading = false; });
  }

  String get _firstName {
    if (_member == null) return 'Member';
    final first = _member!['first_name'] ?? '';
    return first.isNotEmpty ? first : (_member!['username'] ?? 'Member');
  }

  String get _membershipPlan {
    final plan = _member?['membership'] ?? 'basic';
    return plan[0].toUpperCase() + plan.substring(1);
  }

  String get _status => _member?['status'] ?? 'active';

  String get _expiryDate => _member?['expiry_date'] ?? '—';

  String get _goal {
    switch (_member?['goal']) {
      case 'bulk': return 'Muscle Building';
      case 'cut': return 'Weight Loss';
      case 'maintain': return 'Maintenance';
      default: return 'General Fitness';
    }
  }

  int get _checkins => _member?['checkins'] ?? 0;

  int get _daysUntilExpiry {
    if (_expiryDate == '—') return -1;
    try {
      final expiry = DateTime.parse(_expiryDate);
      return expiry.difference(DateTime.now()).inDays;
    } catch (_) {
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
        onRefresh: _loadMember,
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
                      value: days >= 0 ? '$days' : '—',
                      label: 'Days Until Expiry',
                      iconColor: days >= 0 && days <= 7 ? Colors.red : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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

              if (days >= 0 && days <= 7)
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