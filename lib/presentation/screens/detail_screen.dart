import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/constants.dart';
import '../../core/theme/theme.dart';
import '../../data/models/placement_update.dart';

class DetailScreen extends StatelessWidget {
  final PlacementUpdate update;

  const DetailScreen({super.key, required this.update});

  Future<void> _openGmailMessage(BuildContext context) async {
    final String urlStr = AppConstants.getGmailWebUrl(update.gmailMessageId);
    final Uri url = Uri.parse(urlStr);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to open email. Link: $urlStr"),
            action: SnackBarAction(
              label: 'Copy',
              textColor: AppTheme.primaryNeon,
              onPressed: () {
                // Copy logic is optional, but snackbar informs user
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor(update.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shortlist Details"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Header (Big & clean)
              Text(
                update.companyName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // 2-Column Stats Grid (Inspired by Oura Screen 1 Stats Layout)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderMuted, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildGridItem(
                            context,
                            "SELECTION ROUND",
                            update.status.toUpperCase(),
                            valueColor: statusColor,
                          ),
                        ),
                        Expanded(
                          child: _buildGridItem(
                            context,
                            "DATE RECEIVED",
                            _formatDate(update.dateReceived),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGridItem(
                            context,
                            "SPREADSHEET",
                            update.hasExcelAttachment ? "ATTACHED" : "NONE",
                            valueColor: update.hasExcelAttachment ? AppTheme.primaryNeon : AppTheme.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: _buildGridItem(
                            context,
                            "MESSAGE ID",
                            update.gmailMessageId.substring(0, min(12, update.gmailMessageId.length)) + "...",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              
              // Email Subject Section
              _buildSectionLabel("SUBJECT"),
              const SizedBox(height: 8),
              Text(
                update.emailSubject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Email snippet section
              _buildSectionLabel("EMAIL SNIPPET"),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderMuted, width: 1),
                ),
                child: Text(
                  update.snippet,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Excel indicator if applicable
              if (update.hasExcelAttachment) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeon.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.15), width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.table_chart, color: AppTheme.primaryNeon, size: 24),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Spreadsheet Attached",
                              style: TextStyle(
                                color: AppTheme.primaryNeon,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "VIT CDC attached a shortlist Excel sheet. Open the email in Gmail to view or download it.",
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Open in Gmail Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
                icon: const Icon(Icons.mail_outline, color: Colors.black),
                label: const Text("Open Original Email in Gmail"),
                onPressed: () => _openGmailMessage(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  // Helper to build 2-column grid items (Inspired by Oura Screen 1)
  Widget _buildGridItem(BuildContext context, String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'offered':
        return AppTheme.primaryNeon;
      case 'online test':
        return AppTheme.secondaryGold;
      case 'interview':
        return AppTheme.accentTeal;
      case 'ppt':
        return Colors.indigoAccent;
      case 'shortlisted':
        return Colors.lightGreenAccent;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
