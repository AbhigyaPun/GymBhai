import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String _selectedCategory = 'general';
  int _rating = 4;
  final _messageController = TextEditingController();
  bool _submitting = false;
  String? _error;

  // History
  List<dynamic> _history = [];
  bool _loadingHistory = true;

  final List<String> _categories = [
    'general', 'equipment', 'cleanliness', 'staff', 'classes', 'other'
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final token = await AuthService.getToken();
      final res = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/member/feedback/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          _history = jsonDecode(res.body);
          _loadingHistory = false;
        });
      } else {
        setState(() => _loadingHistory = false);
      }
    } catch (_) {
      setState(() => _loadingHistory = false);
    }
  }

  Future<void> _submit() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your message'),
            backgroundColor: Colors.red),
      );
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      final token = await AuthService.getToken();
      final res   = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/member/feedback/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'category': _selectedCategory,
          'message':  _messageController.text.trim(),
          'rating':   _rating,
        }),
      );
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        setState(() {
          
          _history   = [data, ..._history];
        });
        _messageController.clear();
        setState(() { _rating = 4; _selectedCategory = 'general'; });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted! Thank you.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      } else {
        final data = jsonDecode(res.body);
        setState(() =>
            _error = data['message'] ?? data['error'] ?? 'Submission failed');
      }
    } catch (_) {
      setState(() => _error = 'Cannot connect to server');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Color _statusColor(String status) {
    switch (status) {
      case 'reviewed': return AppTheme.primaryGreen;
      case 'resolved': return Colors.blue;
      default:         return Colors.orange;
    }
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
                      style: TextStyle(color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  Text('We value your feedback',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Submit card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.edit_outlined, size: 18,
                                color: AppTheme.primaryGreen),
                            SizedBox(width: 8),
                            Text('Submit Feedback',
                                style: TextStyle(fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark)),
                          ]),
                          const SizedBox(height: 16),
                          // Category
                          const Text('Category',
                              style: TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textDark)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: _categories.map((cat) {
                              final selected = _selectedCategory == cat;
                              return GestureDetector(
                                onTap: () => setState(
                                    () => _selectedCategory = cat),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppTheme.primaryGreen
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selected
                                          ? AppTheme.primaryGreen
                                          : AppTheme.dividerColor,
                                    ),
                                  ),
                                  child: Text(_cap(cat),
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : AppTheme.textGrey,
                                        fontSize: 13,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      )),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          // Message
                          const Text('Your Message',
                              style: TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textDark)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _messageController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: "Tell us what's on your mind...",
                              hintStyle: TextStyle(
                                  color: AppTheme.textGrey, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Rating
                          const Text('Rating',
                              style: TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textDark)),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (i) {
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _rating = i + 1),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(
                                    i < _rating
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: Colors.amber, size: 36,
                                  ),
                                ),
                              );
                            }),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.red.shade200),
                              ),
                              child: Text(_error!,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red.shade700)),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: _submitting
                                ? const SizedBox(width: 16, height: 16,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2))
                                : const Icon(Icons.send_outlined, size: 18),
                            label: Text(_submitting
                                ? 'Submitting...'
                                : 'Submit Feedback'),
                            onPressed: _submitting ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // History
                  const Text('My Feedback History',
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 10),
                  if (_loadingHistory)
                    const Center(child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen))
                  else if (_history.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: const Text(
                        'No feedback submitted yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppTheme.textGrey, fontSize: 13),
                      ),
                    )
                  else
                    ...(_history.map((f) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _cap(f['category'] ?? ''),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.primaryGreen,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        children: List.generate(5, (i) =>
                                            Icon(
                                              i < (f['rating'] ?? 0)
                                                  ? Icons.star_rounded
                                                  : Icons.star_outline_rounded,
                                              color: Colors.amber,
                                              size: 14,
                                            )),
                                      ),
                                    ]),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statusColor(f['status'] ?? '')
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _cap(f['status'] ?? ''),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: _statusColor(
                                                f['status'] ?? ''),
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(f['message'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textDark)),
                                const SizedBox(height: 6),
                                Text(
                                  DateTime.parse(f['created_at'])
                                      .toLocal()
                                      .toString()
                                      .substring(0, 10),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textGrey),
                                ),
                              ],
                            ),
                          ),
                        ))),
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