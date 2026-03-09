import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String? _qrData;
  String? _memberName;
  String? _membership;
  String? _status;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQR();
  }

  Future<void> _loadQR() async {
    setState(() { _loading = true; _error = null; });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() { _error = 'Not logged in'; _loading = false; });
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/member/qr/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Also get membership info from saved member data
        final member = await AuthService.getMember();

        setState(() {
          _qrData      = data['qr_data'];
          _memberName  = data['name'];
          _membership  = member?['membership'] ?? 'basic';
          _status      = member?['status'] ?? 'active';
          _loading     = false;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error   = data['error'] ?? 'Failed to load QR code';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error   = 'Cannot connect to server. Make sure you are on the same network.';
        _loading = false;
      });
    }
  }

  String get _membershipLabel {
    switch (_membership) {
      case 'premium':  return 'Premium';
      case 'standard': return 'Standard';
      default:         return 'Basic';
    }
  }

  Color get _membershipColor {
    switch (_membership) {
      case 'premium':  return const Color(0xFFFFD700); // gold
      case 'standard': return Colors.blue;
      default:         return Colors.grey;
    }
  }

  Color get _statusColor {
    switch (_status) {
      case 'active':  return AppTheme.primaryGreen;
      case 'frozen':  return Colors.blue;
      case 'expired': return Colors.red;
      default:        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('My QR Code'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : _error != null
              ? _buildError()
              : _buildQR(),
    );
  }

  Widget _buildQR() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // ── Instruction ───────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryGreen, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Show this QR code to the gym staff to check in',
                    style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── QR Code Card ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Member name
                Text(
                  _memberName ?? 'Member',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 6),
                // Membership badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _membershipColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _membershipLabel,
                        style: TextStyle(
                            color: _membershipColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _status![0].toUpperCase() + _status!.substring(1),
                        style: TextStyle(
                            color: _statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Actual QR ────────────────────────────
                QrImageView(
                  data: _qrData!,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppTheme.primaryGreen,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan at reception',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Security note ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: AppTheme.textGrey, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This QR code is unique to your account and cryptographically signed. Do not share it.',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Refresh button ────────────────────────────
          TextButton.icon(
            onPressed: _loadQR,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh QR'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2, size: 80, color: AppTheme.textGrey),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadQR,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            ),
          ],
        ),
      ),
    );
  }
}