import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // Profile info controllers
  final _nameCtrl = TextEditingController(text: 'Abhigya');
  final _emailCtrl = TextEditingController(text: 'abhigya@email.com');
  final _phoneCtrl = TextEditingController(text: '9823510522');
  final _ageCtrl = TextEditingController(text: '30');
  String _gender = 'Male';
  final _heightCtrl = TextEditingController(text: '175');
  final _weightCtrl = TextEditingController(text: '75.5');
  final _addressCtrl = TextEditingController(text: 'Kathmandu');

  // Fitness profile controllers
  final _fitnessGoalCtrl = TextEditingController(text: 'Muscle Building');
  String _fitnessLevel = 'Intermediate';
  String _dietType = 'Non-Vegetarian';
  final _trainingDaysCtrl = TextEditingController(text: '5');

  void _updateProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _updateFitnessProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitness profile updated!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Row(
                children: [
                  const Icon(Icons.manage_accounts_outlined, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Account Settings',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Manage your account preferences',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
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
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          const SizedBox(height: 16),
                          _SettingsField(label: 'Full Name', controller: _nameCtrl),
                          _SettingsField(label: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                          _SettingsField(label: 'Phone Number', controller: _phoneCtrl, keyboardType: TextInputType.phone),
                          _SettingsField(label: 'Age', controller: _ageCtrl, keyboardType: TextInputType.number),
                          // Gender dropdown
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Gender',
                                    style: TextStyle(fontSize: 13, color: AppTheme.textGrey, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _gender,
                                  decoration: const InputDecoration(isDense: true),
                                  items: ['Male', 'Female', 'Other']
                                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _gender = v!),
                                ),
                              ],
                            ),
                          ),
                          _SettingsField(label: 'Height (cm)', controller: _heightCtrl, keyboardType: TextInputType.number),
                          _SettingsField(label: 'Weight (kg)', controller: _weightCtrl, keyboardType: TextInputType.number),
                          _SettingsField(label: 'Address', controller: _addressCtrl),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: _updateProfile,
                            child: const Text('Update Profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Fitness Profile
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fitness Profile',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          const SizedBox(height: 16),
                          _SettingsField(label: 'Fitness Goal', controller: _fitnessGoalCtrl),
                          // Fitness Level dropdown
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Fitness Level',
                                    style: TextStyle(fontSize: 13, color: AppTheme.textGrey, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _fitnessLevel,
                                  decoration: const InputDecoration(isDense: true),
                                  items: ['Beginner', 'Intermediate', 'Advanced']
                                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _fitnessLevel = v!),
                                ),
                              ],
                            ),
                          ),
                          // Diet Type dropdown
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Diet Type',
                                    style: TextStyle(fontSize: 13, color: AppTheme.textGrey, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _dietType,
                                  decoration: const InputDecoration(isDense: true),
                                  items: ['Vegetarian', 'Non-Vegetarian', 'Vegan']
                                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _dietType = v!),
                                ),
                              ],
                            ),
                          ),
                          _SettingsField(label: 'Training Days Per Week', controller: _trainingDaysCtrl, keyboardType: TextInputType.number),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: _updateFitnessProfile,
                            child: const Text('Update Fitness Profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Security card
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline, size: 18, color: AppTheme.textDark),
                              SizedBox(width: 8),
                              Text('Security',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Change Password', style: TextStyle(fontSize: 14)),
                          trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
                          onTap: () => _showChangePasswordDialog(context),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          title: const Text('Two-Factor Authentication', style: TextStyle(fontSize: 14)),
                          trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
                          onTap: () {},
                        ),
                      ],
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

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: currentCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Current Password')),
            const SizedBox(height: 10),
            TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New Password')),
            const SizedBox(height: 10),
            TextField(controller: confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully!'), backgroundColor: AppTheme.primaryGreen),
              );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _SettingsField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppTheme.textGrey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: const InputDecoration(isDense: true),
          ),
        ],
      ),
    );
  }
}