import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';
import 'account_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _member;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final token = await AuthService.getToken();
      final res   = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/member/profile/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          _member  = jsonDecode(res.body);
          _loading = false;
        });
      } else {
        // Fall back to cached member
        final cached = await AuthService.getMember();
        setState(() { _member = cached; _loading = false; });
      }
    } catch (_) {
      final cached = await AuthService.getMember();
      setState(() { _member = cached; _loading = false; });
    }
  }

  String get _fullName {
    final first = _member?['first_name'] ?? '';
    final last  = _member?['last_name']  ?? '';
    return '$first $last'.trim().isEmpty ? 'Member' : '$first $last'.trim();
  }

  String get _initials {
    final first = _member?['first_name'] ?? '';
    final last  = _member?['last_name']  ?? '';
    if (first.isEmpty) return '?';
    if (last.isEmpty) return first[0].toUpperCase();
    return '${first[0]}${last[0]}'.toUpperCase();
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String get _goal {
    switch (_member?['goal']) {
      case 'bulk':     return 'Muscle Building';
      case 'cut':      return 'Weight Loss';
      case 'maintain': return 'Maintenance';
      default:         return 'General Fitness';
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/', (route) => false);
              }
            },
            child: const Text('Log Out',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(
            color: AppTheme.primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Gym Bhai'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: AppTheme.primaryGreen,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  child: Text(_initials,
                      style: const TextStyle(fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_fullName,
                        style: const TextStyle(color: Colors.white,
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('${_cap(_member?['membership'] ?? '')} Member',
                        style: const TextStyle(color: Colors.white70,
                            fontSize: 13)),
                  ],
                ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Membership card
                  _SectionCard(
                    title: '🏷️  Membership',
                    children: [
                      _InfoRow(label: 'Plan',
                          value: _cap(_member?['membership'] ?? '')),
                      _InfoRow(label: 'Status',
                          value: _cap(_member?['status'] ?? ''),
                          valueColor: _member?['status'] == 'active'
                              ? AppTheme.primaryGreen
                              : Colors.red),
                      _InfoRow(label: 'Expires',
                          value: _member?['expiry_date'] ?? '—'),
                      _InfoRow(label: 'Check-ins',
                          value: '${_member?['checkins'] ?? 0}'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Personal info
                  _SectionCard(
                    title: '👤  Personal Information',
                    actionLabel: 'Edit',
                    onAction: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                              const AccountSettingsScreen()));
                      _loadProfile(); // Refresh after editing
                    },
                    children: [
                      _InfoRow(label: 'Name',    value: _fullName),
                      _InfoRow(label: 'Email',   value: _member?['email']    ?? '—'),
                      _InfoRow(label: 'Phone',   value: _member?['phone']    ?? '—'),
                      _InfoRow(label: 'Goal',    value: _goal),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Settings
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                          child: Text('⚙️  Settings',
                              style: TextStyle(fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.manage_accounts_outlined,
                              color: AppTheme.textGrey, size: 20),
                          title: const Text('Account Settings',
                              style: TextStyle(fontSize: 14)),
                          trailing: const Icon(Icons.chevron_right,
                              color: AppTheme.textGrey),
                          onTap: () async {
                            await Navigator.push(context,
                                MaterialPageRoute(builder: (_) =>
                                    const AccountSettingsScreen()));
                            _loadProfile();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Logout
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout,
                        color: Colors.red, size: 18),
                    label: const Text('Log Out',
                        style: TextStyle(color: Colors.red,
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _confirmLogout(context),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionCard({
    required this.title,
    required this.children,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark)),
                if (actionLabel != null)
                  GestureDetector(
                    onTap: onAction,
                    child: Text(actionLabel!,
                        style: const TextStyle(fontSize: 13,
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontSize: 13,
                    color: AppTheme.textGrey)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppTheme.textDark)),
          ),
        ],
      ),
    );
  }
}