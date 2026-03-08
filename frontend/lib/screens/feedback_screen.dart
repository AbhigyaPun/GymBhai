import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String _selectedCategory = 'General';
  int _rating = 4;
  final _messageController = TextEditingController();
  bool _submitted = false;

  final List<String> _categories = [
    'General', 'Equipment', 'Cleanliness', 'Staff', 'Classes', 'Other'
  ];

  void _submit() {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your message'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _submitted = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _submitted = false);
        _messageController.clear();
        setState(() { _rating = 4; _selectedCategory = 'General'; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted! Thank you.'), backgroundColor: AppTheme.primaryGreen),
        );
      }
    });
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Feedback & Complaints',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('We value your trust',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Submit Feedback card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryGreen),
                              SizedBox(width: 8),
                              Text('Submit Feedback',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Category
                          const Text('Category',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories.map((cat) {
                              final selected = _selectedCategory == cat;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCategory = cat),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected ? AppTheme.primaryGreen : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selected ? AppTheme.primaryGreen : AppTheme.dividerColor,
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: selected ? Colors.white : AppTheme.textGrey,
                                      fontSize: 13,
                                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          // Message
                          const Text('Your Message',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _messageController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: "Tell us what's on your mind...",
                              hintStyle: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Rating
                          const Text('Rating (Optional)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (i) {
                              return GestureDetector(
                                onTap: () => setState(() => _rating = i + 1),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(
                                    i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 36,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                          // Submit button
                          ElevatedButton.icon(
                            icon: _submitted
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.send_outlined, size: 18),
                            label: Text(_submitted ? 'Submitting...' : 'Submit Feedback'),
                            onPressed: _submitted ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Need Immediate Help
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Need Immediate Help?',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.phone_outlined, color: AppTheme.primaryGreen, size: 20),
                            ),
                            title: const Text('Call Reception',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            subtitle: const Text('+1 (555) 123-4567',
                                style: TextStyle(fontSize: 13, color: AppTheme.primaryGreen)),
                            onTap: () {},
                          ),
                        ],
                      ),
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