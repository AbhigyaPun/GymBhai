import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // Controllers
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _phoneCtrl      = TextEditingController();

  // Fitness
  String _goal     = 'maintain';
  String _membership = 'basic';

  bool _loading = true;
  bool _saving  = false;
  String? _error;
  String? _success;

  // Password
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _savingPass = false;
  String? _passError;
  String? _passSuccess;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthService.getToken();
      final res   = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/member/profile/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _firstNameCtrl.text = data['first_name'] ?? '';
          _lastNameCtrl.text  = data['last_name']  ?? '';
          _emailCtrl.text     = data['email']       ?? '';
          _phoneCtrl.text     = data['phone']       ?? '';
          _goal               = data['goal']        ?? 'maintain';
          _membership         = data['membership']  ?? 'basic';
          _loading            = false;
        });
      } else {
        setState(() { _error = 'Failed to load profile'; _loading = false; });
      }
    } catch (_) {
      setState(() { _error = 'Cannot connect to server'; _loading = false; });
    }
  }

  Future<void> _saveProfile() async {
    setState(() { _saving = true; _error = null; _success = null; });
    try {
      final token = await AuthService.getToken();
      final res   = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/member/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'first_name': _firstNameCtrl.text.trim(),
          'last_name':  _lastNameCtrl.text.trim(),
          'email':      _emailCtrl.text.trim(),
          'phone':      _phoneCtrl.text.trim(),
          'goal':       _goal,
        }),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        // Update stored member data
        await AuthService.updateMember(data);
        setState(() { _success = 'Profile updated successfully!'; });
      } else {
        setState(() {
          _error = (data as Map).values.expand((v) =>
              v is List ? v.map((e) => e.toString()) : [v.toString()]).join(' ');
        });
      }
    } catch (_) {
      setState(() => _error = 'Cannot connect to server');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      setState(() => _passError = 'Passwords do not match');
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      setState(() => _passError = 'Password must be at least 6 characters');
      return;
    }
    setState(() { _savingPass = true; _passError = null; _passSuccess = null; });
    try {
      final token = await AuthService.getToken();
      final res   = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/member/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'password': _newPassCtrl.text}),
      );
      if (res.statusCode == 200) {
        _currentPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();
        setState(() => _passSuccess = 'Password changed successfully!');
      } else {
        final data = jsonDecode(res.body);
        setState(() => _passError = data['password']?.first ??
            'Failed to change password');
      }
    } catch (_) {
      setState(() => _passError = 'Cannot connect to server');
    } finally {
      if (mounted) setState(() => _savingPass = false);
    }
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Gym Bhai'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(
              color: AppTheme.primaryGreen))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    color: AppTheme.primaryGreen,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    child: Row(children: [
                      const Icon(Icons.manage_accounts_outlined,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Account Settings',
                              style: TextStyle(color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text('Manage your account preferences',
                              style: TextStyle(color: Colors.white70,
                                  fontSize: 12)),
                        ],
                      ),
                    ]),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Information
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Profile Information',
                                    style: TextStyle(fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark)),
                                const SizedBox(height: 16),
                                _Field(label: 'First Name',
                                    controller: _firstNameCtrl),
                                _Field(label: 'Last Name',
                                    controller: _lastNameCtrl),
                                _Field(label: 'Email',
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress),
                                _Field(label: 'Phone',
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone),
                                // Goal
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Fitness Goal',
                                          style: TextStyle(fontSize: 13,
                                              color: AppTheme.textGrey,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: ['bulk', 'cut', 'maintain']
                                            .map((g) => GestureDetector(
                                                  onTap: () => setState(
                                                      () => _goal = g),
                                                  child: Container(
                                                    margin: const EdgeInsets
                                                        .only(right: 8),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: _goal == g
                                                          ? AppTheme.primaryGreen
                                                          : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      border: Border.all(
                                                        color: _goal == g
                                                            ? AppTheme.primaryGreen
                                                            : AppTheme.dividerColor,
                                                      ),
                                                    ),
                                                    child: Text(_cap(g),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: _goal == g
                                                              ? Colors.white
                                                              : AppTheme.textGrey,
                                                          fontWeight: _goal == g
                                                              ? FontWeight.w600
                                                              : FontWeight.normal,
                                                        )),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                // Membership (read only)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Membership Plan',
                                          style: TextStyle(fontSize: 13,
                                              color: AppTheme.textGrey,
                                              fontWeight: FontWeight.w500)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(_cap(_membership),
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: AppTheme.primaryGreen,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_error != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.red.shade200),
                                    ),
                                    child: Text(_error!,
                                        style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 13)),
                                  ),
                                if (_success != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.green.shade200),
                                    ),
                                    child: Text(_success!,
                                        style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 13)),
                                  ),
                                ElevatedButton(
                                  onPressed: _saving ? null : _saveProfile,
                                  child: _saving
                                      ? const SizedBox(
                                          height: 20, width: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : const Text('Save Profile'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Change Password
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(children: [
                                  Icon(Icons.lock_outline, size: 18,
                                      color: AppTheme.textDark),
                                  SizedBox(width: 8),
                                  Text('Change Password',
                                      style: TextStyle(fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textDark)),
                                ]),
                                const SizedBox(height: 16),
                                _Field(label: 'New Password',
                                    controller: _newPassCtrl,
                                    obscure: true),
                                _Field(label: 'Confirm Password',
                                    controller: _confirmPassCtrl,
                                    obscure: true),
                                if (_passError != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.red.shade200),
                                    ),
                                    child: Text(_passError!,
                                        style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 13)),
                                  ),
                                if (_passSuccess != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.green.shade200),
                                    ),
                                    child: Text(_passSuccess!,
                                        style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 13)),
                                  ),
                                ElevatedButton(
                                  onPressed:
                                      _savingPass ? null : _changePassword,
                                  child: _savingPass
                                      ? const SizedBox(
                                          height: 20, width: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : const Text('Change Password'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscure;

  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            decoration: const InputDecoration(isDense: true),
          ),
        ],
      ),
    );
  }
}